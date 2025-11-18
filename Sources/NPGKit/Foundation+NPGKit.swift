//
//  Foundation+NPGKit.swift
//  NPGKit
//
//  Created by Adam Cooper on 18/11/2025.
//

import Foundation

public extension JSONDecoder {
    static var npgKit: JSONDecoder {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let defaultDecoder = JSONDecoder()
        defaultDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return defaultDecoder
    }
}

public extension JSONEncoder {
    static var npgKit: JSONEncoder {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let defaultEncoder = JSONEncoder()
        defaultEncoder.dateEncodingStrategy = .formatted(dateFormatter)
        return defaultEncoder
    }
}
