import Foundation

/**
 NPGError covers errors encountered when using NPGKit.
 */
enum NPGError: LocalizedError {
    /// Thrown when a string is expected - but not received - in a certain format.
    case invalidStringFormat(expectedFormat: String)
    
    /// Thrown when a request for a given content type yields no results.
    case noContentForType(any NPGObject.Type)
    
    /// A URL path component for the given content type doesn't exist.
    case noPathComponentForType(any NPGObject.Type)
    
    /// A base URL for the selected data source doesn't exist.
    case noBaseURLForDataSource
    
    var errorDescription: String? {
        switch self {
        case .invalidStringFormat(let expectedFormat):
            return "Incorrect string format. Expected \"\(expectedFormat)\"."
        
            case .noContentForType(let type):
                return "No content found for \(type)"
                
            case .noPathComponentForType(let type):
                return "No path component found for \(type)"
                
            case .noBaseURLForDataSource:
                return "No base URL for the selected data source."
        }
    }
}
