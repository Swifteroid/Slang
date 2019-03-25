import Slang
import Foundation
import Nimble
import Quick

internal class DisassemblySpec: Spec {
    override internal func spec() {
        it("can initialize") {
            let file = File("struct Secret { func foo() -> String? { return nil } }")
            var disassembly: Disassembly!

            expect(expression: { disassembly = try Disassembly(file) }).toNot(throwError())

            expect(disassembly.lines).toNot(beEmpty())
            expect(disassembly.syntax).toNot(beEmpty())
            expect(disassembly.structure).toNot(beEmpty())
        }
    }
}
