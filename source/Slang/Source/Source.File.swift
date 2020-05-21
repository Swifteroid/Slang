import Foundation
import SourceKittenFramework

/// Swift language source code file.
public class File {
    public init(_ primitive: SourceKittenFramework.File) {
        self.primitive = primitive
    }

    public convenience init() {
        self.init("")
    }

    public convenience init(_ contents: String) {
        self.init(SourceKittenFramework.File(contents: contents))
    }

    public convenience init?(_ url: URL) {
        guard let primitive = SourceKittenFramework.File(path: url.path) else { return nil }
        self.init(primitive)
    }

    public var primitive: SourceKittenFramework.File

    public var contents: String {
        get { return primitive.contents }
        set { primitive.contents = newValue }
    }

    public var url: URL? {
        return primitive.path.map { URL(fileURLWithPath: $0) }
    }

    public subscript(range: Range<Int>) -> String {
        let utf8 = contents.utf8
        let lowerBound: String.Index = utf8.index(utf8.startIndex, offsetBy: range.lowerBound)
        let upperBound: String.Index = utf8.index(lowerBound, offsetBy: range.upperBound - range.lowerBound)
        return String(utf8[lowerBound ..< upperBound])!
    }

    public subscript(fragment: FileSlice) -> String {
        return self[fragment.range]
    }
}

extension File: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: File, rhs: File) -> Bool { return lhs === rhs }
}

/// Slice of a Swift language source code file.
public protocol FileSlice {
    var file: File { get }
    /// The slice's range in the file, equivalent to `Range<UTF8Index>`.
    var range: Range<Int> { get }
}

extension FileSlice {
    public var contents: String {
        return file[self]
    }

    public var fragment: Fragment {
        return Fragment(self)
    }
}
