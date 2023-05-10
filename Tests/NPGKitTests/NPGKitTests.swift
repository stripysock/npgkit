import XCTest
import Combine
@testable import NPGKit

@available(iOS 15.0, *)
final class NPGKitTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    func testDataRetrieval() {
        let expectation = XCTestExpectation(description: "Items load successfully")
        let npgKit = NPGKit()
        
        Task {
            do {
                try await npgKit.refreshData()
                
                if !npgKit.labels.isEmpty {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected to see some label data")
                }
                
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 15)

    }
}
