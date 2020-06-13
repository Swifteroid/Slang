import Foundation
import Quick

internal class Spec: QuickSpec {
}

/// Runs the shell command and returns stdout + stderr.
internal func shell(_ command: String) throws -> String {
    let process: Process = Process()
    let pipe: Pipe = Pipe()
    process.launchPath = "/usr/bin/env"
    process.arguments = ["bash", "-c", command]
    process.standardOutput = pipe
    process.standardError = pipe
    try process.run()
    return String(decoding: try pipe.fileHandleForReading.readToEnd() ?? Data(), as: UTF8.self)
}

/// Runs the shell command and returns the entire stdout + stderr output truncated on the end.
internal func shell(line command: String) throws -> String { try shell(command).trimmingTrailingCharacters(in: .newlines) }
/// Runs the shell command and returns the entire stdout + stderr output truncated on the end and split into lines.
internal func shell(lines command: String) throws -> [String] { try shell(command).trimmingTrailingCharacters(in: .newlines).components(separatedBy: .newlines) }
