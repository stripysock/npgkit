import Foundation

internal struct FailableDecodable<Base: Decodable> : Decodable {
    let base: Base?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}

internal struct NPGData: Decodable {
    public struct Metadata: Decodable {
        var title: String
        var subtitle: String
        var intro: String
    }
    
    var title: Metadata
    var areas: [FailableDecodable<NPGArea>]
    var locations: [FailableDecodable<NPGLocation>]
    var labels: [FailableDecodable<NPGLabel>]
}

protocol NPGObject: Hashable {
    var id: Int { get }
    var dateModified: Date { get }
}

protocol NPGFile: NPGObject {
    var url: URL { get }
}

/**
 NPGBool is a stand-in for the standard Bool, but allows for "yes" and "no" values.
 */
internal enum NPGBool: String, Codable {
    case yes
    case no
}

/**
 NPGArea is a space within the gallery that encompasses one or more locations.
 For example, the area for Portrait 23 encompasses the locations "Gallery 4", "Gallery 5", "Gallery 6", "Gallery 6 Nook 1" and "Gallery 6 Nook 2".
 */
public struct NPGArea: NPGObject, Codable {
    /// A unique identifier for this area.
    public var id: Int
    
    /// Last modified date for this area.
    public var dateModified: Date
    
    /// A title for this area, for instance, "Portrait 23".
    public var title: String
    
    /// An optional subtitle for this area.
    public var subtitle: String?
    
    /// A becaon identifier associated with this area.
    public var beacon: String?
    
    /// Sort priority
    public var priority: Int
    
    /// All of the locations encapsulated by this area.
    public var locationIDs: [Int]
    
    /// All of the labels that appear within the entire area.
    public var labelIDs: [Int]
}

/**
 NPGLocation represents a given contiguous area within the Gallery. This might be an entire Gallery space (i.e. Gallery 2), an alcove, or even a wall.
 */
public struct NPGLocation: NPGObject, Codable {
    /// A unique identifier for this location.
    public var id: Int
    
    /// The ID of the ``NPGArea`` that encompasses this location.
    public var areaID: Int
    
    /// Last modified date for this area.
    public var dateModified: Date
    
    /// A title for this location, for instance, "Gallery 2"
    public var title: String
    
    /// An optional subtitle for this location, for instance, "Emerging Artists"
    public var subtitle: String?
    
    /// An optional text of a label that may appear at the entrance to the space.
    public var content: String?
    
    /// A becaon identifier associated with this location.
    public var beacon: String?
    
    /// Sort priority.
    public var priority: Int
    
    /// All of the labels that appear within this location
    public var labelIDs: [Int]
    
    /// Audio wayfinding entry, guiding the user from this location to another.
    public var audioGuidance: [NPGAudio]
    
    /// Audio wayfinding entry, describing the features of this location.
    public var audioDescription: [NPGAudio]
}


public struct NPGLabel: NPGObject, Codable {
    public struct LabelText: Codable, Hashable {
        public enum LabelType: String, Codable, Hashable {
            case caption
            case label
        }
        
        /// The type of label that this item represents.
        public var type: LabelType
        
        /// The text content of the label, formatted in HTML.
        public var content: String
        
        /// The sort priority for this label.
        public var priority: Int
    }
    
    public struct Nearby: Codable, Hashable {
        public enum Relationship: String, Codable, Hashable {
            case above
            case below
            case left
            case right
            case near
            case nearrelated
        }
        var id: Int
        var relationship: Relationship
    }
    
    public var id: Int
    public var dateModified: Date
    public var title: String
    public var subtitle: String
    public var dateCreated: String
    public var areaID: Int
    public var locationID: Int?
    public var beacon: String?
    public var priority: Int
    /// Use convenience ``size`` instead.
    var width: Double
    /// Use convenience ``size`` instead.
    var height: Double
    public var text: [LabelText]
    public var images: [NPGImage]
    public var nearbyLabels: [Nearby]
    public var audio: [NPGAudio]
    public var audioDescription: [NPGAudio]
    public var scanObjects: [NPG3DObject]
}

public struct NPGImage: NPGFile {
    public struct CropSize: Hashable {
        public var width: Double
        public var height: Double
        public var cropTopLeftX: Double
        public var cropTopLeftY: Double
        public var cropBottomRightX: Double
        public var cropBottomRightY: Double
    }
    
    public var id: Int
    public var dateModified: Date
    public var scanningOnly: Bool
    /// Use convenience ``size`` instead.
    var width: Double
    /// Use convenience ``size`` instead.
    var height: Double
    public var subjectCrop: CropSize?
    public var url: URL
    public var thumbnailURL: URL?
    public var squareURL: URL?
}

public struct NPGAudio: NPGFile, Codable {
    public var id: Int
    public var dateModified: Date
    public var title: String
    public var duration: String
    public var transcript: String
    public var url: URL
}

public struct NPG3DObject: NPGFile, Codable {
    public var id: Int
    public var dateModified: Date
    public var url: URL
}
