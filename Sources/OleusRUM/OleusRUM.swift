import Foundation
#if canImport(UIKit)
import UIKit
#endif

public final class OleusRUM {
    public static var shared: OleusRUM?

    private let config: OleusConfiguration
    private let batcher: EventBatcher
    private var sessionId: String = UUID().uuidString
    private var currentViewId: String?
    private var currentViewName: String?
    private var appVersion: String
    private var osVersion: String
    private var deviceModel: String
    private var crashReporter: CrashReporter?
    private var viewTracker: ViewTracker?
    private var sessionReplay: SessionReplay?

    public static func start(configuration: OleusConfiguration) {
        let sdk = OleusRUM(configuration: configuration)
        shared = sdk
        sdk.boot()
    }

    private init(configuration: OleusConfiguration) {
        self.config = configuration
        self.batcher = EventBatcher(config: configuration)
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        osVersion  = ProcessInfo.processInfo.operatingSystemVersionString
        #if canImport(UIKit)
        deviceModel = UIDevice.current.model
        #else
        deviceModel = "mac"
        #endif
    }

    private func boot() {
        Task { await batcher.start() }
        guard Double.random(in: 0...1) < config.sessionSampleRate else { return }
        trackSessionStart()
        if config.crashReportingEnabled { crashReporter = CrashReporter(sdk: self) }
        if config.networkInstrumentationEnabled {
            URLProtocol.registerClass(OleusURLProtocol.self)
        }
        #if canImport(UIKit)
        viewTracker = ViewTracker(sdk: self)
        if config.sessionReplayEnabled && Double.random(in: 0...1) < config.sessionReplaySampleRate {
            sessionReplay = SessionReplay(sdk: self)
            sessionReplay?.start()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                                object: nil, queue: .main) { [weak self] _ in
            Task { await self?.batcher.flush() }
        }
        #endif
    }

    func trackSessionStart() {
        enqueue(event(type: .sessionStart, attributes: [:]))
    }

    public func trackAction(name: String, attributes: [String: Any] = [:]) {
        var attrs = attributes
        attrs["action_name"] = name
        enqueue(event(type: .action, attributes: attrs))
    }

    func trackViewStart(name: String) {
        currentViewId = UUID().uuidString
        currentViewName = name
        enqueue(event(type: .viewStart, attributes: ["view_name": name], viewId: currentViewId))
    }

    func trackViewEnd(name: String) {
        enqueue(event(type: .viewEnd, attributes: ["view_name": name], viewId: currentViewId))
        currentViewId = nil
    }

    func trackResource(url: String, method: String, statusCode: Int, durationMs: Double, traceId: String, spanId: String) {
        enqueue(event(type: .resource, attributes: [
            "url": url, "method": method, "status_code": statusCode,
            "duration_ms": durationMs, "trace_id": traceId, "span_id": spanId,
        ]))
    }

    func trackCrash(report: [String: Any]) {
        enqueue(event(type: .crash, attributes: report))
    }

    func trackReplayFrame(wireframe: [String: Any]) {
        enqueue(event(type: .replay, attributes: ["frame": wireframe]))
    }

    func flushSync() {
        // Called from crash handler — must be synchronous
        let sema = DispatchSemaphore(value: 0)
        Task { await batcher.flush(); sema.signal() }
        sema.wait(timeout: .now() + 5)
    }

    private func enqueue(event: RUMEvent) {
        Task { await batcher.enqueue(event) }
    }

    private func event(type: RUMEventType, attributes: [String: Any], viewId: String? = nil) -> RUMEvent {
        RUMEvent(
            type: type,
            sessionId: sessionId,
            viewId: viewId ?? currentViewId,
            timestamp: Date().timeIntervalSince1970 * 1000,
            appVersion: appVersion,
            osVersion: osVersion,
            deviceModel: deviceModel,
            attributes: attributes.mapValues { AnyCodable($0) }
        )
    }
}
