import XCTest
import Combine
@testable import NPGKit

@available(iOS 15.0, *)
final class NPGKitTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    func testArtworkRetrieval() {
        let expectation = XCTestExpectation(description: "Artwork loads successfully")
        let npgKit = NPGKit()
        
        npgKit.$artworks
            .receive(on: RunLoop.main)
            .sink { artwork in
                if !npgKit.artworks.isEmpty {
                    expectation.fulfill()
                } else {
                    print("No artworks yet...")
                }
            }
            .store(in: &cancellables)
        
        Task {
            do {
                try await npgKit.refreshData()
                
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 15)
    }
}
