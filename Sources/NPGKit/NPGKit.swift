import Foundation
import Combine

@available(iOS 15.0, *)
@available(macOS 12.0, *)
@available(tvOS 16.0, *)
@available(visionOS 1.0, *)
public class NPGKit {
    public enum DataSource: String, Sendable {
        case fixture
        case development
        case production
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
        self.metadata = npgData.metadata
        self.areas = npgData.areas.compactMap { $0.base }
        self.locations = npgData.locations.compactMap { $0.base }
        self.artworks = npgData.artworks.compactMap { $0.base }
        self.beacons = npgData.beacons.compactMap { $0.base }
        self.tours = npgData.tours.compactMap { $0.base }
        self.entities = npgData.entities.compactMap { $0.base }
    }
}

@available(iOS 15.0, *)
@available(macOS 12.0, *)
@available(tvOS 16.0, *)
@available(visionOS 1.0, *)
fileprivate extension NPGKit.DataSource {
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
}
