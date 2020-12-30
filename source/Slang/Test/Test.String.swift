import Foundation
import Nimble
import Quick

internal class StringSpec: QuickSpec {
    internal override func spec() {
        // 🔥 This will fail quite often – when bytes after allocation are not zero
        // the initialized string will not be what we expect.
        // it("can init from bytes without the closing zero-byte") {
        //     expect(String(cString: Array(bytes.dropLast()))) == string
        // }

        it("can return character count and bytes") {
            let string: String = "foo bar \u{1F1FA}\u{1F1F8}"
            let bytes: [Int8] = Array(string.utf8CString)
            expect(string.count) == 9
            expect(String(cString: bytes)) == string
        }

        it("can handle zero bytes") {
            expect("\u{0}".utf8CString) == [0, 0]
            expect(String(cString: [0, 0] as [Int8])) == ""
        }

        it("can handle signed and unsigned bytes") {
            let string: String = "foo bar \u{1F1FA}\u{1F1F8}"
            let signedBytes: [Int8] = Array(string.utf8CString)
            let unsignedBytes = signedBytes.map { UInt8(truncatingIfNeeded: $0) }
            expect(String(cString: signedBytes)) == string
            expect(String(cString: unsignedBytes)) == string
        }

        it("can access unicode scalars") {
            // ✊ Apparently there's no way to represent sting from raw bytes other than using scalars, however, the actual string
            // bytes will differ from their plain values, i.e., `\u{FF}` will not be encoded as `0xFF`. For that reason the encrypted
            // values must be accessed through the unicode scalar view.

            let string: String = "\u{0}\u{F}\u{FF}\u{1F1FA}\u{1F1F8}"
            let scalars: [UInt32] = string.unicodeScalars.map { $0.value }
            expect(scalars[0]) == 0
            expect(scalars[1]) == 0xF
            expect(scalars[2]) == 0xFF
            expect(scalars[3]) == 0x1F1FA
            expect(scalars[4]) == 0x1F1F8
        }
    }
}
