import Foundation

/// Function call structure view.
public struct FunctionCall: StructureView {
    public init?(_ structure: Structure) {
        if structure.kind != .expr(.call) { return nil }
        var arguments: [Argument] = []

        // Single unnamed arguments don't appear to be parsed and instead should be checked using the body length.
        if !structure.substructures.isEmpty {
            for (index, argument) in structure.substructures.enumerated() {
                if argument.kind != .expr(.arg) { return nil }
                arguments.append(Argument(index: index, name: argument.name, value: Fragment(argument.file, argument.bodyRange)))
            }
        } else if !structure.bodyRange.isEmpty {
            arguments.append(Argument(index: 0, name: nil, value: Fragment(structure.file, structure.bodyRange)))
        }

        self.name = structure.name
        self.structure = structure
        self.arguments = arguments
    }

    public let structure: Structure
    public let name: String
    public let arguments: [Argument]
}

extension FunctionCall: CustomStringConvertible {
    public var description: String { return "\(self.name)(\n\(self.arguments.map({ "    \($0)" }).joined(separator: ",\n"))\n" }
}

extension FunctionCall {
    /// Describes a function call argument.
    public struct Argument {
        init(index: Int, name: String?, value: Fragment) {
            self.index = index
            self.name = name
            self.value = value
        }

        public let index: Int
        public let name: String?
        public let value: Fragment
    }
}

extension FunctionCall.Argument: CustomStringConvertible {
    public var description: String { return "\(type(of: self))(index: \(self.index), name: \(self.name ?? "nil"), value: \(self.value.contents))" }
}
