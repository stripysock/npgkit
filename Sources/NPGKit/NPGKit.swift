import Foundation
import os.log

@available(iOS 15.0, *)
@available(macOS 12.0, *)
@available(tvOS 16.0, *)
@available(visionOS 1.0, *)
public actor NPGKit {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: #file)
    )
    
    public enum DataSource: String, Sendable {
        case fixture
        case development
        case production
        
        var defaultPollPeriod: TimeInterval {
            switch self {
                case .fixture:
                    60 // 60 seconds
                case .development:
                    60 * 15 // 15 minutes
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
    
    public init(dataSource: DataSource = .production) {
        self.dataSource = dataSource
    }
    
    /**
     An async throwing stream of areas within (and possibly beyond) the National Portrait Gallery.
     
     - throws: Will throw an `NPGError` if the content can't be retrieved or is malformed.
     */
    public func areas(pollEvery pollPeriod: TimeInterval? = nil) -> AsyncThrowingStream<[NPGArea], Error> {
        pollingStreamForNPGObject(pollEvery: pollPeriod)
    }
    
    /**
     An async throwing stream of of artworks on display within the NPG.
     
     - throws: Will throw an `NPGError` if the content can't be retrieved or is malformed.
     */
    public func artworks(pollEvery pollPeriod: TimeInterval? = nil) -> AsyncThrowingStream<[NPGArtwork], Error> {
        pollingStreamForNPGObject(pollEvery: pollPeriod)
    }
    
    /**
     An async throwing stream of location beacons used throughout the NPG.
     
     - throws: Will throw an `NPGError` if the content can't be retrieved or is malformed.
     */
    public func beacons(pollEvery pollPeriod: TimeInterval? = nil) -> AsyncThrowingStream<[NPGBeacon], Error> {
        pollingStreamForNPGObject(pollEvery: pollPeriod)
    }
    
    /**
     An async throwing stream of entities (people or collectives) referenced in the gallery.
     
     - throws: Will throw an `NPGError` if the content can't be retrieved or is malformed.
     */
    public func entities(pollEvery pollPeriod: TimeInterval? = nil) -> AsyncThrowingStream<[NPGEntity], Error> {
        pollingStreamForNPGObject(pollEvery: pollPeriod)
    }
    
    /**
     An async throwing stream of  locations with the NPG.
     Use a location's ``areaID`` to determine the associated area.
     
     - throws: Will throw an `NPGError` if the content can't be retrieved or is malformed.
     */
    public func locations(pollEvery pollPeriod: TimeInterval? = nil) -> AsyncThrowingStream<[NPGArea.Location], Error> {
        pollingStreamForNPGObject(pollEvery: pollPeriod)
    }
    
    /**
     An async throwing stream of tours offered within (and possibly beyond) the National Portrait Gallery.
     
     - throws: Will throw an `NPGError` if the content can't be retrieved or is malformed.
     */
    public func tours(pollEvery pollPeriod: TimeInterval? = nil) -> AsyncThrowingStream<[NPGTour], Error> {
        pollingStreamForNPGObject(pollEvery: pollPeriod)
    }
    
    private var timerBucket: [Timer] = []
    private func pollingStreamForNPGObject<T: NPGObject>(pollEvery pollPeriod: TimeInterval? = nil) -> AsyncThrowingStream<[T], Error> {
        let session = self.session
        let jsonDecoder = self.jsonDecoder
        let dataSource = self.dataSource
        let pollPeriod = pollPeriod ?? dataSource.defaultPollPeriod
        
        return AsyncThrowingStream { continuation in
            
            Task {
                repeat {
                    let data: Data
                    
                    do {
                        switch dataSource {
                            case .fixture:
                                guard let path = Bundle.module.path(forResource: "fixture", ofType: "json"),
                                      FileManager.default.fileExists(atPath: path),
                                      let fixtureData = FileManager.default.contents(atPath: path) else {
                                    fatalError("No fixture data found for \(T.self).")
                                }
                                data = fixtureData
                            default:
                                let endpoint = try dataSource.endpoint(for: T.self)
                                let (sessionData, _) = try await session.data(from: endpoint)
                                data = sessionData
                        }
                        
                        let npgData = try jsonDecoder.decode(NPGData.self, from: data)
                        
                        let values: [T] = try npgData.items()
                        
                        let decodingErrors = try npgData.decodingErrors(for: T.self)
                        if !decodingErrors.isEmpty {
                            Self.logger.error("\(decodingErrors.count) errors encountered whilst decoding \(T.self) entities.")
                        }
                        
                        continuation.yield(values)
                        
                    } catch {
                        continuation.finish(throwing: error)
                    }
                    
                    try await Task.sleep(for: .seconds(pollPeriod))
                } while !Task.isCancelled
            }
            
        }
        
    }
}

@available(iOS 15.0, *)
@available(macOS 12.0, *)
@available(tvOS 16.0, *)
@available(visionOS 1.0, *)
fileprivate extension NPGKit.DataSource {
    enum PathComponent: String {
        case areas = "/areas"
        case locations = "/locations"
        case beacons = "/beacons"
        case artworks = "/labels"
        case entities = "/people"
        case tours = "/tours"
        
        static func forType(_ type: any NPGObject.Type) throws -> Self {
            switch type {
                case is NPGArea.Type:
                    return .areas
                    
                case is NPGArea.Location.Type:
                    return .locations
                    
                case is NPGBeacon.Type:
                    return .beacons
                    
                case is NPGArtwork.Type:
                    return .artworks
                    
                case is NPGEntity.Type:
                    return .entities
                    
                case is NPGTour.Type:
                    return .tours
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
            case is NPGArea.Type:
                guard let values = self.areas else {
                    throw(NPGError.noContentForType(T.self))
                }
                return values.compactMap { $0.base as? T }
                
            case is NPGArea.Location.Type:
                guard let values = self.locations else {
                    throw(NPGError.noContentForType(T.self))
                }
                return values.compactMap { $0.base as? T }
            
            case is NPGArtwork.Type:
                guard let values = self.artworks else {
                    throw(NPGError.noContentForType(T.self))
                }
                return values.compactMap { $0.base as? T }
                
            case is NPGBeacon.Type:
                guard let values = self.beacons else {
                    throw(NPGError.noContentForType(T.self))
                }
                return values.compactMap { $0.base as? T }
                
            case is NPGEntity.Type:
                guard let values = self.entities else {
                    throw(NPGError.noContentForType(T.self))
                }
                return values.compactMap { $0.base as? T }
                
            case is NPGTour.Type:
                guard let values = self.tours else {
                    throw(NPGError.noContentForType(T.self))
                }
                return values.compactMap { $0.base as? T }
                
            default:
                throw(NPGError.noContentForType(T.self))
        }
    }
    
    func decodingErrors(for type: any NPGObject.Type) throws -> [Error] {
        switch type.self {
            case is NPGArea.Type:
                guard let values = self.areas else {
                    throw(NPGError.noContentForType(type))
                }
                return values.compactMap { $0.error }
                
            case is NPGArea.Location.Type:
                guard let values = self.locations else {
                    throw(NPGError.noContentForType(type))
                }
                return values.compactMap { $0.error }
               
            case is NPGArtwork.Type:
                guard let values = self.artworks else {
                    throw(NPGError.noContentForType(type))
                }
                return values.compactMap { $0.error }
                
            case is NPGBeacon.Type:
                guard let values = self.beacons else {
                    throw(NPGError.noContentForType(type))
                }
                return values.compactMap { $0.error }
                
            case is NPGEntity.Type:
                guard let values = self.entities else {
                    throw(NPGError.noContentForType(type))
                }
                return values.compactMap { $0.error }
            
            case is NPGTour.Type:
                guard let values = self.tours else {
                    throw(NPGError.noContentForType(type))
                }
                return values.compactMap { $0.error }
                
            default:
                throw(NPGError.noContentForType(type))
        }
    }
}
