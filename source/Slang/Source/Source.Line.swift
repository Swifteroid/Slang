import Foundation
import SourceKittenFramework

/// Line of a source code file.
public class Line: FileSlice {
    public init(_ file: File, _ primitive: SourceKittenFramework.Line) {
        self.file = file
        self.primitive = primitive
        self.index = primitive.index
        self.range = primitive.byteRange.lowerBound ..< primitive.byteRange.upperBound
    }

    public let file: File
    public let primitive: SourceKittenFramework.Line

    public let index: Int
    public let range: Range<Int>
}

extension Line: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Line, rhs: Line) -> Bool { return lhs === rhs }
}
