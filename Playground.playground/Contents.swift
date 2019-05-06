import Slang

// Not using multiline string literal because it breaks the playground…
let sample = ""
    + "import Fex \n"
    + "struct Foo { \n"
    + "    enum Error: Swift.Error { case any; case minor; case major } \n"
    + "    class Bar { var bar: Int? } \n"
    + "    struct Baz { let baz: Float = 5 } \n"
    + "    func foo() -> String? { return nil } \n"
    + "} \n"

// Parse the sample source code.
let disassembly = try! Disassembly(File(sample))

// Create top-level queries.
let fragmentQuery = disassembly.query.fragment
let syntaxQuery = disassembly.query.syntax
let structureQuery = disassembly.query.structure

// Find subfragments using regular expression.
fragmentQuery.subfragments("\\s+(.+ Ba.)\\s")[0].one?.contents // "class Bar"
fragmentQuery.subfragments("\\s+(.+ Ba.)\\s").all[1].contents // "class Baz"

// Find first syntax token and first token of identifier kind.
syntaxQuery.first.one?.contents // "import"
syntaxQuery.first(of: .identifier).one?.contents // "Fex"

// Find top level structures and it's children.
structureQuery.children.one?.contents // "struct Foo…"
structureQuery.children.children[0].one?.contents // "enum Error…"
structureQuery.children.children[1].one?.contents // "class Bar…"

// Find the first enum declaration.
structureQuery.descendants(of: .decl(.enum(nil))).one!.contents
