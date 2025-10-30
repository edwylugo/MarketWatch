import Foundation

protocol NumberFormattable {
    func formattedToTwoDecimals() -> String
}

extension Double: NumberFormattable {
    func formattedToTwoDecimals() -> String {
        String(format: "%.2f", self)
    }
    
    func formattedAsPercent() -> String {
        return String(format: "%.2f%%", self)
    }
}

extension Float: NumberFormattable {
    func formattedToTwoDecimals() -> String {
        String(format: "%.2f", self)
    }
}

extension Decimal: NumberFormattable {
    func formattedToTwoDecimals() -> String {
        NSDecimalNumber(decimal: self).stringValue
    }
}
