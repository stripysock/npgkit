import Foundation
import SwiftUI

public extension Int {
    static func idGenerator() -> Int {
        (0..<Int.max).randomElement() ?? 90210
    }
}

extension NPGObject {
    internal static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
}

extension NPGBool {
    init(bool: Bool) {
        self = bool ? .yes : .no
    }
    
    var bool: Bool {
        self == .yes
    }
}

extension NPGMetadata {
    static public let empty = Self.init(title: "", subtitle: "", intro: "")
}

extension NPGCoordinates {
    public init(latitude: CGFloat = .zero, longitude: CGFloat = .zero) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension NPGTour {
    public init(id: Int = .idGenerator(),
                title: String,
                subtitle: String? = nil,
                beaconID: Int? = nil,
                priority: Int = 1,
                audio: [NPGAudio],
                tourStops: [NPGTour.TourStop]) {
        self.id = id
        self.dateModified = .now
        self.title = title
        self.subtitle = subtitle
        self.beaconID = beaconID
        self.priority = priority
        self.audio = audio
        self.tourStops = tourStops
    }
}

extension NPGTour.TourStop {
    public init(id: Int = .idGenerator(),
                title: String,
                subtitle: String? = nil,
                content: String? = nil,
                beaconID: Int,
                priority: Int = 1,
                artworkIDs: [Int],
                audio: [NPGAudio]) {
        self.id = id
        self.dateModified = .now
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.beaconID = beaconID
        self.priority = priority
        self.artworkIDs = artworkIDs
        self.audio = audio
    }
}

extension NPGBeacon {
    public init(id: Int = .idGenerator(),
                proximityUUID: UUID,
                major: Int = 1,
                minor: Int,
                title: String,
                areaIDs: [Int],
                locationIDs: [Int],
                artworkIDs: [Int]) {
        self.id = id
        self.dateModified = .now
        self.proximityUUID = proximityUUID
        self.major = major
        self.minor = minor
        self.title = title
        self.areaIDs = areaIDs
        self.locationIDs = locationIDs
        self.artworkIDs = artworkIDs
    }
}

extension NPGArea {
    public init(id: Int = .idGenerator(),
                title: String,
                subtitle: String? = nil,
                beaconIDs: [Int],
                priority: Int = 1,
                locationIDs: [Int],
                artworkIDs: [Int],
                externalCoordinates: NPGCoordinates? = nil) {
        self.id = id
        self.dateModified = .now
        self.title = title
        self.subtitle = subtitle
        self.beaconIDs = beaconIDs
        self.priority = priority
        self.locationIDs = locationIDs
        self.artworkIDs = artworkIDs
        self.externalCoordinates = externalCoordinates
    }
}

extension NPGArea.Location {
    public init(id: Int = .idGenerator(),
                areaID: Int,
                title: String,
                subtitle: String? = nil,
                content: String? = nil,
                beaconID: Int? = nil,
                priority: Int = 1,
                artworkIDs: [Int],
                audio: [NPGAudio]) {
        self.id = id
        self.areaID = areaID
        self.dateModified = .now
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.beaconID = beaconID
        self.priority = priority
        self.artworkIDs = artworkIDs
        self.audio = audio
    }
}

extension NPGArtwork {
    public init(id: Int = .idGenerator(),
                title: String,
                subtitle: String = "",
                dateCreated: String,
                accessionID: String? = nil,
                areaID: Int,
                locationID: Int? = nil,
                beaconID: Int? = nil,
                priority: Int = 1,
                size: CGSize = .zero,
                text: [NPGArtwork.LabelText] = [],
                images: [NPGImage] = [],
                nearbyArtworks: [NPGArtwork.Nearby] = [],
                audio: [NPGAudio] = [],
                video: [NPGVideo] = [],
                scanObjects: [NPG3DObject] = []) {
        self.id = id
        self.dateModified = .now
        self.title = title
        self.subtitle = subtitle
        self.dateCreated = dateCreated
        self.accessionID = accessionID
        self.areaID = areaID
        self.locationID = locationID
        self.beaconID = beaconID
        self.priority = priority
        self.width = size.width
        self.height = size.height
        self.text = text
        self.images = images
        self.nearbyArtworks = nearbyArtworks
        self.audio = audio
        self.video = video
        self.scanObjects = scanObjects
    }
    
    /// The size of the artwork in centimetres.
    public var size: CGSize {
        .init(width: width, height: height)
    }
}

extension NPGArtwork.LabelText {
    public init(type: NPGArtwork.LabelText.LabelType = .label,
                priority: Int = 1,
                content: String) {
        self.type = type
        self.content = content
        self.priority = priority
    }
}

extension NPGArtwork.Nearby {
    public init(relatedArtworkID: Int,
                relationship: NPGArtwork.Nearby.Relationship = .near) {
        self.id = relatedArtworkID
        self.relationship = relationship
    }
}

extension NPGImage {
    public init(id: Int = .idGenerator(),
                dateModified: Date = .now,
                scanningOnly: Bool = false,
                size: CGSize = .zero,
                subjectCrop: NPGImage.CropSize? = nil,
                faceCrops: [NPGImage.FaceCrop] = [],
                url: URL,
                thumbnailURL: URL? = nil,
                squareURL: URL? = nil) {
        self.id = id
        self.dateModified = dateModified
        self.scanningOnly = scanningOnly
        self.width = size.width
        self.height = size.height
        self.subjectCrop = subjectCrop
        self.faceCrops = faceCrops
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.squareURL = squareURL
    }
    
    public var size: CGSize {
        .init(width: width, height: height)
    }
}

extension NPGImage.FaceCrop {
    public init(entityID: Int, cropString: String) throws {
        self.entityID = entityID
        self.crop = try NPGImage.CropSize(string: cropString)
    }
}

extension NPGImage.CropSize {
    public static func defaultCrop() -> Self {
        .init(rect: .init(origin: .init(x: 50, y: 50), size: .init(width: 50, height: 50)))
    }
    
    public init(rect: CGRect, referenceSize: CGSize = .init(width: 100, height: 100)) {
        self.referenceWidth = referenceSize.width
        self.referenceHeight = referenceSize.height
        
        self.topLeftX = rect.origin.x / referenceWidth
        self.topLeftY = rect.origin.y / referenceHeight
        
        self.bottomRightX = (rect.origin.x + rect.size.width) / referenceWidth
        self.bottomRightY = (rect.origin.y + rect.size.height) / referenceHeight
    }
    
    /**
    Expects a comma-delimited string with 6 values, e.g. `560,742,0,0,559,559`.
     */
    internal init(string: String) throws {
        let parts = string.split(separator: ",").compactMap { Double($0) }
        guard parts.count == 6 else {
            throw(NPGError.invalidStringFormat(expectedFormat: "6 comma-delimited values, i.e. 560,742,0,0,559,559"))
        }
        
        if parts[0] > 0, parts[1] > 0 {
            self.referenceWidth = parts[0]
            self.referenceHeight = parts[1]
        } else {
            self.referenceWidth = 100
            self.referenceHeight = 100
        }
        
        self.topLeftX = parts[2] / referenceWidth
        self.topLeftY = parts[3] / referenceHeight
        
        self.bottomRightX = parts[4] / referenceWidth
        self.bottomRightY = parts[5] / referenceHeight
    }
    
    public var stringValue: String {
        "\(referenceSize.width),\(referenceSize.height),\(topLeft.x * referenceSize.width),\(topLeft.y * referenceSize.height),\(bottomRight.x * referenceSize.width),\(bottomRight.y * referenceSize.height)"
    }
    
    /**
     Reference size, if present, is the frame of reference that the ``topLeft`` and ``bottomRight`` points lie within.
     If reference size is equal to 0, topLeft and bottomRight should be considered percentage values of the total image size.
     
     - seealso: ``size(for:)``, ``rect(for:)``
     */
    public var referenceSize: CGSize {
        CGSize(width: referenceWidth, height: referenceHeight)
    }
    
    /**
     The upper-left coordinates of the crop.
     
     - seealso: ``referenceSize``
     */
    public var topLeft: CGPoint {
        CGPoint(x: topLeftX, y: topLeftY)
    }
    
    /**
     The lower-right coordinates of the crop.
     
     - seealso: ``referenceSize``
     */
    public var bottomRight: CGPoint {
        CGPoint(x: bottomRightX, y: bottomRightY)
    }
    
    /**
     Calculates a size for the crop, with the provided reference size providing a reference frame.
     If no reference size is provided, the internal reference size will be used.
     */
    public func size(for outputSize: CGSize) -> CGSize {
        let width = (bottomRight.x - topLeft.x) * outputSize.width
        let height = (bottomRight.y - topLeft.y) * outputSize.height
        
       
        return .init(width: width, height: height)
    }
    
    /**
     Calculates a CGRect for the crop based on the supplied reference size.
     If no reference size is provided, the internal reference size will be used.
     */
    public func rect(for outputSize: CGSize) -> CGRect {
        let size = size(for: outputSize)
        let origin = CGPoint(x: topLeft.x * outputSize.width, y: topLeft.y * outputSize.height)
        
        return .init(origin: origin, size: size)
    }
}

extension NPGAudio {
    public init(id: Int = .idGenerator(),
                priority: Int = 1,
                audioContext: NPGAudio.AudioContext = .audiodescription,
                title: String,
                duration: String,
                transcript: String,
                attribution: String? = nil,
                acknowledgements: String? = nil,
                url: URL) {
        self.id = id
        self.dateModified = .now
        self.priority = priority
        self.audioContext = audioContext
        self.title = title
        self.duration = duration
        self.transcript = transcript
        self.attribution = attribution
        self.acknowledgements = acknowledgements
        self.url = url
    }
}

extension NPGVideo {
    public init(id: Int = .idGenerator(),
                priority: Int = 1,
                videoContext: NPGVideo.VideoContext = .portraitstory,
                title: String,
                duration: String,
                size: CGSize,
                transcript: String,
                url: URL) {
        self.id = id
        self.dateModified = .now
        self.priority = priority
        self.videoContext = videoContext
        self.title = title
        self.duration = duration
        self.transcript = transcript
        self.url = url
        self.width = size.width
        self.height = size.height
    }
    
    public var size: CGSize {
        .init(width: width, height: height)
    }
}

extension NPG3DObject {
    public init(id: Int = .idGenerator(),
                url: URL) {
        self.id = id
        self.dateModified = .now
        self.url = url
    }
}

extension NPGEntity {
    public init(id: Int = .idGenerator(),
                displayName: String,
                simpleName: String? = nil,
                givenNames: [String]? = nil,
                familyNames: [String]? = nil,
                text: [NPGArtwork.LabelText] = [],
                audio: [NPGAudio] = [],
                artworkAsSubjectIDs: [Int] = [],
                artworkAsArtistIDs: [Int] = []) {
        self.id = id
        self.dateModified = .now
        self.displayName = displayName
        self.simpleName = simpleName
        self.givenNames = givenNames
        self.familyNames = familyNames
        self.text = text
        self.audio = audio
        self.artworkAsSubjectIDs = artworkAsSubjectIDs
        self.artworkAsArtistIDs = artworkAsArtistIDs
    }
}
