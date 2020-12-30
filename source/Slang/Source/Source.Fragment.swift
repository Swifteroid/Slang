import Foundation
import SourceKittenFramework

/// Fragment of a source code file.
public class Fragment: FileSlice {
    public init(_ file: File, _ range: Range<Int>? = nil) {
        self.file = file
        self.range = range ?? file.contents.utf8.range
    }

    public convenience init(_ fileSlice: FileSlice) {
        self.init(fileSlice.file, fileSlice.range)
    }

    public let file: File
    public let range: Range<Int>

    public subscript(range: Range<Int>) -> Fragment {
        return Fragment(file, self.range.lowerBound + range.lowerBound ..< self.range.lowerBound + range.upperBound)
    }

    /// Returns subfragment for the string range.
    public subscript(subrange: Range<String.Index>) -> Fragment {
        let contents = self.contents
        let range = self.range

        // ✊ The mighty compiler said the following is deprecated. Keeping it here for reference for the time being
        // as I'm not 100% sure if both are equivalent. Tests are passing, though…

        // guard let lowerBound = subrange.lowerBound.samePosition(in: contents.utf8) else { fatalError("Cannot extract subfragment (\(subrange) from the fragment: \(self)") }
        // guard let upperBound = subrange.upperBound.samePosition(in: contents.utf8)?.encodedOffset else { fatalError("Cannot extract subfragment (\(subrange) from the fragment: \(self)") }
        // return Fragment(self.file, range.lowerBound + lowerBound ..< range.lowerBound + upperBound)

        return Fragment(file, range.lowerBound + subrange.lowerBound.utf16Offset(in: contents) ..< range.lowerBound + subrange.upperBound.utf16Offset(in: contents))
    }
}

extension Fragment: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Fragment, rhs: Fragment) -> Bool { return lhs.file === rhs.file && lhs.range == rhs.range }
}

extension Fragment: CustomStringConvertible {
    public var description: String { return "\"\(contents.truncate(64))\" (\(range.lowerBound):\(range.upperBound))" }
}

extension String.UTF8View {
    fileprivate var range: Range<Int> { return 0 ..< count }
}
