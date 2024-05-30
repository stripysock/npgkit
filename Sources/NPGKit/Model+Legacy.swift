import Foundation

/**
 Legacy support for old attributes
*/
extension NPGArea {
    /// A beacon identifier associated with this area.
    @available(*, deprecated, renamed: "beaconIDs", message: "Use beaconIDs instead.")
    public var beaconID: Int? {
        self.beaconIDs.first
    }
    
    @available(*, deprecated, renamed: "beaconID", message: "Use beaconIDs instead.")
    public var beacon: String? {
        guard let beaconID = beaconID else {
            return nil
        }
        return "\(beaconID)"
    }
    
    @available(*, deprecated, renamed: "artworkIDs", message: "Use artworkIDs instead.")
    public var labelIDs: [Int] {
        return artworkIDs
    }
}

@available(swift, deprecated: 1.0.2, renamed: "NPGArea.Location")
typealias NPGLocation = NPGArea.Location

extension NPGArea.Location {
    @available(swift, deprecated: 1.0, renamed: "beaconID")
    public var beacon: String? {
        guard let beaconID = beaconID else {
            return nil
        }
        return "\(beaconID)"
    }
    
    @available(swift, deprecated: 1.0.8, renamed: "artworkIDs")
    public var labelIDs: [Int] {
        return artworkIDs
    }
}

extension NPGArtwork {
    @available(swift, deprecated: 1.0, renamed: "beaconID")
    public var beacon: String? {
        guard let beaconID = beaconID else {
            return nil
        }
        return "\(beaconID)"
    }
}

extension NPGImage.CropSize {
    @available(swift, deprecated: 1.1.4, renamed: "referenceSize")
    public var width: Double {
        return referenceSize.width
    }
    
    @available(swift, deprecated: 1.1.4, renamed: "referenceSize")
    public var height: Double {
        referenceSize.height
    }
    
    @available(swift, deprecated: 1.1.4, renamed: "size(for:)")
    public var size: CGSize {
        return size(for: referenceSize)
    }
    
    @available(swift, deprecated: 1.1.4, renamed: "topLeft")
    public var cropTopLeftX: Double {
        topLeftX
    }
    
    @available(swift, deprecated: 1.1.4, renamed: "topLeft")
    public var cropTopLeftY: Double {
        topLeftY
    }
    
    @available(swift, deprecated: 1.1.4, renamed: "bottomRight")
    public var cropBottomRightX: Double {
        bottomRightX
    }
    
    @available(swift, deprecated: 1.1.4, renamed: "bottomRight")
    public var cropBottomRightY: Double {
        bottomRightY
    }
}

extension NPGTour.TourStop {
    @available(swift, deprecated: 1.0.8, renamed: "artworkIDs")
    public var labelIDs: [Int] {
        return artworkIDs
    }
}
