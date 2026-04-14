import Foundation

public enum StorageStyle: Sendable {
    case binary
    case decimal
}

public struct StorageSize: Equatable, Comparable, Sendable {
    public let bytes: Int64

    public init(bytes: Int64) {
        self.bytes = max(0, bytes)
    }

    public static func < (lhs: StorageSize, rhs: StorageSize) -> Bool {
        lhs.bytes < rhs.bytes
    }

    public func formatted(style: StorageStyle = .binary, fractionDigits: Int = 2) -> String {
        let base: Double = (style == .binary) ? 1024 : 1000
        let units = (style == .binary)
            ? ["B", "KiB", "MiB", "GiB", "TiB", "PiB"]
            : ["B", "KB", "MB", "GB", "TB", "PB"]

        var value = Double(bytes)
        var index = 0

        while value >= base && index < units.count - 1 {
            value /= base
            index += 1
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = max(0, fractionDigits)
        formatter.minimumFractionDigits = 0

        let formattedNumber = formatter.string(from: NSNumber(value: value))
            ?? String(format: "%.\(max(0, fractionDigits))f", value)

        return "\(formattedNumber) \(units[index])"
    }

    public static func parse(_ input: String) -> StorageSize? {
        let normalized = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^([0-9]+(?:\.[0-9]+)?)\s*([a-zA-Z]*)$"#

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }

        let range = NSRange(normalized.startIndex..<normalized.endIndex, in: normalized)
        guard let match = regex.firstMatch(in: normalized, options: [], range: range),
              match.numberOfRanges == 3,
              let valueRange = Range(match.range(at: 1), in: normalized),
              let unitRange = Range(match.range(at: 2), in: normalized),
              let value = Double(normalized[valueRange]) else {
            return nil
        }

        let unit = String(normalized[unitRange]).lowercased()
        guard let multiplier = multiplier(for: unit) else {
            return nil
        }

        return StorageSize(bytes: Int64((value * multiplier).rounded()))
    }

    public static func reclaimedSpace(fromDeletedItems bytes: [Int64]) -> StorageSize {
        let total = bytes
            .filter { $0 > 0 }
            .reduce(Int64(0), +)
        return StorageSize(bytes: total)
    }

    public static func cleanupEfficiency(reclaimed: StorageSize, total: StorageSize) -> Double {
        guard total.bytes > 0 else { return 0 }
        let percentage = (Double(reclaimed.bytes) / Double(total.bytes)) * 100
        return min(100, max(0, percentage))
    }

    private static func multiplier(for unit: String) -> Double? {
        switch unit {
        case "", "b", "byte", "bytes":
            return 1
        case "k", "kb":
            return 1_000
        case "m", "mb":
            return 1_000_000
        case "g", "gb":
            return 1_000_000_000
        case "t", "tb":
            return 1_000_000_000_000
        case "p", "pb":
            return 1_000_000_000_000_000
        case "ki", "kib":
            return 1_024
        case "mi", "mib":
            return 1_048_576
        case "gi", "gib":
            return 1_073_741_824
        case "ti", "tib":
            return 1_099_511_627_776
        case "pi", "pib":
            return 1_125_899_906_842_624
        default:
            return nil
        }
    }
}
