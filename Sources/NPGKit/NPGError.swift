import Foundation

/**
 NPGError covers errors encountered when using NPGKit.
 */
enum NPGError: LocalizedError {
    /// Thrown when a string is expected - but not received - in a certain format.
    case invalidStringFormat(expectedFormat: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidStringFormat(let expectedFormat):
            return "Incorrect string format. Expected \"\(expectedFormat)\"."
        }
    }
}
