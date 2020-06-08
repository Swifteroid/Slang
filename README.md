# Slang [![Build Status](https://travis-ci.org/Swifteroid/Slang.svg?branch=master)](https://travis-ci.org/Swifteroid/Slang)

Slang is a Swift language source querying and editing framework – it's built on top of [SourceKitten](https://github.com/jpsim/SourceKitten) (which on its own is built on top of [SourceKit](https://github.com/apple/swift/tree/master/tools/SourceKit)) and provides super-simple access to code fragments, syntax, and structures for their analysis and modification.

## Usage

Checkout the [Slang playground](/Playground.playground) and unit tests for more usage examples. Below is a very basic showcase for extracting Swift source code elements and modifying them:

```swift
import Slang

let source: String = "import Foundation; class Foo { let bar = 1 }"
let file: File = File(source)
let disassembly: Disassembly = try! Disassembly(file)
var edits: [Edit] = []

// Change "Foundation" identifier to "AppKit".
edits.append(Edit(disassembly.query.syntax.first(of: .identifier).select(where: { $0.contents == "Foundation" }).one!, "AppKit"))
// Change "class" keyword to "struct".
edits.append(Edit(disassembly.query.structure.children(of: .decl(.class)).syntax.first(of: .keyword).one!, "struct"))
// Change "bar" property value from "1" to "BAR".
edits.append(Edit(disassembly.query.structure.children(of: .decl(.class)).syntax.last(of: .number).one!, "\"BAR\""))

print(file.contents.applying(edits))
// import AppKit; struct Foo { let bar = "BAR" }
```

## Parsing

Source code gets parsed (disassembled) using `Disassembly` class into three views:

- `Fragment` – string slice of the original source.
- `Syntax` – Swift language syntax token, for example, `import`, `class`, `var`, etc.
- `Structure` - a distinct block of code that might contain other substructures.

`Syntax` and `Structure` wrap SourceKitten primitives and their identical counterparts.

## Querying

There are three query types for each disassembled source code view (or context): `FragmentQuery`, `SyntaxQuery` and `StructureQuery`. Queries are accessible from `Disassembly` object under `query` property.

All queries share common characteristics:

- They all use predicates to filter out current selection and create subqueries.
- All queries also conform to `Collection` protocol and allow the use of subscripts.
- Query extensions provide convenient matchers for basic operations, but custom predicates can be used for more complex scenarios.

And properties:

- `disassembly` - references the `Disassembly` instance.
- `selection` - initial query selection set to be queried.
- `one` – first selected element, can be `nil`.
- `all` - entire query selection, can be empty.

## Editing

`Edit` object provides editing instruction (insert, replace or delete) and applies the instruction to a given string. `Edit` object comes with a [convenience initializers](/source/Slang/Source/Source.Edit.swift#L8-L26) and provides `String` extensions for directly applying single or multiple edits.

## Motivation

[SourceKitten](https://github.com/jpsim/SourceKitten) provides the necessary tools to digest Swift code into structured output. However, any further analysis and source manipulations must be done by hand with lots of boilerplate. Slang aims to provide extensible framework and structure for Swift source parsing, extraction, and manipulation.

## Installation

#### Carthage

Add Slang to your `Cartfile`:

```
github "Swifteroid/Slang" ~> 0.1
```

#### Swift Package Manager

Add Slang as a dependency of your package in `Package.swift`:

```swift
.package(url: "https://github.com/Swifteroid/Slang.git", from: "0.1.0")
```
