import XCTest
@testable import StorageToolkit

final class StorageSizeTests: XCTestCase {
    func testNegativeBytesClampToZero() {
        let size = StorageSize(bytes: -100)
        XCTAssertEqual(size.bytes, 0)
    }

    func testBinaryFormatting() {
        let size = StorageSize(bytes: 1_536)
        XCTAssertEqual(size.formatted(style: .binary, fractionDigits: 1), "1.5 KiB")
    }

    func testDecimalFormatting() {
        let size = StorageSize(bytes: 1_500_000)
        XCTAssertEqual(size.formatted(style: .decimal, fractionDigits: 1), "1.5 MB")
    }

    func testParseDecimalGigabytes() {
        let parsed = StorageSize.parse("1.5 GB")
        XCTAssertEqual(parsed?.bytes, 1_500_000_000)
    }

    func testParseBinaryGigabytes() {
        let parsed = StorageSize.parse("1.5 GiB")
        XCTAssertEqual(parsed?.bytes, 1_610_612_736)
    }

    func testParseInvalidInput() {
        XCTAssertNil(StorageSize.parse("hello world"))
    }

    func testReclaimedSpaceSkipsNegativeValues() {
        let reclaimed = StorageSize.reclaimedSpace(fromDeletedItems: [1_024, 2_048, -3_000])
        XCTAssertEqual(reclaimed.bytes, 3_072)
    }

    func testCleanupEfficiency() {
        let reclaimed = StorageSize(bytes: 5_000)
        let total = StorageSize(bytes: 20_000)
        XCTAssertEqual(StorageSize.cleanupEfficiency(reclaimed: reclaimed, total: total), 25)
    }
}
