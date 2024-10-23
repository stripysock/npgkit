import Foundation

extension NPGObject {
    internal static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
}

extension NPGData {
    enum CodingKeys: String, CodingKey {
        case areas, locations, beacons, tours
        case artworks = "labels"
        case entities = "people"
        case metadata = "title"
    }
}

extension NPGTour {
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, priority, audio
        case dateModified = "datemodified"
        case beaconID = "beaconid"
        case tourStops = "tourstops"
    }
}

extension NPGTour.TourStop {
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, content, priority, audio
        case dateModified = "datemodified"
        case beaconID = "beaconid"
        case artworkIDs = "labels"
    }
}

extension NPGBeacon {
    enum CodingKeys: String, CodingKey {
        case id, title, major, minor
        case proximityUUID = "uuid"
        case dateModified = "datemodified"
        case areaIDs = "areas"
        case locationIDs = "locations"
        case artworkIDs = "labels"
    }
}

extension NPGArea {
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, priority
        case dateModified = "datemodified"
        case locationIDs = "locations"
        case artworkIDs = "labels"
        case beaconIDs = "beaconids"
        case externalCoordinates = "gpscoordinates"
    }
}

extension NPGArea.Location {
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, priority, audio
        case dateModified = "datemodified"
        case areaID = "areaid"
        case artworkIDs = "labels"
        case beaconID = "beaconid"
    }
}

extension NPGArtwork {
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, priority, width, height, text, images, audio
        case dateModified = "datemodified"
        case dateCreated = "datecreated"
        case areaID = "areaid"
        case locationID = "locationid"
        case nearbyArtworks = "nearbylabels"
        case scanObjects = "3dscan"
        case beaconID = "beaconid"
    }
}

extension NPGImage: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case dateModified = "datemodified"
        case scanningOnly = "scanningonly"
        case width
        case height
        case subjectCrop = "cropsquare"
        case faceCrops = "faces"
        case url = "fileURL"
        case thumbnailURL = "thickURL"
        case squareURL = "doublesquareURL"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.dateModified = try container.decode(Date.self, forKey: .dateModified)
        
        let scanningOnly = try container.decode(NPGBool.self, forKey: .scanningOnly)
        self.scanningOnly = scanningOnly.bool
        
        if let widthDouble = try? container.decode(Double.self, forKey: .width) {
            self.width = widthDouble
        } else {
            let widthString = try container.decode(String.self, forKey: .width)
            guard let widthDouble = Double(widthString) else {
                let context = DecodingError.Context(codingPath: [CodingKeys.width], debugDescription: "Expected double.")
                throw(DecodingError.typeMismatch(String.self, context))
            }
            self.width = widthDouble
        }
        
        if let heightDouble = try? container.decode(Double.self, forKey: .height) {
            self.height = heightDouble
        } else {
            let heightString = try container.decode(String.self, forKey: .height)
            guard let heightDouble = Double(heightString) else {
                let context = DecodingError.Context(codingPath: [CodingKeys.height], debugDescription: "Expected double.")
                throw(DecodingError.typeMismatch(String.self, context))
            }
            self.height = heightDouble
        }
        
        if let cropString = try container.decodeIfPresent(String.self, forKey: .subjectCrop) {
            self.subjectCrop = try CropSize(string: cropString)
        } else {
            self.subjectCrop = nil
        }
        self.faceCrops = try container.decodeIfPresent([FaceCrop].self, forKey: .faceCrops) ?? []
        
        self.url = try container.decode(URL.self, forKey: .url)
        self.thumbnailURL = try container.decodeIfPresent(URL.self, forKey: .thumbnailURL)
        self.squareURL = try container.decodeIfPresent(URL.self, forKey: .squareURL)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.dateModified, forKey: .dateModified)
        try container.encode(NPGBool(bool: self.scanningOnly), forKey: .scanningOnly)
        try container.encode(self.width, forKey: .width)
        try container.encode(self.height, forKey: .height)
        try container.encodeIfPresent(self.subjectCrop?.stringValue, forKey: .subjectCrop)
        try container.encodeIfPresent(self.faceCrops, forKey: .faceCrops)
        try container.encode(self.url, forKey: .url)
        try container.encodeIfPresent(self.thumbnailURL, forKey: .thumbnailURL)
        try container.encodeIfPresent(self.squareURL, forKey: .squareURL)
    }
}

extension NPGImage.FaceCrop: Codable {
    enum CodingKeys: String, CodingKey {
        case entityID = "peopleid"
        case left
        case top
        case width
        case height
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.entityID = try container.decode(Int.self, forKey: .entityID)
        
        let left = try container.decode(Double.self, forKey: .left)
        let top = try container.decode(Double.self, forKey: .top)
        let width = try container.decode(Double.self, forKey: .width)
        let height = try container.decode(Double.self, forKey: .height)
        
        let cropSize = NPGImage.CropSize(rect: .init(origin: .init(x: left, y: top), size: .init(width: width, height: height)))
        
        self.crop = cropSize
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let rect = self.crop.rect(for: .init(width: 100, height: 100))
        
        try container.encode(self.entityID, forKey: .entityID)
        try container.encode(rect.origin.x, forKey: .left)
        try container.encode(rect.origin.y, forKey: .top)
        try container.encode(rect.size.width, forKey: .width)
        try container.encode(rect.size.height, forKey: .height)
    }
}

extension NPGAudio {
    enum CodingKeys: String, CodingKey {
        case id, priority, title, duration, transcript, attribution, acknowledgements
        case dateModified = "datemodified"
        case audioContext = "type"
        case url = "fileURL"
    }
}

extension NPG3DObject {
    enum CodingKeys: String, CodingKey {
        case id
        case dateModified = "datemodified"
        case url = "fileURL"
    }
}

extension NPGEntity {
    enum CodingKeys: String, CodingKey {
        case id, text, audio
        case dateModified = "datemodified"
        case displayName = "displayname"
        case simpleName = "simplename"
        case givenNames = "givennames"
        case familyNames = "familynames"
        case artworkAsSubjectIDs = "subjectlabels"
        case artworkAsArtistIDs = "artistlabels"
    }
}
