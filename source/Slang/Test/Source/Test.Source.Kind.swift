import Slang
import Foundation
import Nimble
import Quick

// Structure request examples: https://github.com/apple/swift/search?q=req%3Dstructure+path%3A%2Ftest%2FSourceKit&unscoped_q=req%3Dstructure+path%3A%2Ftest%2FSourceKit
// Test: https://github.com/apple/swift/blob/master/test/SourceKit/DocumentStructure/structure.swift
// Input: https://github.com/apple/swift/blob/master/test/SourceKit/DocumentStructure/Inputs/main.swift
// Response: https://github.com/apple/swift/blob/master/test/SourceKit/DocumentStructure/structure.swift.response

// Syntax-map request examples: https://github.com/apple/swift/search?q=req%3Dsyntax-map+path%3A%2Ftest%2FSourceKit&unscoped_q=req%3Dsyntax-map+path%3A%2Ftest%2FSourceKit
// Test: https://github.com/apple/swift/blob/master/test/SourceKit/SyntaxMapData/syntaxmap.swift
// Input: https://github.com/apple/swift/blob/master/test/SourceKit/SyntaxMapData/Inputs/syntaxmap.swift
// Response: https://github.com/apple/swift/blob/master/test/SourceKit/SyntaxMapData/syntaxmap.swift.response

// Get all "source.lang.swift." identifiers.
// strings /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/sourcekitd.framework/Versions/Current/XPCServices/SourceKitService.xpc/Contents/MacOS/SourceKitService|grep source.lang.swift.

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
            SourceKind.allCases.forEach({ expect(SourceKind($0.rawValue)) == $0 })
        }

        it("can compare known and unknown values") {
            expect(SourceKind.decl(.associatedType)) == SourceKind.decl(.associatedType)
            expect(SourceKind.unknown("foo")) == SourceKind.unknown("foo")
            expect(SourceKind.unknown(SourceKind.decl(.associatedType).rawValue)) != SourceKind.decl(.associatedType)
            expect(SourceKind.decl(.associatedType)) != SourceKind.unknown(SourceKind.decl(.associatedType).rawValue)
        }

        it("includes all current source identifiers") {
            let identifiers = try! Slang_Test.identifiers()

            // Make sure it's valid.
            expect(identifiers).toNot(beEmpty())

            // Confirm all identifiers are known, i.e., none were added.
            expect(identifiers.filter({ SourceKind($0) == .unknown($0) })).to(beEmpty())

            // Confirm all currently known identifiers are in the list, i.e., none were removed.  
            expect(SourceKind.allCases.filter({ !identifiers.contains($0.rawValue) })).to(beEmpty())

            // Just to be sure…
            expect(SourceKind.allCases.count) == identifiers.count
        }
    }
}

/// Returns current SourceKit Swift Language identifiers.
fileprivate func identifiers() throws -> [String] {
    let developerPath = try! shell(line: "xcode-select --print-path")
    let sourceKitServicePath = "\(developerPath)/Toolchains/XcodeDefault.xctoolchain/usr/lib/sourcekitd.framework/Versions/Current/XPCServices/SourceKitService.xpc/Contents/MacOS/SourceKitService"
    var identifiers = try! shell(lines: "strings \(sourceKitServicePath)|grep source.lang.swift.")

    // Remove known "out-of-interest" identifiers.

    // -req=complete
    identifiers.removeAll(where: { $0.starts(with: "source.lang.swift.codecomplete.group") })
    identifiers.removeAll(where: { $0.starts(with: "source.lang.swift.completion.unresolvedmember") })
    identifiers.removeAll(where: { $0.starts(with: "source.lang.swift.keyword") })
    identifiers.removeAll(where: { $0.starts(with: "source.lang.swift.literal.") })
    identifiers.removeAll(where: { $0.starts(with: "source.lang.swift.pattern") })

    // -req=doc-info
    identifiers.removeAll(where: { $0.starts(with: "source.lang.swift.attribute.availability") })

    // -req=index
    identifiers.removeAll(where: { $0.starts(with: "source.lang.swift.import.module.") })

    // -req=complete|doc-info|index|cursor|…
    identifiers.removeAll(where: { $0.starts(with: "source.lang.swift.ref.") })

    return identifiers
}
