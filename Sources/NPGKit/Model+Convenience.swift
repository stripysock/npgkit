import Foundation

extension NPGBool {
    init(bool: Bool) {
        self = bool ? .yes : .no
    }
    
    var bool: Bool {
        self == .yes
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
        
        self.width = parts[0]
        self.height = parts[1]
        self.cropTopLeftX = parts[2]
        self.cropTopLeftY = parts[3]
        self.cropBottomRightX = parts[4]
        self.cropBottomRightY = parts[5]
    }
    
    var stringValue: String {
        "\(width),\(height),\(cropTopLeftX),\(cropTopLeftY),\(cropBottomRightX),\(cropBottomRightY)"
    }
    
    public var size: CGSize {
        .init(width: width, height: height)
    }
    
    public var topLeft: CGPoint {
        .init(x: cropTopLeftX, y: cropTopLeftY)
    }
    
    public var bottomRight: CGPoint {
        .init(x: cropBottomRightX, y: cropBottomRightY)
    }
}
