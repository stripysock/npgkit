import Foundation

/**
 Legacy support for old attributes
*/
extension NPGArea {
    @available(swift, deprecated: 1.0, renamed: "beaconID")
    var beacon: String? {
        guard let beaconID = beaconID else {
            return nil
        }
        return "\(beaconID)"
    }
}

@available(swift, deprecated: 1.0.2, renamed: "NPGArea.Location")
typealias NPGLocation = NPGArea.Location

extension NPGArea.Location {
    @available(swift, deprecated: 1.0, renamed: "beaconID")
    var beacon: String? {
        guard let beaconID = beaconID else {
            return nil
        }
        return "\(beaconID)"
    }
}

extension NPGArtwork {
    @available(swift, deprecated: 1.0, renamed: "beaconID")
    var beacon: String? {
        guard let beaconID = beaconID else {
            return nil
        }
        return "\(beaconID)"
    }
}