import Foundation
import SourceKittenFramework

/// Disassembled (digested) source code file.
public class Disassembly {
    public init(_ file: File) throws {
        let lines = file.primitive.lines.map({ Line(file, $0) })
        let syntax = try SourceKittenFramework.SyntaxMap(file: file.primitive).tokens.enumerated().map({ Syntax(file, $0.element, index: $0.offset) })
        let structure = Structure(file, try SourceKittenFramework.Structure(file: file.primitive).dictionary)

        self.file = file
        self.lines = lines
        self.syntax = syntax
        self.structure = [structure]
    }

    public convenience init(_ file: SourceKittenFramework.File) throws {
        try self.init(File(file))
    }

    public let file: File
    public let lines: [Line]
    public let syntax: [Syntax]
    public let structure: [Structure]

    public func lines(in range: Range<Int>) -> [Line] {
        self.lines.filter({ range.overlaps($0.range) })
    }

    public func syntax(in range: Range<Int>) -> [Syntax] {
        self.syntax.filter({ range.overlaps($0.range) })
    }
}

extension Disassembly {
    public var query: Query { Query(self) }

    public struct Query {
        fileprivate init(_ disassembly: Disassembly) { self.disassembly = disassembly }
        private let disassembly: Disassembly
        public var fragment: FragmentQuery { FragmentQuery(self.disassembly, [Fragment(disassembly.file)]) }
        public var syntax: SyntaxQuery { SyntaxQuery(self.disassembly, self.disassembly.syntax) }
        public var structure: StructureQuery { StructureQuery(self.disassembly, self.disassembly.structure) }
    }
}

extension Disassembly: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Disassembly, rhs: Disassembly) -> Bool { lhs === rhs }
}

extension FileSlice {

    /// Returns lines the receiver spans across in the disassembly.
    public func lines(in disassembly: Disassembly) -> [Line] { disassembly.lines(in: self.range) }

    /// Returns syntax tokens the receiver spans across in the disassembly.
    public func syntax(in disassembly: Disassembly) -> [Syntax] { disassembly.syntax(in: self.range) }
}
