import Foundation
import SourceKittenFramework

/// Source code syntax token, wraps SourceKitten equivalent.
public class Syntax: FileSlice {
    public init(_ file: File, _ primitive: SourceKittenFramework.SyntaxToken, index: Int) {
        guard case .some(.syntaxType(let kind)) = SourceKind(primitive.type) else { fatalError("Couldn't extract syntax kind from the primitive: \(primitive)") }

        self.file = file
        self.primitive = primitive
        self.index = index
        self.range = primitive.offset ..< primitive.offset + primitive.length
        self.kind = kind
    }

    public let file: File
    public let primitive: SourceKittenFramework.SyntaxToken
    public let index: Int
    public let range: Range<Int>
    public var kind: SourceKind.SyntaxType
}

extension Syntax {
    public func previous(in disassembly: Disassembly) -> Syntax? { return { $0.indices.contains($1) ? $0[$1] : nil }(disassembly.syntax, self.index - 1) }
    public func next(in disassembly: Disassembly) -> Syntax? { return { $0.indices.contains($1) ? $0[$1] : nil }(disassembly.syntax, self.index + 1) }
}

extension Syntax: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Syntax, rhs: Syntax) -> Bool { return lhs === rhs }
}

extension Syntax: CustomStringConvertible {
    public var description: String { return self.primitive.description }
}
