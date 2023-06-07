import Foundation

// MARK: Internal Items

/**
 FailableDecodable allows us to decode a whole list of objects, even if one of them is corrupt.
 */
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
    var labels: [FailableDecodable<NPGArtwork>]
}

/**
 NPGBool is a stand-in for the standard Bool, but allows for "yes" and "no" values.
 */
internal enum NPGBool: String, Codable {
    case yes
    case no
}

// MARK: Public Items

public protocol NPGObject: Hashable {
    var id: Int { get }
    var dateModified: Date { get }
}

/// A file referenced by our model.
public protocol NPGFile: NPGObject {
    var url: URL { get }
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

/**
 NPGArtwork represents the publicly available data and metadata for an artwork.
 It includes the name and description of the artwork along with images, 3D objects (for scanning), and audio files describing the work or as an interview with the artist or sitter.
 */
public struct NPGArtwork: NPGObject, Codable {
    
    /// Text used for an artwork's on-wall label.
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
    
    /// A structure that describes the relative position of another artwork.
    public struct Nearby: Codable, Hashable {
        /// The relative position of one artwork to another.
        public enum Relationship: String, Codable, Hashable {
            case above
            case below
            case left
            case right
            case near
            case nearrelated
        }
        
        /// The ID of the related artwork.
        var id: Int
        
        /// The position of the related artwork relative to ours.
        var relationship: Relationship
    }
    
    /// The unique identifier of this artwork.
    public var id: Int
    
    /// When the data was last updated within NPG's database
    public var dateModified: Date
    
    /// The title of the artwork.
    public var title: String
    
    /// A subtitle for this work. May be the artist name or a catchy byline.
    public var subtitle: String
    
    /// The date this artwork was created by the artist.
    public var dateCreated: String
    
    /// The ID of the area in which this portrait exists.
    public var areaID: Int
    
    /// If present, the ID of the specific location in which this artwork exists.
    public var locationID: Int?
    
    /// The ID of the beacon associated with this artwork. If empty, use the beacon associated with the area or location.
    public var beacon: String?
    
    /// Sort priority. This may be used to passively encourage a particular visitor flow and may not seem to have any logical reason.
    public var priority: Int
    
    /// Use convenience ``size`` instead.
    var width: Double
    
    /// Use convenience ``size`` instead.
    var height: Double
    
    /// A collection of label text related to the artwork.
    public var text: [LabelText]
    
    /// Images of this artwork which may be used for display or scanning.
    public var images: [NPGImage]
    
    /// Information on artworks physically near this one.
    public var nearbyArtworks: [Nearby]
    
    /// An array of audio files that relate to the artwork. These may be artist interviews, critiques or information about the sitter.
    public var audio: [NPGAudio]
    
    /// An array of audio files that describe the features of the artwork.
    public var audioDescription: [NPGAudio]
    
    /// An array of 3D Objects to be used for detection by ARKit
    public var scanObjects: [NPG3DObject]
}

/// An image file representing an artwork.
public struct NPGImage: NPGFile {
    /// A structure dictating how an image should be cropped.
    public struct CropSize: Hashable {
        public var width: Double
        public var height: Double
        public var cropTopLeftX: Double
        public var cropTopLeftY: Double
        public var cropBottomRightX: Double
        public var cropBottomRightY: Double
    }
    
    /// The unique identifier of our image.
    public var id: Int
    
    /// When this image was last modified.
    public var dateModified: Date
    
    /// If true, this image should only be used for AR Image detection and should not be shown to the general public.
    public var scanningOnly: Bool
    
    /// Internal - Use convenience ``size`` instead.
    var width: Double
    
    /// Internal  - Use convenience ``size`` instead.
    var height: Double
    
    /// If present, `subjectCrop` defines how to crop the image to focus on the subject.
    public var subjectCrop: CropSize?
    
    /// The publicly accessible URL of the image.
    public var url: URL
    
    /// A smaller, possibly cropped version of the image suitable for thumbail use.
    public var thumbnailURL: URL?
    
    /// A square-cropped version of the image that (hopefully) takes the sitter's position into consideration.
    public var squareURL: URL?
}

/// An audio file associated with an artwork.
public struct NPGAudio: NPGFile, Codable {
    /// The unique identifier of our file.
    public var id: Int
    
    /// When this file was last modified.
    public var dateModified: Date
    
    /// The title of the recording.
    public var title: String
    
    /// A string description of the **approximate** run length. Use other means to determine duration where possible.
    public var duration: String
    
    /// A HTML string containing a textual representation of the recording.
    public var transcript: String
    
    /// The publicly accessible URL of the file.
    public var url: URL
}

/// An 3D scan associated with an artwork.
public struct NPG3DObject: NPGFile, Codable {
    /// The unique identifier of our file.
    public var id: Int
    
    /// When this file was last modified.
    public var dateModified: Date
    
    /// The publicly accessible URL of the file.
    public var url: URL
}
