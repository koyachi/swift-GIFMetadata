//
//  ImageDescriptor.swift
//  GIFMetadata
//
//  Created by koyachi on 2017/06/04.
//
//

import Foundation

public struct ImageDescriptor {
    let imageLeft: UInt16
    let imageTop: UInt16
    let imageWidth: UInt16
    let imageHeight: UInt16
    let localColorTabelFlag: Bool
    let interlaceFlag: Bool
    let sortFlag: Bool
    let sizeOfLocalColorTable: UInt8
}

extension ImageDescriptor: CustomStringConvertible {

    public var description: String {
        return [
            "<\(String(describing: type(of: self)))",
            "imageLeft: \(imageLeft)",
            "imageTop: \(imageTop)",
            "imageWidth: \(imageWidth)",
            "imageHeight: \(imageHeight)",
            "localColorTableFlag: \(localColorTabelFlag)",
            "interlaceFlag: \(interlaceFlag)",
            "sortFlag: \(sortFlag)",
            "sizeOfLocalColorTable: \(sizeOfLocalColorTable)",
            ">",
            ].joined(separator: "\n  ")
    }
}

