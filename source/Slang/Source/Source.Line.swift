import Foundation
import SourceKittenFramework

/// Line of a source code file.
public class Line: FileSlice {
    public init(_ file: File, _ primitive: SourceKittenFramework.Line) {
        self.file = file
        self.primitive = primitive
        self.index = primitive.index
        // Todo: Why not use byte range directly instead?
        self.range = primitive.byteRange.lowerBound.value ..< primitive.byteRange.upperBound.value
    }

    public let file: File
    public let primitive: SourceKittenFramework.Line

    public let index: Int
    public let range: Range<Int>
}

extension Line: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Line, rhs: Line) -> Bool { lhs === rhs }
}
