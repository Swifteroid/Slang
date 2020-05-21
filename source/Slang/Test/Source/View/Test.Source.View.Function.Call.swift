import Foundation
import Nimble
import Quick
import Slang

private let sample = """
foo("bar")
foo(a: 1)
foo("bar", a: 2, "baz", b: false, c: 1 + 2)
"""

internal class FunctionCallViewSpec: Spec {
    internal override func spec() {
        let disassembly: Disassembly = try! Disassembly(File(sample))
        let structures: [Structure] = disassembly.structure[0].substructures

        it("can parse call with a single unnamed argument") {
            let view: FunctionCall? = structures[0].view()
            expect(view).toNot(beNil())
            expect(view?.arguments.count) == 1
            expect(view?.arguments[0].index) == 0
            expect(view?.arguments[0].name).to(beNil())
            expect(view?.arguments[0].value.contents) == "\"bar\""
        }

        it("can parse call with a single named argument") {
            let view: FunctionCall? = structures[1].view()
            expect(view).toNot(beNil())
            expect(view?.arguments.count) == 1
            expect(view?.arguments[0].index) == 0
            expect(view?.arguments[0].name) == "a"
            expect(view?.arguments[0].value.contents) == "1"
        }

        it("can parse call with multiple arguments") {
            let view: FunctionCall? = structures[2].view()
            expect(view).toNot(beNil())
            expect(view?.arguments.count) == 5

            expect(view?.arguments[0].index) == 0
            expect(view?.arguments[0].name).to(beNil())
            expect(view?.arguments[0].value.contents) == "\"bar\""

            expect(view?.arguments[1].index) == 1
            expect(view?.arguments[1].name) == "a"
            expect(view?.arguments[1].value.contents) == "2"

            expect(view?.arguments[2].index) == 2
            expect(view?.arguments[2].name).to(beNil())
            expect(view?.arguments[2].value.contents) == "\"baz\""

            expect(view?.arguments[3].index) == 3
            expect(view?.arguments[3].name) == "b"
            expect(view?.arguments[3].value.contents) == "false"

            expect(view?.arguments[4].index) == 4
            expect(view?.arguments[4].name) == "c"
            expect(view?.arguments[4].value.contents) == "1 + 2"
        }
    }
}
