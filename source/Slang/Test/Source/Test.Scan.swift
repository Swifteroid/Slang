import Foundation
import Nimble
import Quick
import Slang
import SourceKittenFramework

private let sample = """
import XCTest

class ExampleUITests: XCTestCase {
    override func setUp() {
        XCUIApplication().launch()
    }

    func testExamplePass() {
        testMethod(arg: ["T486"]) {
            XCTAssert(true)
        }
    }

    // @SmokeTest
    func testExampleTag() {
        tags(testTags: [
            .help,
            .regression
        ])

        report(territory: .uk, testCases: ["APP-T486", "APP-T486"]) {
            XCTAssert(true)
        }
    }

    func testExampleFail() {
        report(territory: .uk, testCases: ["APP-T486d", "APP-T486d"]) {
            XCTAssert(false)
        }
    }
}

class Example {
    func testExamplePass() {
        XCTAssert(true)
    }

    func testExampleTag() {
        let testCaseIdentifier = ["SmokeTest"]
        XCTAssert(true)
    }

    func testExampleFail() {
        XCTAssert(false)
    }
}
"""

private struct TestCase: Codable, Hashable {
    let name: String
    let suite: String
    let tags: [String]
    let testCaseIDs: [String]

    var testIdentifier: String { return "\(suite)/\(name)" }

    init(name: String, suite: String, tags: [String] = [], testCaseIDs: [String] = []) {
        self.name = name.replacingOccurrences(of: "()", with: "")
        self.suite = suite
        self.tags = tags
        self.testCaseIDs = testCaseIDs
    }
}

internal class SourceTestCaseSpec: QuickSpec {
    internal override func spec() {
        let disassembly = try! Disassembly(File(sample))
        let query = disassembly.query.structure

        let testClasses = query.descendants(where: { $0.conformsTo(class: "XCTestCase") })
        let testMethods = testClasses.children(where: { $0.functionName(startsWith: "test") })

        it("can parse test methods and test classes") {
            let listOfTestClasses = testClasses.all.compactMap { $0.name }
            let listOfTestMethods = testMethods.all.compactMap { $0.name.replacingOccurrences(of: "()", with: "") }

            expect(listOfTestClasses).to(contain(["ExampleUITests"]))
            expect(listOfTestMethods).to(contain(["testExamplePass", "testExampleTag", "testExampleFail"]))
        }

        it("can get testcase identifiers") {
            let listOfTestMethods = testMethods.children(where: { $0.closureName(contains: "report") })
            let testIDs = listOfTestMethods.children(where: { $0.argumentName(contains: "testCases") }).all.compactMap { $0.body }
            let testArg = listOfTestMethods.children(where: { $0.argumentName(contains: "territory") }).all.compactMap { $0.body }

            expect(testArg.first).to(contain([".uk"]))
            expect(testIDs.first?.convertToArray).to(contain(["APP-T486", "APP-T486"]))

            expect(testArg.last).to(contain([".uk"]))
            expect(testIDs.last?.convertToArray).to(contain(["APP-T486d", "APP-T486d"]))
        }

        it("can populate struct") {
            var result = [TestCase]()

            let output: [[TestCase]] = testClasses.compactMap { baseTestClass in
                guard let testClass = baseTestClass.one else {
                    return nil
                }

                guard let testSuite = testClass.name else {
                    return nil
                }
                
                let testMethods = baseTestClass.children(where: { $0.functionName(startsWith: "test") })

                return testMethods.compactMap { function in
                    guard let testMethod = function.one else {
                        return nil
                    }

                    guard let testName = testMethod.name else {
                        return nil
                    }

                    let testCaseIDs = function
                        .children(where: { $0.closureName(contains: "report") })
                        .children(where: { $0.argumentName(contains: "testCases") })
                        .one?.bodyCollection ?? []

                    let testTags = function
                        .children(where: { $0.closureName(contains: "tags") })
                        .children(where: { $0.argumentName(contains: "testTags") })
                        .one?.bodyCollection ?? []

                    return TestCase(name: testName, suite: testSuite, tags: testTags, testCaseIDs: testCaseIDs)
                }
            }

            result += output.flatMap { $0 }

            expect(result[0].name).to(contain("testExamplePass"))
            expect(result[0].testCaseIDs).to(contain([]))

            expect(result[1].name).to(contain("testExampleTag"))
            expect(result[1].testCaseIDs).to(contain(["APP-T486", "APP-T486"]))
            expect(result[1].tags).to(contain(["help", "regression"]))

            expect(result[2].name).to(contain("testExampleFail"))
            expect(result[2].testCaseIDs).to(contain(["APP-T486d", "APP-T486d"]))
        }
    }
}
