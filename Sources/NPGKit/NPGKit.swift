import Foundation
import Combine

@available(iOS 15.0, *)
@available(macOS 12.0, *)
@available(tvOS 16.0, *)
public class NPGKit {
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
    
    private let endpoint: URL = URL(string: "https://www.portrait.gov.au/json/ondisplaytest/all")!
    
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
    
    public init() {
        
    }
    
    /// Call to retrieve the latest content from the API and in turn, refresh the various publishers.
    public func refreshData() async throws {
        let (data, _) = try await session.data(from: endpoint)
        
        let npgData = try jsonDecoder.decode(NPGData.self, from: data)
        
        DispatchQueue.main.async {
            self.areas = npgData.areas.compactMap { $0.base }
            self.locations = npgData.locations.compactMap { $0.base }
            self.artworks = npgData.labels.compactMap { $0.base }
            self.beacons = npgData.beacons.compactMap { $0.base }
            self.tours = npgData.tours.compactMap { $0.base }
        }
    }
}
