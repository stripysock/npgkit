import Foundation

extension NPGObject {
    internal static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
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
        case id, title, subtitle, beacon, priority
        case dateModified = "datemodified"
        case locationIDs = "locations"
        case labelIDs = "labels"
    }
}

extension NPGLocation {
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, beacon, priority, audio
        case dateModified = "datemodified"
        case areaID = "areaid"
        case labelIDs = "labels"
    }
}

extension NPGArtwork {
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, beacon, priority, width, height, text, images, audio
        case dateModified = "datemodified"
        case dateCreated = "datecreated"
        case areaID = "areaid"
        case locationID = "locationid"
        case nearbyArtworks = "nearbylabels"
        case scanObjects = "3dscan"
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
        case url = "largeURL"
        case thumbnailURL = "smallURL"
        case squareURL
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.dateModified = try container.decode(Date.self, forKey: .dateModified)
        
        let scanningOnly = try container.decode(NPGBool.self, forKey: .scanningOnly)
        self.scanningOnly = scanningOnly.bool
        
        self.width = try container.decode(Double.self, forKey: .width)
        self.height = try container.decode(Double.self, forKey: .height)
        
        if let cropString = try container.decodeIfPresent(String.self, forKey: .subjectCrop) {
            self.subjectCrop = try CropSize(string: cropString)
        } else {
            self.subjectCrop = nil
        }
        
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
        try container.encode(self.url, forKey: .url)
        try container.encodeIfPresent(self.thumbnailURL, forKey: .thumbnailURL)
        try container.encodeIfPresent(self.squareURL, forKey: .squareURL)
    }
}

extension NPGAudio {
    enum CodingKeys: String, CodingKey {
        case id
        case dateModified = "datemodified"
        case audioContext = "type"
        case title
        case duration
        case transcript
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
