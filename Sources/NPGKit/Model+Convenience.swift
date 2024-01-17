import Foundation

extension NPGBool {
    init(bool: Bool) {
        self = bool ? .yes : .no
    }
    
    var bool: Bool {
        self == .yes
    }
}

extension NPGMetadata {
    static var empty = Self.init(title: "", subtitle: "", intro: "")
}

extension NPGArtwork {
    /// The size of the artwork in centimetres.
    public var size: CGSize {
        .init(width: width, height: height)
    }
}

extension NPGImage {
    public var size: CGSize {
        .init(width: width, height: height)
    }
}

extension NPGImage.CropSize {
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
            self.referenceWidth = nil
            self.referenceHeight = nil
        }
        
        self.topLeftX = parts[2]
        self.topLeftY = parts[3]
        
        self.bottomRightX = parts[4]
        self.bottomRightY = parts[5]
    }
    
    public var stringValue: String {
        "\(referenceSize.width),\(referenceSize.height),\(topLeft.x),\(topLeft.y),\(bottomRight.x),\(bottomRight.y)"
    }
    
    /**
     Reference size, if present, is the frame of reference that the ``topLeft`` and ``bottomRight`` points lie within.
     If reference size is equal to 0, topLeft and bottomRight should be considered percentage values of the total image size.
     
     - seealso: ``size(for:)``, ``rect(for:)``
     */
    public var referenceSize: CGSize {
        CGSize(width: referenceWidth ?? 0, height: referenceHeight ?? 0)
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
    public func size(for referenceSize: CGSize?) -> CGSize {
        let width: CGFloat
        let height: CGFloat
        
        if let suppliedRef = referenceSize {
            // Treat bottomRight, topLeft as percentages
            width = (bottomRight.x - topLeft.x) * suppliedRef.width
            height = (bottomRight.y - topLeft.y) * suppliedRef.height
            
        } else if self.referenceWidth == 0, self.referenceHeight == 0 {
            width = 0
            height = 0
            
        } else {
            width = bottomRight.x - topLeft.x
            height = bottomRight.y - topLeft.y
        }
        return .init(width: width, height: height)
    }
    
    /**
     Calculates a CGRect for the crop based on the supplied reference size.
     If no reference size is provided, the internal reference size will be used.
     */
    public func rect(for referenceSize: CGSize?) -> CGRect {
        let size = size(for: referenceSize)
        let origin: CGPoint
        
        if let suppliedRef = referenceSize {
            // Treat topLeft as percentages
            origin = .init(x: topLeft.x * suppliedRef.width, y: topLeft.x * suppliedRef.height)
        } else {
            origin = topLeft
        }
        
        return .init(origin: origin, size: size)
    }
}
