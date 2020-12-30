import Foundation
import SourceKittenFramework

/// Source code structure, wraps SourceKitten equivalent.
public class Structure: FileSlice {
    public init(_ file: File, _ primitive: [String: SourceKitRepresentable]) {
        guard let range: Range<Int> = unwrap(primitive[.offset] as? Int64, primitive[.length] as? Int64, { Int($0) ..< Int($0 + $1) }) else {
            fatalError("Couldn't extract range from the primitive: \(primitive)")
        }

        self.file = file
        self.primitive = primitive
        self.range = range
        substructures = (primitive[.substructure] as? [[String: SourceKitRepresentable]] ?? []).map { Structure(file, $0) }
    }

    public let file: File
    public let primitive: [String: SourceKitRepresentable]
    public let range: Range<Int>
    public let substructures: [Structure]

    public subscript(key: SwiftDocKey) -> SourceKitRepresentable? {
        return primitive[key]
    }
}

extension Structure {
    public var kind: SourceKind! { return unwrap(self[.kind] as? String) { SourceKind(rawValue: $0) } }

    public var name: String! { return self[.name] as? String }

    public var inheritedType: [String] {
        guard let inheritedType = primitive[.inheritedtypes] as? [[String: SourceKitRepresentable]] else {
            return []
        }

        return inheritedType.compactMap { (unwrap($0[.name] as? String) { $0 }) }
    }

    public var nameRange: Range<Int>! { return unwrap(self[.nameOffset] as? Int64, self[.nameLength] as? Int64) { Int($0) ..< Int($0 + $1) } }

    public var body: String { return file[self.bodyRange] }

    public var bodyCollection: [String] { return body.convertToArray }

    public var bodyRange: Range<Int>! { return unwrap(self[.bodyOffset] as? Int64, self[.bodyLength] as? Int64) { Int($0) ..< Int($0 + $1) } }
}

extension Structure {
    public func conformsTo(class value: String) -> Bool {
        return kind == .decl(.class) && inheritedType.contains(value)
    }

    public func functionName(startsWith value: String) -> Bool {
        guard let name = self.name else {
            return false
        }

        return kind == .decl(.function(.method(.instance))) && name.hasPrefix(value)
    }

    public func functionName(contains value: String) -> Bool {
        guard let name = self.name else {
            return false
        }

        return kind == .decl(.function(.method(.instance))) && name.contains(value)
    }

    public func closureName(contains value: String) -> Bool {
        guard let name = self.name else {
            return false
        }

        return kind == .expr(.call) && name.contains(value)
    }

    public func argumentName(contains value: String) -> Bool {
        guard let name = self.name else {
            return false
        }

        return kind == .expr(.arg) && name.contains(value)
    }
}

extension Structure: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Structure, rhs: Structure) -> Bool { return lhs === rhs }
}

extension Structure: CustomStringConvertible {
    public var description: String { return toJSON(toNSDictionary(primitive)) }
}

extension Dictionary where Key == String {
    fileprivate subscript(key: SwiftDocKey) -> Value? {
        return self[key.rawValue]
    }
}
