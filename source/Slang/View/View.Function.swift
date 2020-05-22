import Foundation
import SourceKittenFramework

/// `Function.signature` alias.
public var Func: FunctionSignature {
    Function.signature
}

public struct Function {
    /// Returns empty function signature.
    public static var signature: FunctionSignature { FunctionSignature() }
}

/// Describes a function signature and provides matching capacity.
public struct FunctionSignature {
    public init(_ parameters: [Parameter]) { self.parameters = parameters }
    public init(_ parameters: Parameter...) { self.init(parameters) }

    /// Signature parameters.
    public let parameters: [Parameter]

    /// Tests whether the signature matches the function call.
    public func matches(_ call: FunctionCall) -> Bool {
        call.arguments.count == self.parameters.count && self.parameters.enumerated().allSatisfy({ $0.element.matches(call.arguments[$0.offset]) })
    }
}

extension FunctionSignature {
    static func + (lhs: FunctionSignature, rhs: FunctionSignature.Parameter) -> FunctionSignature {
        FunctionSignature(lhs.parameters + [rhs])
    }
}

extension FunctionSignature {
    public func any() -> FunctionSignature { self + Parameter() }
}

extension FunctionSignature {
    public func any(_ kind: SourceKind.SyntaxType) -> FunctionSignature { self + SyntaxParameter(nil, kind) }
    public func named(_ name: String, _ kind: SourceKind.SyntaxType) -> FunctionSignature { self + SyntaxParameter(.named(name), kind) }
    public func unnamed(_ kind: SourceKind.SyntaxType) -> FunctionSignature { self + SyntaxParameter(.unnamed, kind) }
}

extension FunctionSignature {

    public class Parameter {
        public init(_ name: Name? = nil) {
            self.name = name
        }
        public let name: Name?
        public func matches(_ argument: FunctionCall.Argument) -> Bool {
            self.name?.matches(argument.name) ?? true
        }
    }

    /// Parameter that uses syntax kind predicate.
    public class SyntaxParameter: Parameter {
        public init(_ name: Name? = nil, _ kind: SourceKind.SyntaxType) {
            self.kind = kind
            super.init(name)
        }
        public let kind: SourceKind.SyntaxType
        override public func matches(_ argument: FunctionCall.Argument) -> Bool {
            guard super.matches(argument) else { return false }
            guard let syntax: [Syntax] = try? Disassembly(File(argument.value.contents)).syntax else { return false }
            return syntax.count == 1 && syntax.first?.kind == self.kind
        }
    }

    /// Argument name matcher.
    public enum Name {
        case named(String)
        case unnamed
        fileprivate func matches(_ string: String?) -> Bool {
            switch self {
                case .named(let name): return name == string
                case .unnamed: return string == nil
            }
        }
    }
}

public func ~= (lhs: FunctionSignature, rhs: FunctionCall?) -> Bool {
    rhs.map({ lhs.matches($0) }) ?? false
}
