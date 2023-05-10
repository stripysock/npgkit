import Foundation

/**
 NPGError covers errors encountered when using NPGKit.
 */
enum NPGError: LocalizedError {
    /// An invalid data format encountered, possibly when
    case invalidStringFormat(expectedFormat: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidStringFormat(let expectedFormat):
            return "Incorrect string format. Expected \"\(expectedFormat)\"."
        }
    }
}
