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

        it("can return all cases") {
            expect(SourceKind.allCases.count) == 90
        }

        it("can initialize all known cases") {
            SourceKind.allCases.forEach({ expect(SourceKind($0.rawValue)) == $0 })
        }
    }
}
