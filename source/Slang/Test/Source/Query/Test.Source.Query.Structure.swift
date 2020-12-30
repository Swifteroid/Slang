import Foundation
import Nimble
import Quick
import Slang
import SourceKittenFramework

private let sample = """
struct Foo {
    enum Error: Swift.Error { case any; case minor; case major }

    class Bar {
        var bar: Int?
    }

    struct Baz {
        let baz: Float = 5
    }

    func foo() -> String? { return nil }
}
"""

internal class StructureQuerySpec: Spec {
    internal override func spec() {
        let disassembly = try! Disassembly(File(sample))
        let query = disassembly.query.structure

        // Swift.print(disassembly.structure)
        // query.descendants.all.forEach({ Swift.print($0.contents) })

        it("can query syntax tokens") {
            expect(query.descendants(of: .decl(.enum(nil))).syntax.first.one?.contents) == "enum"
            expect(query.descendants(of: .decl(.enum(nil))).syntax.last.one?.contents) == "major"
        }

        it("can query descendants") {
            expect(query.descendants.count) == 13
            expect(query.descendants(of: .decl(.struct)).count) == 2
            expect(query.descendants(of: .decl(.enum(.case))).count) == 3
            expect(query.descendants(of: .decl(.enum(.case)), depth: 1).count) == 0
        }

        it("can query children") {
            expect(query.children.count) == 1
            expect(query.children(of: .decl(.struct)).count) == 1
            expect(query.children(of: .decl(.enum(nil))).count) == 0
        }

        it("can query first element") {
            expect(query.descendants.first.one?.name) == "Foo"
            expect(query.descendants.first(of: .decl(.enum(.case))).one?.contents) == "case any"
        }

        it("can query last element") {
            expect(query.descendants.last.one?.name) == "foo()"
            expect(query.descendants.last(of: .decl(.enum(.case))).one?.contents) == "case major"
        }
    }
}
