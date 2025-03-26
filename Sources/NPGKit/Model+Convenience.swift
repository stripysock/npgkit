import Foundation
import SwiftUI

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
    internal init(rect: CGRect) {
        self.referenceWidth = 100
        self.referenceHeight = 100
        
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
