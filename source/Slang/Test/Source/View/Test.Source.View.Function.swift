import Foundation
import Nimble
import Quick
import Slang

private let sample = """
foo(a: 1)
foo("bar", a: 2, "baz", b: false, c: 1 + 2)
"""

internal class FunctionSignatureSpec: Spec {
    internal override func spec() {
        let disassembly: Disassembly = try! Disassembly(File(sample))
        let structures: [Structure] = disassembly.structure[0].substructures

        it("can match function call") {
            var call: FunctionCall

            call = structures[0].view()!
            expect(Func.any() ~= call) == true
            expect(Func.named("a", .number) ~= call) == true
            expect(Func.unnamed(.number) ~= call) == false

            call = structures[1].view()!
            expect(Func.any() ~= call) == false
            expect(Func.any().any().any().any().any() ~= call) == true
            expect(Func.unnamed(.string).named("a", .number).any().named("b", .keyword).any() ~= call) == true
        }
    }
}
