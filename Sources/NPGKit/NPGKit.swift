import Foundation
import Combine
import os.log

@available(iOS 15.0, *)
@available(macOS 12.0, *)
@available(tvOS 16.0, *)
@available(visionOS 1.0, *)
public class NPGKit {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: #file)
    )
    
    public enum DataSource: String, Sendable {
        case fixture
        case development
        case production
        
        var pollPeriod: TimeInterval {
            switch self {
                case .fixture:
                    30
                case .development:
                    60 * 60 * 1 // hour
                case .production:
                    60 * 60 * 1 // 1 hour
            }
        }
    }
    
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    private let dataSource: DataSource
    
    /// A published metadata object containing text about the service.
    @Published public var metadata: NPGMetadata = .empty
    
    /// A published collection of areas within (and possibly beyond) the National Portrait Gallery.
    @Published public var areas: [NPGArea] = []
    
    /// A published collection of locations with the NPG. Use a location's ``areaID`` to determine the associated area.
    @Published public var locations: [NPGArea.Location] = []
    
    /// A published collection of artwork on display within the NPG.
    @Published public var artworks: [NPGArtwork] = []
    
    /// A published collection of location beacons used throughout the NPG.
    @Published public var beacons: [NPGBeacon] = []
    
    /// A published collection of tours offered within (and possibly beyond) the National Portrait Gallery.
    @Published public var tours: [NPGTour] = []
    
    /// A published collection of entities (people or collectives) referenced in the gallery.
    @Published public var entities: [NPGEntity] = []
    
    public init(dataSource: DataSource = .production) {
        self.dataSource = dataSource
    }
    
    public func artworksStream() -> AsyncThrowingStream<[NPGArtwork], Error> {
        pollingStreamForNPGObject()
    }
    
    public func entitiesStream() -> AsyncThrowingStream<[NPGEntity], Error> {
        pollingStreamForNPGObject()
    }
    
    private func pollingStreamForNPGObject<T: NPGObject>() -> AsyncThrowingStream<[T], Error> {
        let session = self.session
        let jsonDecoder = self.jsonDecoder
        let dataSource = self.dataSource
        let pollPeriod = dataSource.pollPeriod
        
        return AsyncThrowingStream { continuation in
            let timer = Timer.scheduledTimer(withTimeInterval: pollPeriod, repeats: true) { _ in
                Task {
                    
                    let data: Data
                    switch dataSource {
                        case .fixture:
                            guard let path = Bundle.module.path(forResource: "fixture", ofType: "json"),
                                  FileManager.default.fileExists(atPath: path),
                                  let fixtureData = FileManager.default.contents(atPath: path) else {
                                fatalError("No fixture data found.")
                            }
                            data = fixtureData
                        default:
                            let endpoint = try dataSource.endpoint(for: T.self)
                            let (sessionData, _) = try await session.data(from: endpoint)
                            data = sessionData
                    }
                    
                    do {
                        // Note that [NPGData] is a stop gap whilst the API has an error
                        let npgDataCollection: [NPGData]
                        if let preferred = try? jsonDecoder.decode(NPGData.self, from: data) {
                            npgDataCollection = [preferred]
                        } else {
                            npgDataCollection = try jsonDecoder.decode([NPGData].self, from: data)
                        }
                        
                        guard let npgData = npgDataCollection.first else {
                            throw(NPGError.invalidStringFormat(expectedFormat: "Couldn't retrieve content"))
                        }
                        
                        let values: [T] = try npgData.items()
                        
                        continuation.yield(values)
                        
                        let decodingErrors = try npgData.decodingErrors(for: T.self)
                        if !decodingErrors.isEmpty {
                            Self.logger.error("\(decodingErrors.count) errors encountered whilst decoding entities.")
                        }
                        
                    } catch {
                        continuation.finish(throwing: error)
                    }
                    
                    
                }
            }
            
            timer.fire()
        }
        
    }
    
    /// Call to retrieve the latest content from the API and in turn, refresh the various publishers.
    public func refreshData() async throws {
        let data: Data
        switch dataSource {
        case .fixture:
            guard let path = Bundle.module.path(forResource: "fixture", ofType: "json"),
                  FileManager.default.fileExists(atPath: path),
                  let fixtureData = FileManager.default.contents(atPath: path) else {
                fatalError("No fixture found for the data source \"\(dataSource.rawValue)\".")
            }
            data = fixtureData
        default:
            guard let endpoint = dataSource.endpoint else {
                fatalError("No endpoint specified for the data source \"\(dataSource.rawValue)\".")
            }
            let (sessionData, _) = try await session.data(from: endpoint)
            data = sessionData
        }
        
        let npgData = try jsonDecoder.decode(NPGData.self, from: data)
        
        await updateContent(npgData: npgData)
    }
    
    @MainActor
    func updateContent(npgData: NPGData) {
        if let metadata = npgData.metadata {
            self.metadata = metadata
        }
        self.areas = npgData.areas?.compactMap { $0.base } ?? []
        self.locations = npgData.locations?.compactMap { $0.base } ?? []
        self.artworks = npgData.artworks?.compactMap { $0.base } ?? []
        self.beacons = npgData.beacons?.compactMap { $0.base } ?? []
        self.tours = npgData.tours?.compactMap { $0.base } ?? []
        self.entities = npgData.entities?.compactMap { $0.base } ?? []
    }
}

@available(iOS 15.0, *)
@available(macOS 12.0, *)
@available(tvOS 16.0, *)
@available(visionOS 1.0, *)
fileprivate extension NPGKit.DataSource {
    enum PathComponent: String {
        case artworks = "/labels"
        case entities = "/people"
        
        static func forType(_ type: any NPGObject.Type) throws -> Self {
            switch type {
                case is NPGArtwork.Type:
                    return .artworks
                    
                case is NPGEntity.Type:
                    return .entities
                default:
                    throw(NPGError.noPathComponentForType(type))
            }
        }
    }
    
    var baseURL: URL? {
        switch self {
        case .development:
            return URL(string: "https://www.portrait.gov.au/json/ondisplaydev")
            
        case .production:
            return URL(string: "https://www.portrait.gov.au/json/ondisplaylive")
            
        default:
            return nil
        }
    }
    
    var endpoint: URL? {
        if let baseURL = baseURL {
            baseURL.appending(path: "/all")
        } else {
            nil
        }
    }
    
    func endpoint(for type: any NPGObject.Type) throws -> URL {
        guard let baseURL = baseURL else {
            throw(NPGError.noBaseURLForDataSource)
        }
        
        let pathComponent = try PathComponent.forType(type)
        
        return baseURL.appending(path: pathComponent.rawValue)
    }
}

fileprivate extension NPGData {
    func items<T: NPGObject>() throws -> [T] {
        switch T.self {
            case is NPGArtwork.Type:
                guard let values = self.artworks else {
                    throw(NPGError.noContentForType(T.self))
                }
                return values.compactMap { $0.base as? T }
                
            case is NPGEntity.Type:
                guard let values = self.entities else {
                    throw(NPGError.noContentForType(T.self))
                }
                return values.compactMap { $0.base as? T }
                
            default:
                throw(NPGError.noContentForType(T.self))
        }
    }
    
    func decodingErrors(for type: any NPGObject.Type) throws -> [Error] {
        switch type.self {
            case is NPGArtwork.Type:
                guard let values = self.artworks else {
                    throw(NPGError.noContentForType(type))
                }
                return values.compactMap { $0.error }
                
            case is NPGEntity.Type:
                guard let values = self.entities else {
                    throw(NPGError.noContentForType(type))
                }
                return values.compactMap { $0.error }
                
            default:
                throw(NPGError.noContentForType(type))
        }
    }
}
