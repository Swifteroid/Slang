import Foundation

/// Returns the tuple of unwrapped values if all of them are not `nil`
@discardableResult internal func unwrap<V1, V2>(_ v1: V1?, _ v2: V2?) -> (V1, V2)? {
    if let v1 = v1, let v2 = v2 { return (v1, v2) } else { return nil }
}

/// Returns the tuple of unwrapped values if all of them are not `nil`
@discardableResult internal func unwrap<V1, V2, V3>(_ v1: V1?, _ v2: V2?, _ v3: V3?) -> (V1, V2, V3)? {
    if let v1 = v1, let v2 = v2, let v3 = v3 { return (v1, v2, v3) } else { return nil }
}

/// Performs the block with the unwrapped value if it is not `nil`.
@discardableResult internal func unwrap<V, R>(_ v: V?, _ block: (_ v: V) throws -> R?) rethrows -> R? {
    if let v = v { return try block(v) } else { return nil }
}

/// Performs the block with unwrapped values if all of them are not `nil`.
@discardableResult internal func unwrap<V1, V2, R>(_ v1: V1?, _ v2: V2?, _ block: (_ v1: V1, _ v2: V2) throws -> R?) rethrows -> R? {
    if let (v1, v2) = unwrap(v1, v2) { return try block(v1, v2) } else { return nil }
}

/// Performs the block with unwrapped values if all of them are not `nil`.
@discardableResult internal func unwrap<V1, V2, V3, R>(_ v1: V1?, _ v2: V2?, _ v3: V3?, _ block: (_ v1: V1, _ v2: V2, _ v3: V3) throws -> R?) rethrows -> R? {
    if let (v1, v2, v3) = unwrap(v1, v2, v3) { return try block(v1, v2, v3) } else { return nil }
}

extension String {
    /// Truncates the string from the end to the given max length.
    internal func truncate(_ length: Int) -> String {
        return count < length ? self : prefix(length) + "…"
    }

    public func components(separatedBy separators: [String]) -> [String] {
        var output: [String] = [self]

        for separator in separators {
            output = output.flatMap { $0.components(separatedBy: separator) }
        }

        return output.map { $0.trimmingCharacters(in: .whitespaces) }
    }

    /// Convert Array literal to an Array
    public var convertToArray: [String] {
        let data = self.data(using: .utf8)

        var collection: [String]!

        do {
            collection = try JSONSerialization.jsonObject(with: data!, options: []) as? [String]
        } catch {
            collection = components(separatedBy: .whitespacesAndNewlines)
                .flatMap { $0.components(separatedBy: [",", ".", "[", "]", "\""]) }
                .filter { !$0.isEmpty }
        }

        return collection
    }
}
