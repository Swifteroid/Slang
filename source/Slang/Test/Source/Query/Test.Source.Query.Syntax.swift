import Foundation
import Nimble
import Quick
import Slang
import SourceKittenFramework

private let sample = """
import Foundation

let bar: Int = 123
var qux: String?

// Such a foo!
struct Foo {
    func foo() -> String? { return nil }
}
"""

internal class SyntaxQuerySpec: Spec {
    internal override func spec() {
        let disassembly = try! Disassembly(File(sample))
        let query = disassembly.query.syntax

        // Swift.print(disassembly.syntax)

        it("can query first syntax token") {
            expect(query.first.count) == 1
            expect(query.first.one?.contents) == "import"
            expect(query.first(of: .identifier).one?.contents) == "Foundation"
        }

        it("can query last syntax token") {
            expect(query.last.count) == 1
            expect(query.last.one?.contents) == "nil"
            expect(query.last(of: .typeIdentifier).one?.contents) == "String"
        }

        it("can query next syntax token") {
            expect(query.first.next.one?.contents) == "Foundation"
            expect(query.first.next(of: .identifier).one?.contents) == "Foundation"
            expect(query.first.next(of: .number).one?.contents) == "123"
        }

        it("can query previous syntax token") {
            expect(query.last.previous.one?.contents) == "return"
            expect(query.last.previous(of: .keyword).one?.contents) == "return"
            expect(query.last.previous(of: .identifier).one?.contents) == "foo"
        }
    }
}
