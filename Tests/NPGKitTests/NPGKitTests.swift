import XCTest
import Combine
@testable import NPGKit

@available(iOS 15.0, *)
final class NPGKitTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private let npgKit = NPGKit()
    
    func testArtworkRetrieval() {
        let artworkExpectation = XCTestExpectation(description: "Artwork loads successfully")
        
        npgKit.$artworks
            .receive(on: RunLoop.main)
            .sink { [npgKit] artwork in
                if !npgKit.artworks.isEmpty {
                    print("Haz \(artwork.count) artworks!")
                    artworkExpectation.fulfill()
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
        
        wait(for: [artworkExpectation], timeout: 8)
    }
    
    func testTourRetrieval() {
        let tourExpectation = XCTestExpectation(description: "Tours load successfully")
        
        npgKit.$artworks
            .receive(on: RunLoop.main)
            .sink { [npgKit] artwork in
                if !npgKit.tours.isEmpty {
                    print("Haz tours!")
                    tourExpectation.fulfill()
                } else {
                    print("No tours yet...")
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
        
        wait(for: [tourExpectation], timeout: 8)
    }
    
    func testLocationRetrieval() {
        let beaconExpectation = XCTestExpectation(description: "Beacons load successfully")
        let areaExpectation = XCTestExpectation(description: "Areas load successfully")
        let locationExpectation = XCTestExpectation(description: "Locations load successfully")
        
        npgKit.$areas
            .receive(on: RunLoop.main)
            .sink { [npgKit] areas in
                if !npgKit.areas.isEmpty {
                    print("Haz areas!")
                    areaExpectation.fulfill()
                } else {
                    print("No areas yet...")
                }
            }
            .store(in: &cancellables)
        
        npgKit.$locations
            .receive(on: RunLoop.main)
            .sink { [npgKit] locations in
                if !npgKit.locations.isEmpty {
                    print("Haz locations!")
                    locationExpectation.fulfill()
                } else {
                    print("No locations yet...")
                }
            }
            .store(in: &cancellables)
        
        npgKit.$beacons
            .receive(on: RunLoop.main)
            .sink { [npgKit] beacons in
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
        
        wait(for: [beaconExpectation, areaExpectation, locationExpectation], timeout: 8)
    }
}
