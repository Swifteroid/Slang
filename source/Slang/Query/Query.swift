import Foundation
import SourceKittenFramework

public class Query<Context: Hashable & FileSlice> {
    public init<S: Sequence>(_ disassembly: Disassembly, _ selection: S) where S.Element == Context {
        self.disassembly = disassembly
        self.selection = Array(selection).uniques
    }

    public let disassembly: Disassembly
    public let selection: [Context]
}

extension Query: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(disassembly)
        hasher.combine(selection)
    }

    public static func == (lhs: Query, rhs: Query) -> Bool { return lhs.disassembly == rhs.disassembly && lhs.selection == rhs.selection }
}

extension Query {
    /// Returns all matched elements.
    public var all: [Context] { return selection }

    /// Returns the first matched element.
    public var one: Context? { return all.first }
}

/// It's a query… but it's also a collection! Get it? 😯
public protocol Quellection: Collection where Element == Self, Index == Int, SubSequence == Self {
    associatedtype Context: Hashable, FileSlice

    init<S: Sequence>(_ disassembly: Disassembly, _ selection: S) where S.Element == Context

    var disassembly: Disassembly { get }
    var selection: [Context] { get }
}

extension Quellection {
    public func query<S: Sequence>(_ selection: S) -> Self where S.Element == Context { return type(of: self).init(disassembly, selection) }
    public func query(_ selection: Context?) -> Self { return query(selection.map { [$0] } ?? []) }

    public var startIndex: Index { return selection.startIndex }
    public var endIndex: Index { return selection.endIndex }
    public func index(after i: Index) -> Index { return selection.index(after: i) }
    public subscript(index: Index) -> Self { return query([self.selection[index]]) }
    public subscript(bounds: Range<Index>) -> Self { return query(selection[bounds]) }
}

extension Quellection {
    public func map<Q: Quellection>(_ transform: (Self) -> Q) -> Q {
        return Q(disassembly, selection.reduce(into: []) { $0.append(contentsOf: transform(self.query($1)).selection) })
    }
}

public protocol Predicate {
    associatedtype Context: Hashable, FileSlice
    typealias Filter = (Context) -> Bool

    func matches(_: Context) -> Bool
    func match(_: [Context]) -> [Context]
}

extension Predicate {
    public func updating(_ block: (inout Self) -> Void) -> Self {
        var copy: Self = self
        block(&copy)
        return copy
    }
}

extension Collection where Element: Hashable {
    fileprivate var uniques: [Element] {
        var set: Set<Element> = Set()
        return reduce(into: []) { if set.insert($1).inserted { $0.append($1) } }
    }
}
