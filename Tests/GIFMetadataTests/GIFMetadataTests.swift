import XCTest
import Foundation
@testable import GIFMetadata

class GIFMetadataTests: XCTestCase {

    var testBundle: Bundle {
        get {
            return Bundle(for: type(of: self))
        }
    }

    func testBasic() {
        guard let pathStr = testBundle.url(forResource: "Rotating_earth", withExtension: "gif") else {
            assertionFailure("pathStr!")
            return
        }

        print("pathStr = \(pathStr)")
        let gifData = try! Data(contentsOf: pathStr)
        let metadata = GIFMetadata(gifData)
        print("metadata = \(metadata)")
        XCTAssertTrue(true, "true")
    }

    func testPreferedLoopCount() {
        let testCases: [(String, Int)] = [
            // inputFile, expected,
            ("loop0", 0),
            ("loop1", 1),
            ("loop2", 2),
            ("without_loop", 1),
        ]
        for (inputFile, expected) in testCases {
            guard let pathStr = testBundle.url(forResource: inputFile, withExtension: "gif") else {
                assertionFailure("pathStr!")
                return
            }

            print("pathStr = \(pathStr)")
            let gifData = try! Data(contentsOf: pathStr)
            let metadata = GIFMetadata(gifData)
            //print("metadata = \(metadata)")
            let result = metadata.preferredLoopCount()
            //print("result: \(result), expected: \(expected)")
            XCTAssertEqual(result, expected, "\(inputFile).gif's preferredLoopCount() == \(result), expected == \(expected)")
        }
    }

    func testNilData() {
        let nilGifData = Data(_: [])
        let metadata = GIFMetadata(nilGifData)
        //print("metadata = \(metadata)")
        let expected = 0
        let result = metadata.preferredLoopCount()
        //print("result: \(result), expected: \(expected)")
        XCTAssertEqual(result, expected, "nilGifData's preferredLoopCount() == \(result), expected == \(expected)")
    }

    static var allTests = [
        ("testBasic", testBasic),
        ("testPreferedLoopCount", testPreferedLoopCount),
    ]
}
