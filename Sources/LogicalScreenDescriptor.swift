//
//  LogicalScreenDescriptor.swift
//  GIFMetadata
//
//  Created by koyachi on 2017/06/04.
//
//

import Foundation

public struct LogicalScreenDescriptor {
    let width: UInt16
    let height: UInt16
    let globalColorTableFlag: Bool
    let colorResolution: UInt8
    let sortFlag: Bool
    let sizeOfGlobalColorTable: UInt8
    let backgroundColorIndex: UInt8
    let pixelAspectRatio: UInt8
}

extension LogicalScreenDescriptor: CustomStringConvertible {

    public var description: String {
        return [
            "<\(String(describing: type(of: self)))",
            "width: \(width)",
            "height: \(height)",
            "globalColorTableFlag: \(globalColorTableFlag)",
            "colorResolution: \(colorResolution)",
            "sortFlag: \(sortFlag)",
            "sizeOfGlobalColorTable: \(sizeOfGlobalColorTable)",
            "backgroundColorIndex: \(backgroundColorIndex)",
            "pixelAspectRatio: \(pixelAspectRatio)",
            ">",
            ].joined(separator: "\n  ")
    }
}

