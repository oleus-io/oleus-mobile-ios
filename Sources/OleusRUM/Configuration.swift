import Foundation

public struct OleusConfiguration {
    public var apiKey: String
    public var endpoint: URL
    public var sessionSampleRate: Double        // 0.0–1.0, default 1.0
    public var sessionReplayEnabled: Bool       // default true
    public var sessionReplaySampleRate: Double  // default 0.1 (10%)
    public var networkInstrumentationEnabled: Bool  // default true
    public var crashReportingEnabled: Bool      // default true
    public var batchSize: Int                   // default 50
    public var flushIntervalSeconds: TimeInterval  // default 30

    public init(
        apiKey: String,
        endpoint: URL = URL(string: "https://api.internal.oleus.io")!,
        sessionSampleRate: Double = 1.0,
        sessionReplayEnabled: Bool = true,
        sessionReplaySampleRate: Double = 0.1,
        networkInstrumentationEnabled: Bool = true,
        crashReportingEnabled: Bool = true,
        batchSize: Int = 50,
        flushIntervalSeconds: TimeInterval = 30
    ) {
        self.apiKey = apiKey
        self.endpoint = endpoint
        self.sessionSampleRate = sessionSampleRate
        self.sessionReplayEnabled = sessionReplayEnabled
        self.sessionReplaySampleRate = sessionReplaySampleRate
        self.networkInstrumentationEnabled = networkInstrumentationEnabled
        self.crashReportingEnabled = crashReportingEnabled
        self.batchSize = batchSize
        self.flushIntervalSeconds = flushIntervalSeconds
    }
}
