// Related:
// - https://github.com/voidless/Animated-GIF-iPhone
// - https://github.com/drewnoakes/metadata-extractor/blob/master/Source/com/drew/metadata/gif/GifReader.java

import Foundation

public class GIFMetadata {

    public var logicalScreenDescriptor: LogicalScreenDescriptor?
    public var applicationExtensions: [ApplicationExtension] = []
    public var imageDescriptors: [ImageDescriptor] = []
    public var imageDataCount: Int = 0

    private var data: Data?
    private var pointerIndex: Int? /*{
     didSet {
     print("pointerIndex = \(String(format: "%08x", pointerIndex!))")
     }
     }*/
    private var globalColorTableSize: Int?

    public func preferredLoopCount() -> Int {
        if applicationExtensions.count == 0 && imageDescriptors.count > 0 {
            return 1
        } else {
            for appExt in applicationExtensions {
                switch appExt {
                case .netscapeLooping(let lc):
                    return Int(lc)
                }
            }
        }
        return 0
    }

    public init(_ data: Data) {
        self.data = data
        pointerIndex = 0
        readHeader()
        logicalScreenDescriptor = readLogicalScreenDescriptor()
        readGlobalColorTable()
        readBody()
    }

    func readHeader() {
        //print("\(#function)")
        skipBytes(6)
    }

    func readLogicalScreenDescriptor() -> LogicalScreenDescriptor {
        //print("\(#function)")
        let width = readBytes(2)
        pointerIndex? += 2
        let height = readBytes(2)
        pointerIndex? += 2

        let packedField = readByte()
        pointerIndex? += 1
        let globalColorTableFlag: Bool = packedField & 0x80 == 0x80
        let colorResolution: UInt8 = (packedField & 0x70 >> 4) & 0x07
        let sortFlag: Bool = packedField & 0x08 == 0x08
        let sizeOfGlobalColorTable = packedField & 0x07

        let backgroundColorIndex = readByte()
        pointerIndex? += 1
        let pixelAspectRatio = readByte()
        pointerIndex? += 1

        return LogicalScreenDescriptor(
            width: uint16(width),
            height: uint16(height),
            globalColorTableFlag: globalColorTableFlag,
            colorResolution: colorResolution,
            sortFlag: sortFlag,
            sizeOfGlobalColorTable: sizeOfGlobalColorTable,
            backgroundColorIndex: backgroundColorIndex,
            pixelAspectRatio: pixelAspectRatio)
    }

    func readGlobalColorTable() {
        //print("\(#function)")
        if let logicalScreenDescriptor = logicalScreenDescriptor,
            logicalScreenDescriptor.globalColorTableFlag {
            /*
             let numberOfColors = 2 ^ (logicalScreenDescriptor.colorResolution + 1)
             let byteLength = 3 * numberOfColors
             pointerIndex? += Int(byteLength)
             */
            _readColorTable(sizeOfColorTable: Int(logicalScreenDescriptor.sizeOfGlobalColorTable))
        }
    }

    func readBody() {
        //print("\(#function)")
        let dataLength = data?.count
        while pointerIndex! < dataLength! {
            /*
             let byte = data?.subdata(in: pointerIndex!..<pointerIndex!+1)
             let byteValue = [UInt8](byte!).first!
             */
            let byteValue = readByte()
            pointerIndex? += 1
            //print("readBody.byteValue = \(byteValue)")
            if byteValue == 0x3B {
                // Trailer block
                break
            }
            switch byteValue {
            case 0x21:
                readExtensions()
            case 0x2C:
                let imageDescriptor = readImageDescriptor()
                imageDescriptors.append(imageDescriptor)
                if imageDescriptor.localColorTabelFlag {
                    readLocalColorTable(sizeOfColorTable: Int(imageDescriptor.sizeOfLocalColorTable))
                }
                readImageData()
            default:
                // TODO:
                break
            }
        }
    }

    func readExtensions() {
        //print("\(#function)")
        let byteValue = readByte()
        //print("readExtensions.byteValue = \(byteValue)")
        pointerIndex? += 1
        switch byteValue {
        case 0xF9:
            readGraphicsControleExtension()
        case 0x01:
            readPlainTextExtension()
        case 0xFF:
            readApplicationExtension()
        case 0xFE:
            readCommentExtension()
        default:
            // TODO
            break
        }
    }

    func readImageDescriptor() -> ImageDescriptor {
        //print("\(#function)")
        let imageLeft = readBytes(2)
        pointerIndex? += 2
        let imageTop = readBytes(2)
        pointerIndex? += 2
        let imageWidth = readBytes(2)
        pointerIndex? += 2
        let imageHeight = readBytes(2)
        pointerIndex? += 2

        let packedField = readByte()
        pointerIndex? += 1
        let localColorTableFlag = packedField & 0x80 == 0x80
        let interlaceFlag = packedField & 0x40 == 0x40
        let sortFlag = packedField & 0x20 == 0x20
        // reserbed for future use, 2 bit
        let sizeOfLocalColorTable = packedField & 0x07

        return ImageDescriptor(
            imageLeft: uint16(imageLeft),
            imageTop: uint16(imageTop),
            imageWidth: uint16(imageWidth),
            imageHeight: uint16(imageHeight),
            localColorTabelFlag: localColorTableFlag,
            interlaceFlag: interlaceFlag,
            sortFlag: sortFlag,
            sizeOfLocalColorTable: sizeOfLocalColorTable)
    }

    func readLocalColorTable(sizeOfColorTable: Int) {
        //print("\(#function)")
        _readColorTable(sizeOfColorTable: sizeOfColorTable)
    }
    func readImageData(){
        //print("\(#function)")
        let LZWMinimumCodeSize = readByte()
        pointerIndex? += 1
        while true {
            let byte = readByte()
            pointerIndex? += 1
            if byte == 0x00 {
                return
            }
            let blockSize = byte
            skipBytes(Int(blockSize))
            imageDataCount += 1
        }
    }

    func readGraphicsControleExtension() {
        //print("\(#function)")
        // block size
        skipBytes(1)

        // - Packed Field
        // - Delay Time(2 byte)
        // - Transparent Color Index
        // - Block Terminator(0x00)
        skipBytes(5)
    }

    func readPlainTextExtension() {
        //print("\(#function)")
        // block size, 0x0c
        skipBytes(1)

        while true {
            // - Text Grid Left Position
            // - Text Grid Right Position
            // - Text Grid Width
            // - Text Grid Height
            // - Character Cell Width
            // - Character Cell Height
            // - Text Foreground Color Index
            // - Text Background Color Index
            skipBytes(0x0c)

            // - Block Terminator(0x00)
            if readByte() == 0x00 {
                return
            }
        }
    }

    func readApplicationExtension() {
        //print("\(#function)")
        // block size, 0x0b
        skipBytes(1)

        let applicationIdentifier = readBytes(8)
        let applicationIdentifierStr = String(bytes: applicationIdentifier, encoding: .utf8)
        pointerIndex? += 8
        let applicationAuthenticationCode = readBytes(3)
        pointerIndex? += 3

        while true {
            let byte = readByte()
            pointerIndex? += 1
            if byte == 0x00 {
                return
            } else {
                let blockSize = byte
                let bytes = readBytes(Int(blockSize))
                // TODO animation GIF
                if (applicationIdentifierStr == "NETSCAPE" || applicationIdentifierStr == "ANIMEXTS") {
                    let loopCount: UInt16 = (UInt16(bytes[2]) << 8) + UInt16(bytes[1])
                    applicationExtensions.append(.netscapeLooping(loopCount: loopCount))
                }
                pointerIndex? += Int(blockSize)
            }
        }
    }

    func readCommentExtension() {
        //print("\(#function)")
        // block size
        let blockSize = readByte()
        pointerIndex? += 1
        // comment data
        skipBytes(Int(blockSize))

        while true {
            let byte = readByte()
            pointerIndex? += 1
            if byte == 0x00 {
                return
            } else {
                let blockSize = byte
                // comment data
                skipBytes(Int(blockSize))
            }
        }
    }

    func _readColorTable(sizeOfColorTable: Int) {
        //print("_ \(#function), sizeOfColorTable = \(sizeOfColorTable)")
        let numberOfColors: Int = Int(pow(Double(2), Double(sizeOfColorTable + 1)))
        let byteLength = 3 * numberOfColors
        //print("  numberOfColors = \(numberOfColors), byteLength = \(byteLength)")
        pointerIndex? += Int(byteLength)
    }

    func skipBytes(_ byteCount: Int) {
        //print("_ \(#function), byteCount = \(byteCount)")
        pointerIndex? += byteCount
    }

    func readBytes(_ byteCount: Int) -> [UInt8] {
        //print("_ \(#function), byteCount = \(byteCount)")
        let bytes = data?.subdata(in: pointerIndex!..<pointerIndex!+byteCount)
        let bytesValue = [UInt8](bytes!)
        return bytesValue
    }

    func readByte() -> UInt8 {
        //print("_ \(#function)")
        let byte = data?.subdata(in: pointerIndex!..<pointerIndex!+1)
        let byteValue = [UInt8](byte!).first!
        return byteValue
    }

    func uint16(_ bytes: [UInt8]) -> UInt16 {
        let result: UInt16 = (UInt16(bytes[1]) << 8) + UInt16(bytes[0])
        return result
    }
}

extension GIFMetadata: CustomStringConvertible {

    public var description: String {
        return [
            "<\(String(describing: type(of: self)))",
            "logicalScreenDescriptor: \(logicalScreenDescriptor)",
            "applicationExtensions: \(applicationExtensions)",
            "imageDescriptors: \(imageDescriptors)",
            "imageDataCount: \(imageDataCount)",
            "preferredLoopCount: \(preferredLoopCount())",
            ">",
            ].joined(separator: "\n  ")
    }
}
