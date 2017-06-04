//
//  ApplicationExtension.swift
//  GIFMetadata
//
//  Created by koyachi on 2017/06/04.
//
//

import Foundation

public enum ApplicationExtension {
    case netscapeLooping(loopCount: UInt16)
}

extension ApplicationExtension: CustomStringConvertible{

    public var description: String {
        var loopCount: UInt16 = 0
        switch self {
        case .netscapeLooping(let lc):
            loopCount = lc
        default:
            break
        }
        return [
            "<\(String(describing: type(of: self)))",
            "netscapLooping.loopCount: \(loopCount)",
            ">",
            ].joined(separator: "\n  ")
    }
}
