import Foundation
import Combine

@available(iOS 15.0, *)
@available(macOS 12.0, *)
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
        //decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private let endpoint: URL = URL(string: "https://www.portrait.gov.au/json/ondisplaytest/all")!
    
    @Published public var areas: [NPGArea] = []
    @Published public var locations: [NPGLocation] = []
    @Published public var labels: [NPGLabel] = []
    
    public init() {
        
    }
    
    public func refreshData() async throws {
        let (data, _) = try await session.data(from: endpoint)
        
        let npgData = try jsonDecoder.decode(NPGData.self, from: data)
        
        DispatchQueue.main.async {
            self.areas = npgData.areas
            self.locations = npgData.locations
            self.labels = npgData.labels
        }
    }
}
