//
//  GraphicsControlExtension.swift
//  GIFMetadata
//
//  Created by koyachi on 2017/06/04.
//
//

import Foundation

public struct GraphicsControlExtension {
    let disposalMethod: UInt8
    let userInputFlag: Bool
    let transparentColorFlag: Bool
    let delayTime: UInt8
    let transparentColorIndex: UInt8
}

extension GraphicsControlExtension: CustomStringConvertible {

    public var description: String {
        return [
            "<\(String(describing: type(of: self)))",
            "disposalMethod: \(disposalMethod)",
            "userInputFlag: \(userInputFlag)",
            "transparentColorFlag: \(transparentColorFlag)",
            "delayTime: \(delayTime)",
            "transparentColorIndex: \(transparentColorIndex)",
            ">",
            ].joined(separator: "\n  ")
    }
}

