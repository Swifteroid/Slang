import Foundation
import SourceKittenFramework

public final class StructureQuery: Query<Structure>, Quellection {}

extension StructureQuery {
    public var fragments: FragmentQuery { return FragmentQuery(disassembly, selection.map { $0.fragment }) }
    public var syntax: SyntaxQuery { return SyntaxQuery(disassembly, selection.reduce(into: []) { $0.append(contentsOf: self.disassembly.syntax(in: $1.range)) }) }
}

extension StructureQuery {
    public func select(_ predicate: Predicate) -> StructureQuery {
        return query(predicate.match(selection))
    }

    public func first(_ predicate: Predicate) -> StructureQuery {
        return query(selection.first(where: predicate.matches))
    }

    public func last(_ predicate: Predicate) -> StructureQuery {
        return query(selection.last(where: predicate.matches))
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

        return query(predicate.match(recursion(selection.reduce(into: []) { $0.append(contentsOf: $1.substructures) }, (depth ?? Int.max) - 1)))
    }

    public func children(_ predicate: Predicate) -> StructureQuery {
        return descendants(predicate, depth: 1)
    }
}

extension StructureQuery {
    public func select(where filter: @escaping Predicate.Filter) -> StructureQuery { return select(Predicate(filter: filter)) }
    public func select(of kind: SourceKind) -> StructureQuery { return select(Predicate(kind: kind)) }

    public var first: StructureQuery { return self.first(Predicate()) }
    public func first(where filter: @escaping Predicate.Filter) -> StructureQuery { return first(Predicate(filter: filter)) }
    public func first(of kind: SourceKind) -> StructureQuery { return first(Predicate(kind: kind)) }

    public var last: StructureQuery { return self.last(Predicate()) }
    public func last(where filter: @escaping Predicate.Filter) -> StructureQuery { return last(Predicate(filter: filter)) }
    public func last(of kind: SourceKind) -> StructureQuery { return last(Predicate(kind: kind)) }

    public var descendants: StructureQuery { return self.descendants(Predicate()) }
    public func descendants(where filter: @escaping Predicate.Filter, depth: Int? = nil) -> StructureQuery { return descendants(Predicate(filter: filter), depth: depth) }
    public func descendants(of kind: SourceKind, depth: Int? = nil) -> StructureQuery { return descendants(Predicate(kind: kind), depth: depth) }
    public func descendants(of kinds: [SourceKind], depth: Int? = nil) -> StructureQuery { return query(kinds.reduce(into: []) { $0 += self.descendants(Predicate(kind: $1), depth: depth).selection }) }

    public var children: StructureQuery { return self.children(Predicate()) }
    public func children(where filter: @escaping Predicate.Filter) -> StructureQuery { return children(Predicate(filter: filter)) }
    public func children(of kind: SourceKind) -> StructureQuery { return children(Predicate(kind: kind)) }
    public func children(of kinds: [SourceKind]) -> StructureQuery { return query(kinds.reduce(into: []) { $0 += self.children(Predicate(kind: $1)).selection }) }
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
            return structures.filter(matches)
        }
    }
}

extension StructureQuery.Predicate {
    public func filter(_ newValue: Filter?) -> StructureQuery.Predicate { return updating { $0.filter = newValue } }
    public func kind(_ newValue: SourceKind?) -> StructureQuery.Predicate { return updating { $0.kind = newValue } }
}
