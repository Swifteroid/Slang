import Foundation
import SourceKittenFramework

final public class StructureQuery: Query<Structure>, Quellection {
}

extension StructureQuery {
    public var fragments: FragmentQuery { return FragmentQuery(self.disassembly, self.selection.map({ $0.fragment })) }
    public var syntax: SyntaxQuery { return SyntaxQuery(self.disassembly, self.selection.reduce(into: [], { $0.append(contentsOf: self.disassembly.syntax(in: $1.range)) })) }
}

extension StructureQuery {
    public func select(_ predicate: Predicate) -> StructureQuery {
        return self.query(predicate.match(self.selection))
    }

    public func first(_ predicate: Predicate) -> StructureQuery {
        return self.query(self.selection.first(where: predicate.matches))
    }

    public func last(_ predicate: Predicate) -> StructureQuery {
        return self.query(self.selection.last(where: predicate.matches))
    }

    public func descendants(_ predicate: Predicate, depth: Int? = nil) -> StructureQuery {

        // Recursive search.
        func recursion(_ structures: [Structure], _ depth: Int) -> [Structure] {
            var matches: [Structure] = []

            for structure in structures {
                matches.append(structure)
                if depth > 0 { matches.append(contentsOf: recursion(structure.substructures, depth - 1)) }
            }

            return matches
        }

        return self.query(predicate.match(recursion(self.selection.reduce(into: [], { $0.append(contentsOf: $1.substructures) }), (depth ?? Int.max) - 1)))
    }

    public func children(_ predicate: Predicate) -> StructureQuery {
        return self.descendants(predicate, depth: 1)
    }
}

extension StructureQuery {
    public func select(where filter: @escaping Predicate.Filter) -> StructureQuery { return self.select(Predicate(filter: filter)) }
    public func select(of kind: SourceKind) -> StructureQuery { return self.select(Predicate(kind: kind)) }

    public var first: StructureQuery { return self.first(Predicate()) }
    public func first(where filter: @escaping Predicate.Filter) -> StructureQuery { return self.first(Predicate(filter: filter)) }
    public func first(of kind: SourceKind) -> StructureQuery { return self.first(Predicate(kind: kind)) }

    public var last: StructureQuery { return self.last(Predicate()) }
    public func last(where filter: @escaping Predicate.Filter) -> StructureQuery { return self.last(Predicate(filter: filter)) }
    public func last(of kind: SourceKind) -> StructureQuery { return self.last(Predicate(kind: kind)) }

    public var descendants: StructureQuery { return self.descendants(Predicate()) }
    public func descendants(where filter: @escaping Predicate.Filter, depth: Int? = nil) -> StructureQuery { return self.descendants(Predicate(filter: filter), depth: depth) }
    public func descendants(of kind: SourceKind, depth: Int? = nil) -> StructureQuery { return self.descendants(Predicate(kind: kind), depth: depth) }
    public func descendants(of kinds: [SourceKind], depth: Int? = nil) -> StructureQuery { return self.query(kinds.reduce(into: [], { $0 += self.descendants(Predicate(kind: $1), depth: depth).selection })) }

    public var children: StructureQuery { return self.children(Predicate()) }
    public func children(where filter: @escaping Predicate.Filter) -> StructureQuery { return self.children(Predicate(filter: filter)) }
    public func children(of kind: SourceKind) -> StructureQuery { return self.children(Predicate(kind: kind)) }
    public func children(of kinds: [SourceKind]) -> StructureQuery { return self.query(kinds.reduce(into: [], { $0 += self.children(Predicate(kind: $1)).selection })) }
}

extension StructureQuery {
    public struct Predicate: Slang.Predicate {
        public typealias Context = Structure

        public init(filter: Filter? = nil, kind: SourceKind? = nil) {
            self.filter = filter
            self.kind = kind
        }

        public var filter: Filter?
        public var kind: SourceKind?

        public func matches(_ structure: Structure) -> Bool {
            if let filter = self.filter, !filter(structure) { return false }
            if let kind = self.kind, structure.kind != kind { return false }
            return true
        }

        public func match(_ structures: [Structure]) -> [Structure] {
            return structures.filter(self.matches)
        }
    }
}

extension StructureQuery.Predicate {
    public func filter(_ newValue: Filter?) -> StructureQuery.Predicate { return self.updating({ $0.filter = newValue }) }
    public func kind(_ newValue: SourceKind?) -> StructureQuery.Predicate { return self.updating({ $0.kind = newValue }) }
}
