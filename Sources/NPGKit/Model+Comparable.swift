import Foundation

extension NPGTour: Comparable {
    public static func < (lhs: NPGTour, rhs: NPGTour) -> Bool {
        lhs.priority < rhs.priority
    }
}

extension NPGTour.TourStop: Comparable {
    public static func < (lhs: NPGTour.TourStop, rhs: NPGTour.TourStop) -> Bool {
        lhs.priority < rhs.priority
    }
}

extension NPGArea: Comparable {
    public static func < (lhs: NPGArea, rhs: NPGArea) -> Bool {
        lhs.priority < rhs.priority
    }
}

extension NPGArea.Location: Comparable {
    public static func < (lhs: NPGArea.Location, rhs: NPGArea.Location) -> Bool {
        lhs.priority < rhs.priority
    }
}

extension NPGArtwork: Comparable {
    public static func < (lhs: NPGArtwork, rhs: NPGArtwork) -> Bool {
        lhs.priority < rhs.priority
    }
}

extension NPGArtwork.LabelText: Comparable {
    public static func < (lhs: NPGArtwork.LabelText, rhs: NPGArtwork.LabelText) -> Bool {
        lhs.priority < rhs.priority
    }
}

extension NPGAudio: Comparable {
    public static func < (lhs: NPGAudio, rhs: NPGAudio) -> Bool {
        if lhs.audioContext != rhs.audioContext {
            return lhs.audioContext < rhs.audioContext
        }
        return lhs.title < rhs.title
    }
}

extension NPGEntity: Comparable {
    public static func < (lhs: NPGEntity, rhs: NPGEntity) -> Bool {
        let lhsCompare = lhs.familyNames?.joined(separator: " ") ?? lhs.simpleName ?? lhs.displayName
        let rhsCompare = rhs.familyNames?.joined(separator: " ") ?? rhs.simpleName ?? rhs.displayName
        
        return lhsCompare < rhsCompare
    }
}
