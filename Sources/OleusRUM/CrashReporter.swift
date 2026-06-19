import Foundation

final class CrashReporter {
    private let sdk: OleusRUM

    init(sdk: OleusRUM) {
        self.sdk = sdk
        install()
    }

    private func install() {
        // NSException handler
        NSSetUncaughtExceptionHandler { exception in
            CrashReporter.handleException(exception)
        }
        // Signal handlers
        for sig in [SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGPIPE, SIGTRAP] {
            signal(sig) { signo in
                CrashReporter.handleSignal(signo)
            }
        }
    }

    private static func handleException(_ exception: NSException) {
        let report: [String: Any] = [
            "exception_name":   exception.name.rawValue,
            "reason":           exception.reason ?? "",
            "call_stack":       exception.callStackSymbols.joined(separator: "\n"),
            "crash_type":       "exception",
        ]
        OleusRUM.shared?.trackCrash(report: report)
        OleusRUM.shared?.flushSync()
    }

    private static func handleSignal(_ signal: Int32) {
        let report: [String: Any] = [
            "signal":     signal,
            "crash_type": "signal",
            "call_stack": Thread.callStackSymbols.joined(separator: "\n"),
        ]
        OleusRUM.shared?.trackCrash(report: report)
        OleusRUM.shared?.flushSync()
    }
}
