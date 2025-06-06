import Foundation

// MARK: Internal Items

/**
 FailableDecodable allows us to decode a whole list of objects, even if one of them is corrupt.
 */
internal struct FailableDecodable<Base: Decodable & Sendable> : Decodable & Sendable {
    let base: Base?
    let error: Error?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self.base = try container.decode(Base.self)
            self.error = nil
        } catch {
            self.base = nil
            self.error = error
        }
    }
}

public struct NPGMetadata: Codable, Sendable {
    public var title: String
    public var subtitle: String
    public var intro: String
}

internal struct NPGData: Decodable, Sendable {
    
    var metadata: NPGMetadata?
    var areas: [FailableDecodable<NPGArea>]?
    var locations: [FailableDecodable<NPGArea.Location>]?
    var artworks: [FailableDecodable<NPGArtwork>]?
    var beacons: [FailableDecodable<NPGBeacon>]?
    var tours: [FailableDecodable<NPGTour>]?
    var entities: [FailableDecodable<NPGEntity>]?
}

/**
 NPGBool is a stand-in for the standard Bool, but allows for "yes" and "no" values.
 */
internal enum NPGBool: String, Codable, Sendable {
    case yes
    case no
}

// MARK: Public Items

public protocol NPGObject: Hashable, Identifiable, Sendable {
    var id: Int { get }
    var dateModified: Date { get }
}

/// A file referenced by our model.
public protocol NPGFile: NPGObject {
    var url: URL { get }
}

/**
 NPGCoordinates acts as a container for latitude/longitude values, (presumably) using the WGS 84 reference frame.
 
 Consider extending this struct to export `CLLocationCoordinate2D` or equivalent as required for your implementation.
 */
public struct NPGCoordinates: Hashable, Codable, Sendable {
    public var latitude: Double
    public var longitude: Double
}

/**
 NPGTour represents a self-guided tour or pre-determined path through the gallery.
 */
public struct NPGTour: NPGObject, Codable {
    
    /**
     TourStop represents a particular stop on an ``NPGTour``.
     */
    public struct TourStop: NPGObject, Codable {
        /// A unique identifier for this tour stop.
        public var id: Int
        
        /// Last modified date for this tour stop..
        public var dateModified: Date
        
        /// The name of the tour stop.
        public var title: String
        
        /// A subtitle, catch-phrase or second-half of a colonic title. Yep, that's a thing. Bing it.
        public var subtitle: String?
        
        /// Additional textual content to be displayed.
        public var content: String?
        
        /// A beacon identifier associated with this tour stop.
        public var beaconID: Int
        
        /// Sort priority
        public var priority: Int
        
        /// IDs of all of the labels that appear within this tour stop.
        public var artworkIDs: [Int]
        
        /// Audio tracks associated with this tour stop.
        public var audio: [NPGAudio]
    }
    
    /// A unique identifier for this tour.
    public var id: Int
    
    /// Last modified date for this tour.
    public var dateModified: Date
    
    /// The name of the tour.
    public var title: String
    
    /// A subtitle, catch-phrase or second-half of a colonic title. Yep, that's a thing. Bing it.
    public var subtitle: String?
    
    /// A beacon identifier associated with this tour. This would be used to kick off the tour.
    public var beaconID: Int?
    
    /// Sort priority
    public var priority: Int
    
    /// Audio tracks that introduce the tour.
    public var audio: [NPGAudio]
    
    /// The tour stops along this particular tour.
    public var tourStops: [TourStop]
}

/**
 NPGBeacon represents a physical iBeacon within the gallery.
 */
public struct NPGBeacon: NPGObject, Codable {
    
    /// A unique identifier for this beacon.
    public var id: Int
    
    /// Last modified date for this beacon.
    public var dateModified: Date
    
    /// The proximity UUID associated with this beacon. Traditionally all beacons within the gallery shared a proximity ID and differentiated with the major/minor values, though this may change in futre.
    public var proximityUUID: UUID
    
    /// The major value of the beacon.
    public var major: Int
    
    /// The minor value of the beacon. Traditionally this has what has differentiated beacons within the gallery, though this may change in future.
    public var minor: Int
    
    /// A name of an associated location (though not in the NPGLocation sense).
    public var title: String
    
    /// An array of area IDs associated with this beacon.
    public var areaIDs: [Int]
    
    /// An array of location IDs associated with this beacon.
    public var locationIDs: [Int]
    
    /// An array of artwork IDs associated with this beacon.
    public var artworkIDs: [Int]
}


/**
 NPGArea is a space within the gallery that encompasses one or more locations.
 For example, the area for Portrait 23 encompasses the locations "Gallery 4", "Gallery 5", "Gallery 6", "Gallery 6 Nook 1" and "Gallery 6 Nook 2".
 */
public struct NPGArea: NPGObject, Codable {
    
    /**
     NPGArea.Location represents a given contiguous area within the Gallery. This might be an entire Gallery space (i.e. Gallery 2), an alcove, or even a wall.
     */
    public struct Location: NPGObject, Codable {
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
        
        /// A beacon identifier associated with this location.
        public var beaconID: Int?
        
        /// Sort priority.
        public var priority: Int
        
        /// IDs of all of the labels that appear within this location
        public var artworkIDs: [Int]
        
        /// Audio for wayfinding. This could be guiding the user from this location to another (``NPGAudio.AudioContext.wayfinding``) or a description fo the area (``NPGAudio.AudioContext.audiodescription``).
        public var audio: [NPGAudio]
    }
    
    /// A unique identifier for this area.
    public var id: Int
    
    /// Last modified date for this area.
    public var dateModified: Date
    
    /// A title for this area, for instance, "Portrait 23".
    public var title: String
    
    /// An optional subtitle for this area.
    public var subtitle: String?
    
    /// A collection of beacon identifiers associated with this area.
    public var beaconIDs: [Int]
    
    /// Sort priority
    public var priority: Int
    
    /// IDs of all of the locations encapsulated by this area.
    public var locationIDs: [Int]
    
    /// IDs of all of the labels that appear within the entire area.
    public var artworkIDs: [Int]
    
    /// If the area is external to the gallery (for instance, a touring exhibition), the lat/long coordinates.
    public var externalCoordinates: NPGCoordinates?
}

/**
 NPGArtwork represents the publicly available data and metadata for an artwork.
 It includes the name and description of the artwork along with images, 3D objects (for scanning), and audio files describing the work or as an interview with the artist or sitter.
 */
public struct NPGArtwork: NPGObject, Codable {
    
    /// Text used for an artwork's on-wall label.
    public struct LabelText: Codable, Hashable, Sendable {
        public enum LabelType: String, Codable, Hashable, Sendable {
            case caption
            case label
            case biography
        }
        
        /// The type of label that this item represents.
        public var type: LabelType
        
        /// The text content of the label, formatted in HTML.
        public var content: String
        
        /// The sort priority for this label.
        public var priority: Int
    }
    
    /// A structure that describes the relative position of another artwork.
    public struct Nearby: Codable, Hashable, Sendable {
        /// The relative position of one artwork to another.
        public enum Relationship: String, Codable, Hashable, Sendable {
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
    
    /**
     An optional unique identifier that identifies the artwork by the date it was acquired.
     
     This value will only be present by artworks within the gallery collection, not those on loan.
     */
    public var accessionID: String?
    
    /// The ID of the area in which this portrait exists.
    public var areaID: Int
    
    /// If present, the ID of the specific location in which this artwork exists.
    public var locationID: Int?
    
    /// The ID of the beacon associated with this artwork. If empty, use the beacon associated with the area or location.
    public var beaconID: Int?
    
    /// Sort priority. This may be used to passively encourage a particular visitor flow and may not seem to have any logical reason.
    public var priority: Int
    
    /// Width in centimetres. Use convenience ``size`` instead.
    public var width: Double
    
    /// Height in centimetres. Use convenience ``size`` instead.
    public var height: Double
    
    /// A collection of label text related to the artwork.
    public var text: [LabelText]
    
    /// Images of this artwork which may be used for display or scanning.
    public var images: [NPGImage]
    
    /// Information on artworks physically near this one.
    public var nearbyArtworks: [Nearby]
    
    /// An array of audio files that relate to the artwork.
    public var audio: [NPGAudio]
    
    /// An array of video files that relate to the artwork.
    public var video: [NPGVideo]

    /// An array of 3D Objects to be used for detection by ARKit
    public var scanObjects: [NPG3DObject]
}

/// An image file representing an artwork.
public struct NPGImage: NPGFile {
    /**
     A structure dictating how an image should be cropped. If no reference size is supplied (or is zero), it should be assumed that the topLeft and and bottomRight are percentage values of the image's total size.
     
     Note that all of the values are public, but *should* be internal. However, because our computed properties reference these, it can lead to SIL compile errors.
     */
    public struct CropSize: Hashable, Sendable {
        public var referenceWidth: Double
        public var referenceHeight: Double
        public var topLeftX: Double
        public var topLeftY: Double
        public var bottomRightX: Double
        public var bottomRightY: Double
    }
    
    /// A structure specifying the region of a person's face within an image
    public struct FaceCrop: Hashable, Sendable {
        public var entityID: Int
        public var crop: CropSize
    }
    
    /// The unique identifier of our image.
    public var id: Int
    
    /// When this image was last modified.
    public var dateModified: Date
    
    /// If true, this image should only be used for AR Image detection and should not be shown to the general public.
    public var scanningOnly: Bool
    
    /// Internal - Use convenience ``size`` instead.
    public var width: Double
    
    /// Internal  - Use convenience ``size`` instead.
    public var height: Double
    
    /// If present, `subjectCrop` defines how to crop the image to focus on the subject.
    public var subjectCrop: CropSize?
    
    /// The regions in the portrait where a face appears, and who that face belongs to.
    public var faceCrops: [FaceCrop]
    
    /// The publicly accessible URL of the image.
    public var url: URL
    
    /// A smaller, possibly cropped version of the image suitable for thumbail use.
    public var thumbnailURL: URL?
    
    /// A square-cropped version of the image that (hopefully) takes the sitter's position into consideration.
    public var squareURL: URL?
    
    
}

/// An audio file associated with an artwork.
public struct NPGAudio: NPGFile, Codable, Sendable {
    
    /// The context in which an audio file should be used.
    public enum AudioContext: String, Equatable, Codable, Sendable {
        /// An interview with the subject or artist, usually contemporaneous to the associated artwork.
        case intheirownwords
        
        /// Audio describing the assocatiated artwork or location.
        case audiodescription
        
        /// Audio giving directions from one area or location to another.
        case wayfinding
        
        /// Audio related to an artwork or location, but not fitting into ``intheirownwords`` or ``audiodescription``.
        case generalaudio
    }
    
    /// The unique identifier of our file.
    public var id: Int
    
    /// When this file was last modified.
    public var dateModified: Date
    
    /// The sort priority for this audio.
    public var priority: Int
    
    /// The context of the audio.
    public var audioContext: AudioContext
    
    /// The title of the recording.
    public var title: String
    
    /// A string description of the **approximate** run length. Use other means to determine duration where possible.
    public var duration: String
    
    /// A Markdown formatted string containing a textual representation of the recording.
    public var transcript: String
    
    /// A Markdown formatted string containing information about the voice actor.
    public var attribution: String? = nil
    
    /// A Markdown formatted string containing information on where the audio was sourced.
    public var acknowledgements: String? = nil
    
    /// The publicly accessible URL of the file.
    public var url: URL
}

/// An video file associated with an artwork.
public struct NPGVideo: NPGFile, Codable, Sendable {
    
    /// The context in which an video file should be used.
    public enum VideoContext: String, Equatable, Codable, Sendable {
        /// An interview with the subject or artist, usually contemporaneous to the associated artwork.
        case portraitstory
        
        /// Video related to an artwork or location, but not fitting into other contexts.
        case general
    }
    
    /// The unique identifier of our file.
    public var id: Int
    
    /// When this file was last modified.
    public var dateModified: Date
    
    /// The sort priority for this video.
    public var priority: Int
    
    /// The context of the video.
    public var videoContext: VideoContext
    
    /// The title of the recording.
    public var title: String
    
    /// A string description of the **approximate** run length. Use other means to determine duration where possible.
    public var duration: String
    
    /// Internal - Use convenience ``size`` instead.
    public var width: Double
    
    /// Internal  - Use convenience ``size`` instead.
    public var height: Double
    
    /// A Markdown formatted string containing a textual representation of the recording.
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

/**
 NPGEntity represents a person or group, apperaing as either a sitter or artist.
 
 Note that as of 1.0.8 these entities **are not** being retrieved, and instead are a proposed structure for future implmentation.
 */
public struct NPGEntity: NPGObject, Codable {
    
    /// A unique identifier for this entity.
    public var id: Int
    
    /// Last modified date for this entity.
    public var dateModified: Date
    
    /**
     The entity's name as it is usually displayed within the gallery. For an individual this would include the given and family names as structured by their culture, and would include any titles or honorifics. For collectives this would simply be the registered / official name.
     
     ## Examples
     * Drusilla Modjeska
     * Lan Wang
     * Charles Richard Bone
     * Dame Helen Blaxland DBE
     * Midnight Oil
     * Montalbetti + Campbell
     */
    public var displayName: String
    
    /**
     An alternative to ``displayName`` that omits any titles or honorifics, and may also drop additional (secondary) names.
     For collectives, or when the result is no different to the ``displayName``, this should be left as nil.
     
     ## Examples
     * Charles Bone
     * Helen Blaxland
     
     ### See Also
     ``displayName``
     */
    public var simpleName: String?
    
    /**
     An array of an individiual's given names.
     For collectives this should be left as nil.
     
     ## Examples
     * Drusilla
     * Wang
     * Charles, Richard
     * Helen
     
     ### See Also
     ``displayName``
     */
    public var givenNames: [String]?
    
    /**
     An array of an individiual's family names.
     For collectives this should be left as nil.
     
     ## Examples
     * Modjeska
     * Lan
     * Bone
     * Blaxland
     
     ### See Also
     ``displayName``
     */
    public var familyNames: [String]?
    
    /// A collection of  text related to the entity.
    public var text: [NPGArtwork.LabelText]
    
    /// Audio tracks associated with this entity.
    public var audio: [NPGAudio]
    
    /// An array of artwork IDs where this entity appears as the subject.
    public var artworkAsSubjectIDs: [Int]
    
    /// An array of artwork IDs where this entity is credited as the artist.
    public var artworkAsArtistIDs: [Int]
}
