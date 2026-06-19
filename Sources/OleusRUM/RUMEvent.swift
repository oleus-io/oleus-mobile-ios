import Foundation

public enum RUMEventType: String, Codable {
    case sessionStart   = "session_start"
    case sessionEnd     = "session_end"
    case viewStart      = "view_start"
    case viewEnd        = "view_end"
    case action         = "action"
    case resource       = "resource"       // network request
    case error          = "error"
    case crash          = "crash"
    case anr            = "anr"
    case replay         = "replay_segment"
}

public struct RUMEvent: Codable {
    public var type: RUMEventType
    public var sessionId: String
    public var viewId: String?
    public var timestamp: Double           // Unix ms
    public var platform: String = "ios"
    public var appVersion: String
    public var osVersion: String
    public var deviceModel: String
    public var attributes: [String: AnyCodable]

    enum CodingKeys: String, CodingKey {
        case type, sessionId = "session_id", viewId = "view_id",
             timestamp, platform, appVersion = "app_version",
             osVersion = "os_version", deviceModel = "device_model",
             attributes
    }
}

// Minimal type-erased codable value
public struct AnyCodable: Codable {
    public let value: Any
    public init(_ value: Any) { self.value = value }
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(Bool.self)   { self.value = v; return }
        if let v = try? c.decode(Int.self)    { self.value = v; return }
        if let v = try? c.decode(Double.self) { self.value = v; return }
        if let v = try? c.decode(String.self) { self.value = v; return }
        self.value = ""
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch value {
        case let v as Bool:   try c.encode(v)
        case let v as Int:    try c.encode(v)
        case let v as Double: try c.encode(v)
        case let v as String: try c.encode(v)
        default: try c.encode(String(describing: value))
        }
    }
}
