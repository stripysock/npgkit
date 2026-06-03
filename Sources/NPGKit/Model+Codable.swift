import Foundation

extension NPGData {
    enum CodingKeys: String, CodingKey {
        case areas, locations, boundaries, beacons, tours
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
        case adjacentAreas = "adjacentareas"
    }
}

extension NPGArea.AdjacentArea {
    enum CodingKeys: String, CodingKey {
        case areaID = "areaid"
        case direction
    }
}

extension NPGArea.AdjacentLocation {
    enum CodingKeys: String, CodingKey {
        case locationID = "locationid"
        case direction
    }
}

extension NPGArea.Location {
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, priority, audio
        case dateModified = "datemodified"
        case areaID = "areaid"
        case artworkIDs = "labels"
        case boundaryIDs = "boundaries"
        case beaconID = "beaconid"
        case adjacentLocations = "adjacentlocations"
    }
}

extension NPGArea.Boundary {
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, content, priority, width, height, orientation
        case dateAdded = "dateadded"
        case dateModified = "datemodified"
        case locationID = "locationid"
        case leftBoundaryID = "leftboundaryid"
        case rightBoundaryID = "rightboundaryid"
        case positionX = "positionx"
        case positionY = "positiony"
        case artworkIDs = "labels"
        case type = "boundarytype"
        case doorwayLocationID = "doorwaylocationid"
        case doorwayPriority = "doorwaypriority"
        case relativeX = "relativex"
        case relativeY = "relativey"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.locationID = try container.decode(Int.self, forKey: .locationID)
        self.leftBoundaryID = try container.decodeIfPresent(Int.self, forKey: .leftBoundaryID)
        self.rightBoundaryID = try container.decodeIfPresent(Int.self, forKey: .rightBoundaryID)
        self.dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        self.dateModified = try container.decode(Date.self, forKey: .dateModified)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.orientation = try container.decode(NPGArea.Orientation.self, forKey: .orientation)
        self.priority = try container.decode(Int.self, forKey: .priority)
        self.artworkIDs = try container.decodeIfPresent([Int].self, forKey: .artworkIDs) ?? []

        if let widthDouble = try? container.decode(Double.self, forKey: .width) {
            self.width = widthDouble
        } else {
            let widthString = try container.decode(String.self, forKey: .width)
            guard let widthDouble = Double(widthString) else {
                let context = DecodingError.Context(codingPath: [CodingKeys.width], debugDescription: "Expected double.")
                throw DecodingError.typeMismatch(String.self, context)
            }
            self.width = widthDouble
        }

        if let heightDouble = try? container.decode(Double.self, forKey: .height) {
            self.height = heightDouble
        } else {
            let heightString = try container.decode(String.self, forKey: .height)
            guard let heightDouble = Double(heightString) else {
                let context = DecodingError.Context(codingPath: [CodingKeys.height], debugDescription: "Expected double.")
                throw DecodingError.typeMismatch(String.self, context)
            }
            self.height = heightDouble
        }

        self.positionX = (try? container.decodeIfPresent(Double.self, forKey: .positionX)) ?? 0
        self.positionY = (try? container.decodeIfPresent(Double.self, forKey: .positionY)) ?? 0

        let typeString = try container.decode(String.self, forKey: .type)
        switch typeString {
        case "wall":
            self.boundaryType = .wall
        case "islandwall", "island wall":
            let relativeX = try container.decode(Int.self, forKey: .relativeX)
            let relativeY = try container.decode(Int.self, forKey: .relativeY)
            self.boundaryType = .islandWall(relativeX: relativeX, relativeY: relativeY)
        case "doorway":
            let toOtherLocationID = try container.decodeIfPresent(Int.self, forKey: .doorwayLocationID)
            let doorwayPriority = (try? container.decodeIfPresent(NPGArea.Boundary.Priority.self, forKey: .doorwayPriority)) ?? .primary
            self.boundaryType = .doorway(toOtherLocationID: toOtherLocationID, priority: doorwayPriority)
        case "closed doorway":
            self.boundaryType = .doorway(toOtherLocationID: nil)
        case "overlap":
            self.boundaryType = .overlap
        default:
            let context = DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "Unknown boundary type: \(typeString)")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.id, forKey: .id)
        try container.encode(self.locationID, forKey: .locationID)
        try container.encodeIfPresent(self.leftBoundaryID, forKey: .leftBoundaryID)
        try container.encodeIfPresent(self.rightBoundaryID, forKey: .rightBoundaryID)
        try container.encode(self.dateAdded, forKey: .dateAdded)
        try container.encode(self.dateModified, forKey: .dateModified)
        try container.encode(self.title, forKey: .title)
        try container.encodeIfPresent(self.subtitle, forKey: .subtitle)
        try container.encodeIfPresent(self.content, forKey: .content)
        try container.encode(self.width, forKey: .width)
        try container.encode(self.height, forKey: .height)
        try container.encode(self.positionX, forKey: .positionX)
        try container.encode(self.positionY, forKey: .positionY)
        try container.encode(self.orientation, forKey: .orientation)
        try container.encode(self.priority, forKey: .priority)
        try container.encode(self.artworkIDs, forKey: .artworkIDs)

        switch self.boundaryType {
        case .wall:
            try container.encode("wall", forKey: .type)
        case .islandWall(let relativeX, let relativeY):
            try container.encode("islandwall", forKey: .type)
            try container.encode(relativeX, forKey: .relativeX)
            try container.encode(relativeY, forKey: .relativeY)
        case .doorway(let toOtherLocationID, let priority):
            try container.encode("doorway", forKey: .type)
            try container.encodeIfPresent(toOtherLocationID, forKey: .doorwayLocationID)
            try container.encodeIfPresent(priority, forKey: .doorwayPriority)
        case .overlap:
            try container.encode("overlap", forKey: .type)
        }
    }
}

extension NPGArtwork {
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, priority, width, height, text, images, audio, video, media
        case dateModified = "datemodified"
        case dateCreated = "datecreated"
        case areaID = "areaid"
        case accessionID = "accessionnumber"
        case locationID = "locationid"
        case boundaryID = "boundaryid"
        case positionX = "positionx"
        case positionY = "positiony"
        case nearbyArtworks = "nearbylabels"
        case scanObjects = "3dscan"
        case beaconID = "beaconid"
        case excludeFromApplications = "excludeFrom"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.dateModified = try container.decode(Date.self, forKey: .dateModified)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        self.dateCreated = try container.decode(String.self, forKey: .dateCreated)
        self.accessionID = try container.decodeIfPresent(String.self, forKey: .accessionID)
        self.areaID = try container.decode(Int.self, forKey: .areaID)
        self.locationID = try container.decodeIfPresent(Int.self, forKey: .locationID)
        self.boundaryID = try container.decodeIfPresent(Int.self, forKey: .boundaryID)
        self.beaconID = try container.decodeIfPresent(Int.self, forKey: .beaconID)
        self.priority = try container.decode(Int.self, forKey: .priority)

        if let widthDouble = try? container.decode(Double.self, forKey: .width) {
            self.width = widthDouble
        } else {
            let widthString = try container.decode(String.self, forKey: .width)
            guard let widthDouble = Double(widthString) else {
                let context = DecodingError.Context(codingPath: [CodingKeys.width], debugDescription: "Expected double.")
                throw DecodingError.typeMismatch(String.self, context)
            }
            self.width = widthDouble
        }

        if let heightDouble = try? container.decode(Double.self, forKey: .height) {
            self.height = heightDouble
        } else {
            let heightString = try container.decode(String.self, forKey: .height)
            guard let heightDouble = Double(heightString) else {
                let context = DecodingError.Context(codingPath: [CodingKeys.height], debugDescription: "Expected double.")
                throw DecodingError.typeMismatch(String.self, context)
            }
            self.height = heightDouble
        }
        
        if let positionXDouble = try? container.decode(Double.self, forKey: .positionX) {
            self.positionX = positionXDouble
        } else {
            let positionXString = try container.decode(String.self, forKey: .positionX)
            guard let positionXDouble = Double(positionXString) else {
                let context = DecodingError.Context(codingPath: [CodingKeys.positionX], debugDescription: "Expected double.")
                throw DecodingError.typeMismatch(String.self, context)
            }
            self.positionX = positionXDouble
        }
        
        if let positionYDouble = try? container.decode(Double.self, forKey: .positionY) {
            self.positionY = positionYDouble
        } else {
            let positionYString = try container.decode(String.self, forKey: .positionY)
            guard let positionYDouble = Double(positionYString) else {
                let context = DecodingError.Context(codingPath: [CodingKeys.positionY], debugDescription: "Expected double.")
                throw DecodingError.typeMismatch(String.self, context)
            }
            self.positionY = positionYDouble
        }

        self.text = try container.decodeIfPresent([LabelText].self, forKey: .text) ?? []
        self.images = try container.decodeIfPresent([NPGImage].self, forKey: .images) ?? []
        self.nearbyArtworks = try container.decodeIfPresent([Nearby].self, forKey: .nearbyArtworks) ?? []
        self.audio = try container.decodeIfPresent([NPGAudio].self, forKey: .audio) ?? []
        self.video = try container.decodeIfPresent([NPGVideo].self, forKey: .video) ?? []
        self.scanObjects = try container.decodeIfPresent([NPG3DObject].self, forKey: .scanObjects) ?? []
        self.excludeFromApplications = try container.decodeIfPresent([NPGApplication].self, forKey: .excludeFromApplications) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.id, forKey: .id)
        try container.encode(self.dateModified, forKey: .dateModified)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.subtitle, forKey: .subtitle)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.accessionID, forKey: .accessionID)
        try container.encode(self.areaID, forKey: .areaID)
        try container.encodeIfPresent(self.locationID, forKey: .locationID)
        try container.encodeIfPresent(self.boundaryID, forKey: .boundaryID)
        try container.encodeIfPresent(self.beaconID, forKey: .beaconID)
        try container.encode(self.priority, forKey: .priority)
        try container.encode(self.width, forKey: .width)
        try container.encode(self.height, forKey: .height)
        try container.encode(self.positionX, forKey: .positionX)
        try container.encode(self.positionY, forKey: .positionY)
        try container.encode(self.text, forKey: .text)
        try container.encode(self.images, forKey: .images)
        try container.encode(self.nearbyArtworks, forKey: .nearbyArtworks)
        try container.encode(self.audio, forKey: .audio)
        try container.encode(self.video, forKey: .video)
        try container.encode(self.scanObjects, forKey: .scanObjects)
        try container.encode(self.excludeFromApplications, forKey: .excludeFromApplications)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.dateModified = try container.decode(Date.self, forKey: .dateModified)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        self.dateCreated = try container.decode(String.self, forKey: .dateCreated)
        self.accessionID = try container.decodeIfPresent(String.self, forKey: .accessionID)
        self.areaID = try container.decode(Int.self, forKey: .areaID)
        self.locationID = try container.decodeIfPresent(Int.self, forKey: .locationID)
        self.beaconID = try container.decodeIfPresent(Int.self, forKey: .beaconID)
        self.priority = try container.decode(Int.self, forKey: .priority)
        self.width = try container.decode(Double.self, forKey: .width)
        self.height = try container.decode(Double.self, forKey: .height)
        self.text = try container.decode([LabelText].self, forKey: .text)
        self.images = try container.decode([NPGImage].self, forKey: .images)
        self.nearbyArtworks = try container.decode([Nearby].self, forKey: .nearbyArtworks)
        self.audio = try container.decode([NPGAudio].self, forKey: .audio)
        self.video = try container.decode([NPGVideo].self, forKey: .video)
        self.scanObjects = try container.decode([NPG3DObject].self, forKey: .scanObjects)

        // If the media value is missing or doesn't match a known ``MediaType``, treat it as nil rather than failing to decode the entire artwork.
        self.media = try? container.decodeIfPresent(MediaType.self, forKey: .media)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.id, forKey: .id)
        try container.encode(self.dateModified, forKey: .dateModified)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.subtitle, forKey: .subtitle)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.accessionID, forKey: .accessionID)
        try container.encode(self.areaID, forKey: .areaID)
        try container.encodeIfPresent(self.locationID, forKey: .locationID)
        try container.encodeIfPresent(self.beaconID, forKey: .beaconID)
        try container.encode(self.priority, forKey: .priority)
        try container.encode(self.width, forKey: .width)
        try container.encode(self.height, forKey: .height)
        try container.encode(self.text, forKey: .text)
        try container.encode(self.images, forKey: .images)
        try container.encode(self.nearbyArtworks, forKey: .nearbyArtworks)
        try container.encode(self.audio, forKey: .audio)
        try container.encode(self.video, forKey: .video)
        try container.encode(self.scanObjects, forKey: .scanObjects)
        try container.encodeIfPresent(self.media, forKey: .media)
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
        case id, priority, title, duration, transcript, attribution, acknowledgements, performer
        case dateModified = "datemodified"
        case audioContext = "type"
        case url = "fileURL"
        case prefersAutoplay = "prefersAutoPlay"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.dateModified = try container.decode(Date.self, forKey: .dateModified)
        let priority = try container.decodeIfPresent(Int.self, forKey: .priority)
        self.priority = priority ?? 1
        
        self.audioContext = try container.decode(NPGAudio.AudioContext.self, forKey: .audioContext)
        self.title = try container.decode(String.self, forKey: .title)
        self.duration = try container.decode(String.self, forKey: .duration)
        self.transcript = try container.decode(String.self, forKey: .transcript)
        self.attribution = try container.decodeIfPresent(String.self, forKey: .attribution)
        self.acknowledgements = try container.decodeIfPresent(String.self, forKey: .acknowledgements)
        self.url = try container.decode(URL.self, forKey: .url)
        self.performer = try container.decodeIfPresent(String.self, forKey: .performer)
        
        let prefersAutoplay = try container.decodeIfPresent(NPGBool.self, forKey: .prefersAutoplay)
        self.prefersAutoplay = prefersAutoplay?.bool ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.dateModified, forKey: .dateModified)
        try container.encode(self.priority, forKey: .priority)
        try container.encode(self.audioContext, forKey: .audioContext)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.duration, forKey: .duration)
        try container.encode(self.transcript, forKey: .transcript)
        try container.encode(self.attribution, forKey: .attribution)
        try container.encode(self.acknowledgements, forKey: .acknowledgements)
        try container.encode(self.url, forKey: .url)
        try container.encode(NPGBool(bool: self.prefersAutoplay), forKey: .prefersAutoplay)
        try container.encodeIfPresent(self.performer, forKey: .performer)
        
    }
}

extension NPGVideo {
    enum CodingKeys: String, CodingKey {
        case id, priority, title, duration, transcript, width, height
        case dateModified = "datemodified"
        case videoContext = "type"
        case url = "fileURL"
        case webVTT = "webvttURL"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.priority = try container.decode(Int.self, forKey: .priority)
        self.title = try container.decode(String.self, forKey: .title)
        self.duration = (try? container.decode(String.self, forKey: .duration)) ?? ""
        self.transcript = try container.decode(String.self, forKey: .transcript)
        self.dateModified = try container.decode(Date.self, forKey: .dateModified)
        self.videoContext = try container.decode(VideoContext.self, forKey: .videoContext)
        self.url = try container.decode(URL.self, forKey: .url)
        self.webVTT = try? container.decodeIfPresent(URL.self, forKey: .webVTT)
        
        
        if let widthVal = try? container.decode(Double.self, forKey: .width) {
            self.width = widthVal
        } else {
            let widthString = try container.decode(String.self, forKey: .width)
            self.width = Double(widthString) ?? 0
        }
        
        if let heightVal = try? container.decode(Double.self, forKey: .height) {
            self.height = heightVal
        } else {
            let heightString = try container.decode(String.self, forKey: .height)
            self.height = Double(heightString) ?? 0
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.priority, forKey: .priority)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.duration, forKey: .duration)
        try container.encode(self.transcript, forKey: .transcript)
        try container.encode(self.dateModified, forKey: .dateModified)
        try container.encode(self.videoContext, forKey: .videoContext)
        try container.encode(self.url, forKey: .url)
        try container.encodeIfPresent(self.webVTT, forKey: .webVTT)
        try container.encode(self.width, forKey: .width)
        try container.encode(self.height, forKey: .height)
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
