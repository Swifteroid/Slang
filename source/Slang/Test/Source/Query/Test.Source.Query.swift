import Slang
import Foundation
import Nimble
import Quick

internal class QuerySpec: Spec {
    override internal func spec() {
        it("must guarantee unique selection") {
            let disassembly = try! Disassembly(File(""))
            let c1 = Context()
            let c2 = Context()
            let c3 = Context()
            expect(Query<Context>(disassembly, [c1, c1, c2, c3, c3, c2]).all) == [c1, c2, c3]
        }
    }
}

fileprivate class Context: FileSlice {
    fileprivate let file: File = File("")
    fileprivate let range: Range<Int> = 0 ..< 1
}

extension Context: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Context, rhs: Context) -> Bool { return lhs === rhs }
}
