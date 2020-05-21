import Foundation
import Regex
import SourceKittenFramework

public final class FragmentQuery: Query<Fragment>, Quellection {}

extension FragmentQuery {
    public func select(_ predicate: Predicate) -> FragmentQuery {
        return query(predicate.match(selection))
    }

    public func first(_ predicate: Predicate) -> FragmentQuery {
        return query(selection.first(where: predicate.matches))
    }

    public func last(_ predicate: Predicate) -> FragmentQuery {
        return query(selection.last(where: predicate.matches))
    }

    public func subfragments(_ regex: Regex, _ predicate: Predicate) -> FragmentQuery {
        var fragments: [Fragment] = []

        // ✊ If the regex hes capture groups (capture ranges is not empty) the fragments are build from them, otherwise the entire
        // match is returned. Todo: This might not be enough, consider adding custom match extractor or specifier.

        for fragment in selection {
            for match in regex.allMatches(in: fragment.contents) {
                if match.captureRanges.isEmpty {
                    fragments.append(fragment[match.range])
                } else {
                    fragments.append(contentsOf: match.captureRanges.compactMap { $0.map { fragment[$0] } })
                }
            }
        }

        return query(predicate.match(fragments))
    }
}

extension FragmentQuery {
    public func select(where filter: @escaping Predicate.Filter) -> FragmentQuery { return select(Predicate(filter: filter)) }
    public func select(matching pattern: StaticString, options: Options? = nil) -> FragmentQuery { return select(Predicate(pattern: pattern, options: options)) }
    public func select(matching regex: Regex) -> FragmentQuery { return select(Predicate(regex: regex)) }

    public var first: FragmentQuery { return self.first(Predicate()) }
    public func first(where filter: @escaping (Fragment) -> Bool) -> FragmentQuery { return first(Predicate(filter: filter)) }
    public func first(matching regex: Regex) -> FragmentQuery { return first(Predicate(regex: regex)) }
    public func first(matching pattern: StaticString, options: Options? = nil) -> FragmentQuery { return first(Predicate(pattern: pattern, options: options)) }

    public var last: FragmentQuery { return self.last(Predicate()) }
    public func last(where filter: @escaping (Fragment) -> Bool) -> FragmentQuery { return last(Predicate(filter: filter)) }
    public func last(matching regex: Regex) -> FragmentQuery { return last(Predicate(regex: regex)) }
    public func last(matching pattern: StaticString, options: Options? = nil) -> FragmentQuery { return last(Predicate(pattern: pattern, options: options)) }

    public func subfragments(_ pattern: StaticString, options: Options? = nil) -> FragmentQuery { return subfragments(Regex(pattern, options: options ?? .default), Predicate()) }
    public func subfragments(_ regex: Regex) -> FragmentQuery { return subfragments(regex, Predicate()) }
}

extension FragmentQuery {
    public struct Predicate: Slang.Predicate {
        public typealias Context = Fragment

        public init(filter: Filter? = nil, regex: Regex? = nil) {
            self.filter = filter
            self.regex = regex
        }

        public init(filter: Filter? = nil, pattern: StaticString, options: Options? = nil) {
            self.init(filter: filter, regex: Regex(pattern, options: options ?? .default))
        }

        public var filter: Filter?
        public var regex: Regex?

        public func matches(_ fragment: Fragment) -> Bool {
            if let filter = self.filter, !filter(fragment) { return false }
            if let regex = self.regex, !regex.matches(fragment.contents) { return false }
            return true
        }

        public func match(_ fragments: [Fragment]) -> [Fragment] {
            return fragments.filter(matches)
        }
    }
}

extension FragmentQuery.Predicate {
    public func filter(_ newValue: Filter?) -> FragmentQuery.Predicate { return updating { $0.filter = newValue } }
    public func regex(_ newValue: Regex?) -> FragmentQuery.Predicate { return updating { $0.regex = newValue } }
}

extension Options {
    public static let `default`: Options = [Options.ignoreCase, .anchorsMatchLines]
}
