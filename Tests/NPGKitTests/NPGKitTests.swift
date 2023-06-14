import XCTest
import Combine
@testable import NPGKit

@available(iOS 15.0, *)
final class NPGKitTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    func testArtworkRetrieval() {
        let artworkExpectation = XCTestExpectation(description: "Artwork loads successfully")
        let beaconExpectation = XCTestExpectation(description: "Beacons load successfully")
        
        let npgKit = NPGKit()
        
        npgKit.$artworks
            .receive(on: RunLoop.main)
            .sink { artwork in
                if !npgKit.artworks.isEmpty {
                    print("Haz artworks!")
                    artworkExpectation.fulfill()
                } else {
                    print("No artworks yet...")
                }
            }
            .store(in: &cancellables)
        
        npgKit.$beacons
            .receive(on: RunLoop.main)
            .sink { beacons in
                if !npgKit.beacons.isEmpty {
                    print("Haz beacons!")
                    beaconExpectation.fulfill()
                } else {
                    print("No beacons yet...")
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
        
        wait(for: [artworkExpectation,beaconExpectation], timeout: 15)
    }
}
