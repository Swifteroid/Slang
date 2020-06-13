import Foundation

// strings /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/sourcekitd.framework/Versions/Current/XPCServices/SourceKitService.xpc/Contents/MacOS/SourceKitService|grep source.lang.swift

fileprivate protocol SourceKindProtocol {
    init?(rawValue: String)
    init?(_ rawValue: String)
    var rawValue: String { get }
    static var base: SourceKind.Base { get }
}

extension SourceKindProtocol {
    fileprivate init?(_ rawValue: String) { self.init(rawValue: rawValue) }
}

extension SourceKind {
    /// The source group common identifier prefix, all members of the group start with this value.
    fileprivate struct Base: RawRepresentable, ExpressibleByStringLiteral {
        fileprivate init(stringLiteral value: StringLiteralType) { self.rawValue = value }
        fileprivate init(_ rawValue: String) { self.rawValue = rawValue }
        fileprivate init(rawValue: String) { self.rawValue = rawValue }
        fileprivate let rawValue: String
        fileprivate static func ~= (lhs: Base, rhs: String) -> Bool { rhs.starts(with: lhs.rawValue) }
    }
}

public enum SourceKind: SourceKindProtocol, RawRepresentable, Equatable, CaseIterable {
    public typealias AllCases = [Self]
    fileprivate static let base: Base = "source.lang.swift."

    // Todo: Do we also need a `ref` case? Doesn't it copy `decl`?

    case decl(Decl)
    case expr(Expr?)
    case forEachSequence
    case range(Range)
    case stmt(Stmt?)
    case structureElem(StructureElem)
    case syntaxType(SyntaxType)
    case type
    case unknown(_ rawValue: String)

    public static let expr = SourceKind.expr(nil)
    public static let stmt = SourceKind.stmt(nil)

    private struct Raw {
        fileprivate static let expr: String = "source.lang.swift.expr"
        fileprivate static let forEachSequence: String = "source.lang.swift.foreach.sequence"
        fileprivate static let stmt: String = "source.lang.swift.stmt"
        fileprivate static let type: String = "source.lang.swift.type"
    }

    public init?(rawValue: String) {
        var kind: SourceKind?

        switch rawValue {
            case Decl.base: kind = Decl(rawValue).map({ .decl($0) })
            case Raw.expr: kind = .expr
            case Expr.base: kind = Expr(rawValue).map({ .expr($0) })
            case Raw.forEachSequence: kind = .forEachSequence
            case Range.base: kind = Range(rawValue).map({ .range($0) })
            case Raw.stmt: kind = .stmt
            case Stmt.base: kind = Stmt(rawValue).map({ .stmt($0) })
            case StructureElem.base: kind = StructureElem(rawValue).map({ .structureElem($0) })
            case SyntaxType.base: kind = SyntaxType(rawValue).map({ .syntaxType($0) })
            case Raw.type: kind = .type
            default: ()
        }

        self = kind ?? .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
            case .decl(let kind): return kind.rawValue
            case .expr(let kind): return kind?.rawValue ?? Raw.expr
            case .forEachSequence: return Raw.forEachSequence
            case .range(let kind): return kind.rawValue
            case .stmt(let kind): return kind?.rawValue ?? Raw.stmt
            case .structureElem(let kind): return kind.rawValue
            case .syntaxType(let kind): return kind.rawValue
            case .type: return Raw.type
            case .unknown(let rawValue): return rawValue
        }
    }

    public static let allCases: AllCases = []
        + Decl.allCases.map({ Self.decl($0) })
        + [Self.expr(nil)]
        + Expr.allCases.map({ Self.expr($0) })
        + [Self.forEachSequence]
        + Range.allCases.map({ Self.range($0) })
        + [Self.stmt(nil)]
        + Stmt.allCases.map({ Self.stmt($0) })
        + StructureElem.allCases.map({ Self.structureElem($0) })
        + SyntaxType.allCases.map({ Self.syntaxType($0) })
        + [Self.type]

    public static func == (lhs: SourceKind, rhs: SourceKind) -> Bool {
        // A more "intelligent" equality check to handle `unknown` values. Without this, any type would
        // equal to `unknown` if it has the same raw value.
        switch (lhs, rhs) {
            case (.unknown, .unknown): return lhs.rawValue == rhs.rawValue
            case (_, .unknown), (.unknown, _): return false
            default: return lhs.rawValue == rhs.rawValue
        }
    }
}

extension SourceKind {
    public init?(_ rawValue: String) { self.init(rawValue: rawValue) }
}

extension SourceKind {
    public enum Decl: SourceKindProtocol, RawRepresentable, CaseIterable {
        public typealias AllCases = [Self]
        fileprivate static let base: Base = "source.lang.swift.decl."

        case associatedType
        case `class`
        case `enum`(Enum?)
        case `extension`(Extension?)
        case function(Function)
        case genericTypeParam
        case module
        case precedenceGroup
        case `protocol`
        case `struct`
        case typeAlias
        case `var`(Var)

        public static let `enum` = Decl.enum(nil)
        public static let `extension` = Decl.extension(nil)

        private struct Raw {
            fileprivate static let associatedType = "source.lang.swift.decl.associatedtype"
            fileprivate static let `class` = "source.lang.swift.decl.class"
            fileprivate static let `enum` = "source.lang.swift.decl.enum"
            fileprivate static let `extension` = "source.lang.swift.decl.extension"
            fileprivate static let genericTypeParam = "source.lang.swift.decl.generic_type_param"
            fileprivate static let module = "source.lang.swift.decl.module"
            fileprivate static let precedenceGroup = "source.lang.swift.decl.precedencegroup"
            fileprivate static let `protocol` = "source.lang.swift.decl.protocol"
            fileprivate static let `struct` = "source.lang.swift.decl.struct"
            fileprivate static let typeAlias = "source.lang.swift.decl.typealias"
        }

        public init?(rawValue: String) {
            var kind: Decl?

            switch rawValue {
                case Raw.associatedType: kind = .associatedType
                case Raw.class: kind = .class
                case Raw.enum: kind = .enum
                case Enum.base: kind = Enum(rawValue).map({ Decl.enum($0) })
                case Raw.extension: kind = .extension
                case Extension.base: kind = Extension(rawValue).map({ .extension($0) })
                case Function.base: kind = Function(rawValue).map({ .function($0) })
                case Raw.genericTypeParam: kind = .genericTypeParam
                case Raw.module: kind = .module
                case Raw.precedenceGroup: kind = .precedenceGroup
                case Raw.protocol: kind = .protocol
                case Raw.struct: kind = .struct
                case Raw.typeAlias: kind = .typeAlias
                case Var.base: kind = Var(rawValue).map({ .var($0) })
                default: ()
            }

            if let kind: Decl = kind { self = kind } else { return nil }
        }

        public var rawValue: String {
            switch self {
                case .associatedType: return Raw.associatedType
                case .class: return Raw.class
                case .enum(let kind): return kind?.rawValue ?? Raw.enum
                case .`extension`(let kind): return kind?.rawValue ?? Raw.extension
                case .function(let kind): return kind.rawValue
                case .genericTypeParam: return "source.lang.swift.decl.generic_type_param"
                case .module: return "source.lang.swift.decl.module"
                case .precedenceGroup: return "source.lang.swift.decl.precedencegroup"
                case .`protocol`: return "source.lang.swift.decl.protocol"
                case .`struct`: return "source.lang.swift.decl.struct"
                case .typeAlias: return "source.lang.swift.decl.typealias"
                case .`var`(let kind): return kind.rawValue
            }
        }

        public static let allCases: AllCases = []
            + [Self.associatedType]
            + [Self.class]
            + [Self.enum(nil)]
            + Enum.allCases.map({ Self.enum($0) })
            + [Self.extension(nil)]
            + Extension.allCases.map({ Self.extension($0) })
            + Function.allCases.map({ Self.function($0) })
            + [Self.genericTypeParam]
            + [Self.module]
            + [Self.precedenceGroup]
            + [Self.protocol]
            + [Self.struct]
            + [Self.typeAlias]
            + Var.allCases.map({ Self.var($0) })
    }

    public enum Expr: String, SourceKindProtocol, CaseIterable {
        fileprivate static let base: Base = "source.lang.swift.expr"

        case arg = "source.lang.swift.expr.argument"
        case array = "source.lang.swift.expr.array"
        case call = "source.lang.swift.expr.call"
        case closure = "source.lang.swift.expr.closure"
        case dictionary = "source.lang.swift.expr.dictionary"
        case objectLiteral = "source.lang.swift.expr.object_literal"
        case tuple = "source.lang.swift.expr.tuple"
    }

    public enum Range: String, SourceKindProtocol, CaseIterable {
        fileprivate static let base: Base = "source.lang.swift.range."

        case invalid = "source.lang.swift.range.invalid"
        case multiStatement = "source.lang.swift.range.multistatement"
        case multiTypeMemberDeclaration = "source.lang.swift.range.multitypememberdeclaration"
        case singleDeclaration = "source.lang.swift.range.singledeclaration"
        case singleExpression = "source.lang.swift.range.singleexpression"
        case singleStatement = "source.lang.swift.range.singlestatement"
    }

    public enum Stmt: String, SourceKindProtocol, CaseIterable {
        fileprivate static let base: Base = "source.lang.swift.stmt"

        case brace = "source.lang.swift.stmt.brace"
        case `case` = "source.lang.swift.stmt.case"
        case `for` = "source.lang.swift.stmt.for"
        case forEach = "source.lang.swift.stmt.foreach"
        case `guard` = "source.lang.swift.stmt.guard"
        case `if` = "source.lang.swift.stmt.if"
        case repeatWhile = "source.lang.swift.stmt.repeatwhile"
        case `switch` = "source.lang.swift.stmt.switch"
        case `while` = "source.lang.swift.stmt.while"
    }

    public enum StructureElem: String, SourceKindProtocol, CaseIterable {
        fileprivate static let base: Base = "source.lang.swift.structure.elem."

        case structureElemCondExpr = "source.lang.swift.structure.elem.condition_expr"
        case structureElemExpr = "source.lang.swift.structure.elem.expr"
        case structureElemId = "source.lang.swift.structure.elem.id"
        case structureElemInitExpr = "source.lang.swift.structure.elem.init_expr"
        case structureElemPattern = "source.lang.swift.structure.elem.pattern"
        case structureElemTypeRef = "source.lang.swift.structure.elem.typeref"
    }

    public enum SyntaxType: String, SourceKindProtocol, CaseIterable {
        fileprivate static let base: Base = "source.lang.swift.syntaxtype."

        case attributeBuiltin = "source.lang.swift.syntaxtype.attribute.builtin"
        case attributeId = "source.lang.swift.syntaxtype.attribute.id"
        case buildConfigId = "source.lang.swift.syntaxtype.buildconfig.id"
        case buildConfigKeyword = "source.lang.swift.syntaxtype.buildconfig.keyword"
        case comment = "source.lang.swift.syntaxtype.comment"
        case commentMarker = "source.lang.swift.syntaxtype.comment.mark"
        case commentURL = "source.lang.swift.syntaxtype.comment.url"
        case docComment = "source.lang.swift.syntaxtype.doccomment"
        case docCommentField = "source.lang.swift.syntaxtype.doccomment.field"
        case identifier = "source.lang.swift.syntaxtype.identifier"
        case keyword = "source.lang.swift.syntaxtype.keyword"
        case number = "source.lang.swift.syntaxtype.number"
        case objectLiteral = "source.lang.swift.syntaxtype.objectliteral"
        case placeholder = "source.lang.swift.syntaxtype.placeholder"
        case poundDirectiveKeyword = "source.lang.swift.syntaxtype.pounddirective.keyword"
        case string = "source.lang.swift.syntaxtype.string"
        case stringInterpolation = "source.lang.swift.syntaxtype.string_interpolation_anchor"
        case typeIdentifier = "source.lang.swift.syntaxtype.typeidentifier"
    }
}

extension SourceKind.Decl {
    public enum Enum: String, SourceKindProtocol, CaseIterable {
        fileprivate static let base: SourceKind.Base = "source.lang.swift.decl.enum"

        case `case` = "source.lang.swift.decl.enumcase"
        case element = "source.lang.swift.decl.enumelement"
    }

    public enum Extension: String, SourceKindProtocol, CaseIterable {
        fileprivate static let base: SourceKind.Base = "source.lang.swift.decl.extension"

        case `class` = "source.lang.swift.decl.extension.class"
        case `enum` = "source.lang.swift.decl.extension.enum"
        case `protocol` = "source.lang.swift.decl.extension.protocol"
        case `struct` = "source.lang.swift.decl.extension.struct"
    }

    public enum Function: SourceKindProtocol, RawRepresentable, CaseIterable {
        public typealias AllCases = [Self]
        fileprivate static let base: SourceKind.Base = "source.lang.swift.decl.function."

        case accessor(Accessor)
        case constructor
        case destructor
        case free
        case method(Method)
        case `operator`(Operator)
        case `subscript`

        private struct Raw {
            fileprivate static let constructor = "source.lang.swift.decl.function.constructor"
            fileprivate static let destructor = "source.lang.swift.decl.function.destructor"
            fileprivate static let free = "source.lang.swift.decl.function.free"
            fileprivate static let `subscript` = "source.lang.swift.decl.function.subscript"
        }

        public init?(rawValue: String) {
            var kind: Function?

            switch rawValue {
                case Accessor.base: kind = Accessor(rawValue).map({ .accessor($0) })
                case Raw.constructor: kind = .constructor
                case Raw.destructor: kind = .destructor
                case Raw.free: kind = .free
                case Method.base: kind = Method(rawValue).map({ .method($0) })
                case Operator.base: kind = Operator(rawValue).map({ .operator($0) })
                case Raw.subscript: kind = .subscript
                default: ()
            }

            if let kind: Function = kind { self = kind } else { return nil }
        }

        public var rawValue: String {
            switch self {
                case .accessor(let kind): return kind.rawValue
                case .constructor: return Raw.constructor
                case .destructor: return Raw.destructor
                case .free: return Raw.free
                case .method(let kind): return kind.rawValue
                case .operator(let kind): return kind.rawValue
                case .subscript: return Raw.subscript
            }
        }

        public static let allCases: AllCases = []
            + Accessor.allCases.map({ Self.accessor($0) })
            + [Self.constructor]
            + [Self.destructor]
            + [Self.free]
            + Method.allCases.map({ Self.method($0) })
            + Operator.allCases.map({ Self.operator($0) })
            + [Self.subscript]
    }

    public enum Var: String, SourceKindProtocol, CaseIterable {
        fileprivate static let base: SourceKind.Base = "source.lang.swift.decl.var."

        case `class` = "source.lang.swift.decl.var.class"
        case global = "source.lang.swift.decl.var.global"
        case instance = "source.lang.swift.decl.var.instance"
        case local = "source.lang.swift.decl.var.local"
        case param = "source.lang.swift.decl.var.parameter"
        case `static` = "source.lang.swift.decl.var.static"
    }
}

extension SourceKind.Decl.Function {
    public enum Accessor: String, SourceKindProtocol, CaseIterable {
        fileprivate static let base: SourceKind.Base = "source.lang.swift.decl.function.accessor."

        case address = "source.lang.swift.decl.function.accessor.address"
        case didSet = "source.lang.swift.decl.function.accessor.didset"
        case getter = "source.lang.swift.decl.function.accessor.getter"
        case modify = "source.lang.swift.decl.function.accessor.modify"
        case mutableAddress = "source.lang.swift.decl.function.accessor.mutableaddress"
        case read = "source.lang.swift.decl.function.accessor.read"
        case setter = "source.lang.swift.decl.function.accessor.setter"
        case willSet = "source.lang.swift.decl.function.accessor.willset"
    }

    public enum Method: String, SourceKindProtocol, CaseIterable {
        fileprivate static let base: SourceKind.Base = "source.lang.swift.decl.function.method."

        case `class` = "source.lang.swift.decl.function.method.class"
        case instance = "source.lang.swift.decl.function.method.instance"
        case `static` = "source.lang.swift.decl.function.method.static"
    }

    public enum Operator: String, SourceKindProtocol, CaseIterable {
        fileprivate static let base: SourceKind.Base = "source.lang.swift.decl.function.operator."

        case infix = "source.lang.swift.decl.function.operator.infix"
        case postfix = "source.lang.swift.decl.function.operator.postfix"
        case prefix = "source.lang.swift.decl.function.operator.prefix"
    }
}
