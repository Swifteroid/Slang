import Foundation
import Nimble
import Quick
import Slang

internal class EditSpec: Spec {
    internal override func spec() {
        it("can insert") {
            expect(Edit(3, "-baz-").apply("foobar")) == "foo-baz-bar"
            expect(Edit(3 + 1, "-baz-").apply("foo\u{F}\u{F}bar")) == "foo\u{F}-baz-\u{F}bar"
            expect(Edit(3 + 2, "-baz-").apply("foo\u{FF}\u{F}bar")) == "foo\u{FF}-baz-\u{F}bar"
            expect(Edit(3 + 3, "-baz-").apply("foo\u{FFFF}\u{F}bar")) == "foo\u{FFFF}-baz-\u{F}bar"
            expect(Edit(3 + 4, "-baz-").apply("foo\u{FFFFF}\u{F}bar")) == "foo\u{FFFFF}-baz-\u{F}bar"
        }

        it("can replace") {
            expect(Edit(3 ..< 4, "-baz-").apply("fooxbar")) == "foo-baz-bar"
            expect(Edit(3 ..< 3 + 1, "-baz-").apply("foo\u{F}\u{F}bar")) == "foo-baz-\u{F}bar"
            expect(Edit(3 ..< 3 + 2, "-baz-").apply("foo\u{FF}\u{F}bar")) == "foo-baz-\u{F}bar"
            expect(Edit(3 ..< 3 + 3, "-baz-").apply("foo\u{FFFF}\u{F}bar")) == "foo-baz-\u{F}bar"
            expect(Edit(3 ..< 3 + 4, "-baz-").apply("foo\u{FFFFF}\u{F}bar")) == "foo-baz-\u{F}bar"
        }

        it("can remove") {
            expect(Edit(3 ..< 4).apply("fooxbar")) == "foobar"
            expect(Edit(3 ..< 3 + 1).apply("foo\u{F}\u{F}bar")) == "foo\u{F}bar"
            expect(Edit(3 ..< 3 + 2).apply("foo\u{FF}\u{F}bar")) == "foo\u{F}bar"
            expect(Edit(3 ..< 3 + 3).apply("foo\u{FFFF}\u{F}bar")) == "foo\u{F}bar"
            expect(Edit(3 ..< 3 + 4).apply("foo\u{FFFFF}\u{F}bar")) == "foo\u{F}bar"
        }

        it("must apply multiple edits in correct order") {
            let original = "Brown foo qux fex row!"
            let edited = "Brown pow-wow-wow foo 🔥 fex!"

            let insert = Edit(6, "pow-wow-wow ") // own >…< foo
            let replace = Edit(10 ..< 13, "🔥") // >qux<
            let remove = Edit(17 ..< 21) // >row<

            expect(original.applying([remove, replace, insert])) == edited
            expect(original.applying([insert, replace, remove])) == edited
            for _ in 0 ..< 10 { expect(original.applying([insert, replace, remove].shuffled())) == edited }
        }
    }
}
