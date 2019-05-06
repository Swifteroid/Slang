import Slang
import Foundation
import Nimble
import Quick
import SourceKittenFramework

private let sample = """
import Foo
let bar: Int = 123
let baz: String = "Hello world! This qux is such a foo!"
"""

internal class FragmentQuerySpec: Spec {
    override internal func spec() {
        let disassembly = try! Disassembly(File(sample))
        let query = disassembly.query.fragment

        // query.all.forEach({ Swift.print($0.contents) })

        it("can extract subfragments using regular expression pattern") {
            let fragments = query.subfragments("(let ba.)").all
            expect(fragments.count) == 2
            expect(fragments[0].contents) == "let bar"
            expect(fragments[1].contents) == "let baz"
        }
    }
}
