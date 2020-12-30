import Foundation

public class Edit {
    public init(_ instruction: Instruction) {
        self.instruction = instruction
    }

    public convenience init(_ index: Int, _ contents: String) {
        self.init(.insert(index: index, contents: contents))
    }

    public convenience init(_ range: Range<Int>, _ contents: String? = nil) {
        if let contents = contents {
            self.init(.replace(range: range, contents: contents))
        } else {
            self.init(.remove(range: range))
        }
    }

    public convenience init(_ slice: FileSlice, _ contents: String? = nil) {
        self.init(slice.range, contents)
    }

    public convenience init(_ oldSlice: Fragment, _ newSlice: Fragment) {
        self.init(oldSlice, newSlice.contents)
    }

    public var instruction: Instruction

    public func apply(_ string: String) -> String {
        var string: String = string
        let utf8: String.UTF8View = string.utf8

        switch instruction {
        case let .insert(index, contents): string.insert(contentsOf: contents, at: utf8[index])
        case let .replace(range, contents): string.replaceSubrange(utf8[range], with: contents)
        case let .remove(range): string.removeSubrange(utf8[range])
        }

        return string
    }
}

extension Edit {
    public enum Instruction: Equatable {
        case insert(index: Int, contents: String)
        case replace(range: Range<Int>, contents: String)
        case remove(range: Range<Int>)
    }
}

extension Edit.Instruction {
    fileprivate var index: Int {
        switch self {
        case let .insert(index, _): return index
        case let .replace(range, _), let .remove(range): return range.lowerBound
        }
    }

    fileprivate var range: Range<Int>? {
        switch self {
        case .insert: return nil
        case let .replace(range, _), let .remove(range): return range
        }
    }

    fileprivate var contents: String? {
        switch self {
        case let .insert(_, contents), let .replace(_, contents): return contents
        case .remove: return nil
        }
    }
}

extension Edit.Instruction: Comparable {
    public static func < (lhs: Edit.Instruction, rhs: Edit.Instruction) -> Bool {
        return lhs.index > rhs.index
    }
}

extension Edit: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Edit, rhs: Edit) -> Bool { return lhs === rhs }
}

extension String {
    public func applying(_ edit: Edit) -> String {
        return edit.apply(self)
    }

    ///
    public func applying(_ edits: [Edit]) -> String {
        return edits.sorted(by: { $0.instruction < $1.instruction }).reduce(self) { $1.apply($0) }
    }
}

extension String.UTF8View {
    fileprivate subscript(index: Int) -> Index {
        return self.index(startIndex, offsetBy: index)
    }

    fileprivate subscript(range: Range<Int>) -> Range<Index> {
        return { $0 ..< self.index($0, offsetBy: range.count) }(self[range.lowerBound])
    }
}
