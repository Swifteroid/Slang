import Slang
import Foundation
import Nimble
import Quick

internal class SourceKindSpec: Spec {
    override internal func spec() {
        it("can initialize deep enums") {
            expect(SourceKind("source.lang.swift.decl.class")) == .decl(.class)
            expect(SourceKind("source.lang.swift.decl.enum")) == .decl(.enum)
            expect(SourceKind("source.lang.swift.decl.enumcase")) == .decl(.enum(.case))
            expect(SourceKind("source.lang.swift.decl.function.free")) == .decl(.function(.free))
            expect(SourceKind("source.lang.swift.expr")) == .expr
            expect(SourceKind("source.lang.swift.expr.argument")) == .expr(.arg)
            expect(SourceKind("source.lang.swift.foreach.sequence")) == .forEachSequence
            expect(SourceKind("source.lang.swift.range.invalid")) == .range(.invalid)
            expect(SourceKind("source.lang.swift.stmt.brace")) == .stmt(.brace)
            expect(SourceKind("source.lang.swift.structure.elem.condition_expr")) == .structureElem(.structureElemCondExpr)
            expect(SourceKind("source.lang.swift.syntaxtype.attribute.builtin")) == .syntaxType(.attributeBuiltin)
            expect(SourceKind("source.lang.swift.type")) == .type
            expect(SourceKind("source.lang.swift.foo.bar")) == .unknown("source.lang.swift.foo.bar")
        }

        it("can initialize all known cases") {
            allCases.forEach({ expect(SourceKind($0)).toNot(beNil()) })
        }
    }
}

private let allCases: [String] = [
    "source.lang.swift.decl.associatedtype",
    "source.lang.swift.decl.class",
    "source.lang.swift.decl.enum",
    "source.lang.swift.decl.enumcase",
    "source.lang.swift.decl.enumelement",
    "source.lang.swift.decl.extension",
    "source.lang.swift.decl.extension.class",
    "source.lang.swift.decl.extension.enum",
    "source.lang.swift.decl.extension.protocol",
    "source.lang.swift.decl.extension.struct",
    "source.lang.swift.decl.function.accessor.address",
    "source.lang.swift.decl.function.accessor.didset",
    "source.lang.swift.decl.function.accessor.getter",
    "source.lang.swift.decl.function.accessor.modify",
    "source.lang.swift.decl.function.accessor.mutableaddress",
    "source.lang.swift.decl.function.accessor.read",
    "source.lang.swift.decl.function.accessor.setter",
    "source.lang.swift.decl.function.accessor.willset",
    "source.lang.swift.decl.function.constructor",
    "source.lang.swift.decl.function.destructor",
    "source.lang.swift.decl.function.free",
    "source.lang.swift.decl.function.method.class",
    "source.lang.swift.decl.function.method.instance",
    "source.lang.swift.decl.function.method.static",
    "source.lang.swift.decl.function.operator.infix",
    "source.lang.swift.decl.function.operator.postfix",
    "source.lang.swift.decl.function.operator.prefix",
    "source.lang.swift.decl.function.subscript",
    "source.lang.swift.decl.generic_type_param",
    "source.lang.swift.decl.module",
    "source.lang.swift.decl.precedencegroup",
    "source.lang.swift.decl.protocol",
    "source.lang.swift.decl.struct",
    "source.lang.swift.decl.typealias",
    "source.lang.swift.decl.var.class",
    "source.lang.swift.decl.var.global",
    "source.lang.swift.decl.var.instance",
    "source.lang.swift.decl.var.local",
    "source.lang.swift.decl.var.parameter",
    "source.lang.swift.decl.var.static",
    "source.lang.swift.expr",
    "source.lang.swift.expr.argument",
    "source.lang.swift.expr.array",
    "source.lang.swift.expr.call",
    "source.lang.swift.expr.closure",
    "source.lang.swift.expr.dictionary",
    "source.lang.swift.expr.object_literal",
    "source.lang.swift.expr.tuple",
    "source.lang.swift.foreach.sequence",
    "source.lang.swift.range.invalid",
    "source.lang.swift.range.multistatement",
    "source.lang.swift.range.multitypememberdeclaration",
    "source.lang.swift.range.singledeclaration",
    "source.lang.swift.range.singleexpression",
    "source.lang.swift.range.singlestatement",
    "source.lang.swift.stmt",
    "source.lang.swift.stmt.brace",
    "source.lang.swift.stmt.case",
    "source.lang.swift.stmt.for",
    "source.lang.swift.stmt.foreach",
    "source.lang.swift.stmt.guard",
    "source.lang.swift.stmt.if",
    "source.lang.swift.stmt.repeatwhile",
    "source.lang.swift.stmt.switch",
    "source.lang.swift.stmt.while",
    "source.lang.swift.structure.elem.condition_expr",
    "source.lang.swift.structure.elem.expr",
    "source.lang.swift.structure.elem.id",
    "source.lang.swift.structure.elem.init_expr",
    "source.lang.swift.structure.elem.pattern",
    "source.lang.swift.structure.elem.typeref",
    "source.lang.swift.syntaxtype.attribute.builtin",
    "source.lang.swift.syntaxtype.attribute.id",
    "source.lang.swift.syntaxtype.buildconfig.id",
    "source.lang.swift.syntaxtype.buildconfig.keyword",
    "source.lang.swift.syntaxtype.comment",
    "source.lang.swift.syntaxtype.comment.mark",
    "source.lang.swift.syntaxtype.comment.url",
    "source.lang.swift.syntaxtype.doccomment",
    "source.lang.swift.syntaxtype.doccomment.field",
    "source.lang.swift.syntaxtype.identifier",
    "source.lang.swift.syntaxtype.keyword",
    "source.lang.swift.syntaxtype.number",
    "source.lang.swift.syntaxtype.objectliteral",
    "source.lang.swift.syntaxtype.placeholder",
    "source.lang.swift.syntaxtype.pounddirective.keyword",
    "source.lang.swift.syntaxtype.string",
    "source.lang.swift.syntaxtype.string_interpolation_anchor",
    "source.lang.swift.syntaxtype.typeidentifier",
    "source.lang.swift.type",
]
