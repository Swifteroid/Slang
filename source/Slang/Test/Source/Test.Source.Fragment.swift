import Foundation
import Nimble
import Quick
import Slang

internal class FragmentSpec: Spec {
    internal override func spec() {
        it("can subrange") {
            let file = File("\"foo\u{F}\u{FF}\u{FFF}\u{FFFF}\u{FFFFF}\"")
            let fragment = Fragment(file)

            expect(fragment[1 ..< 4].contents) == "foo"
            expect(fragment[4 ..< 5].contents) == "\u{F}"
            expect(fragment[5 ..< 7].contents) == "\u{FF}"
            expect(fragment[7 ..< 10].contents) == "\u{FFF}"
            expect(fragment[10 ..< 13].contents) == "\u{FFFF}"
            expect(fragment[13 ..< 17].contents) == "\u{FFFFF}"
        }
    }
}
