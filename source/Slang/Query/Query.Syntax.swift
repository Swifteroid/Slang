import Foundation
import SourceKittenFramework

public final class SyntaxQuery: Query<Syntax>, Quellection {}

extension SyntaxQuery {
    public var fragments: FragmentQuery { return FragmentQuery(disassembly, selection.map { $0.fragment }) }
}

extension SyntaxQuery {
    public func select(_ predicate: Predicate) -> SyntaxQuery {
        return query(predicate.match(selection))
    }

    public func first(_ predicate: Predicate) -> SyntaxQuery {
        return query(selection.first(where: predicate.matches))
    }

    public func last(_ predicate: Predicate) -> SyntaxQuery {
        return query(selection.last(where: predicate.matches))
    }

    public func next(_ predicate: Predicate) -> SyntaxQuery {
        return query(selection
            .max(by: { $0.index < $1.index })
            .flatMap { self.disassembly.syntax.suffix(from: $0.index + 1).first(where: predicate.matches) })
    }

    public func previous(_ predicate: Predicate) -> SyntaxQuery {
        return query(selection
            .max(by: { $0.index < $1.index })
            .flatMap { self.disassembly.syntax.prefix(upTo: $0.index).last(where: predicate.matches) })
    }
}

extension SyntaxQuery {
    public func select(of kind: SourceKind.SyntaxType) -> SyntaxQuery { return select(Predicate(kind: kind)) }
    public func select(where filter: @escaping Predicate.Filter) -> SyntaxQuery { return select(Predicate(filter: filter)) }

    public var first: SyntaxQuery { return self.first(Predicate()) }
    public func first(where filter: @escaping (Syntax) -> Bool) -> SyntaxQuery { return first(Predicate(filter: filter)) }
    public func first(of kind: SourceKind.SyntaxType) -> SyntaxQuery { return first(Predicate(kind: kind)) }

    public var last: SyntaxQuery { return self.last(Predicate()) }
    public func last(where filter: @escaping (Syntax) -> Bool) -> SyntaxQuery { return last(Predicate(filter: filter)) }
    public func last(of kind: SourceKind.SyntaxType) -> SyntaxQuery { return last(Predicate(kind: kind)) }

    public var next: SyntaxQuery { return self.next(Predicate()) }
    public func next(where filter: @escaping (Syntax) -> Bool) -> SyntaxQuery { return next(Predicate(filter: filter)) }
    public func next(of kind: SourceKind.SyntaxType) -> SyntaxQuery { return next(Predicate(kind: kind)) }

    public var previous: SyntaxQuery { return self.previous(Predicate()) }
    public func previous(where filter: @escaping (Syntax) -> Bool) -> SyntaxQuery { return previous(Predicate(filter: filter)) }
    public func previous(of kind: SourceKind.SyntaxType) -> SyntaxQuery { return previous(Predicate(kind: kind)) }
}

extension SyntaxQuery {
    public struct Predicate: Slang.Predicate {
        public typealias Context = Syntax

        public init(filter: Filter? = nil, kind: SourceKind.SyntaxType? = nil) {
            self.filter = filter
            self.kind = kind
        }

        public var filter: Filter?
        public var kind: SourceKind.SyntaxType?

        public func matches(_ syntax: Syntax) -> Bool {
            if let filter = self.filter, !filter(syntax) { return false }
            if let kind = self.kind, syntax.kind != kind { return false }
            return true
        }

        public func match(_ syntax: [Syntax]) -> [Syntax] {
            return syntax.filter(matches)
        }
    }
}

extension SyntaxQuery.Predicate {
    public func filter(_ newValue: Filter?) -> SyntaxQuery.Predicate { return updating { $0.filter = newValue } }
    public func kind(_ newValue: SourceKind.SyntaxType?) -> SyntaxQuery.Predicate { return updating { $0.kind = newValue } }
}
