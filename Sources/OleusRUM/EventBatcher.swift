import Foundation

actor EventBatcher {
    private var batch: [RUMEvent] = []
    private let config: OleusConfiguration
    private var flushTask: Task<Void, Never>?

    init(config: OleusConfiguration) {
        self.config = config
    }

    func start() {
        flushTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(config.flushIntervalSeconds * 1_000_000_000))
                await flush()
            }
        }
    }

    func enqueue(_ event: RUMEvent) async {
        batch.append(event)
        if batch.count >= config.batchSize {
            await flush()
        }
    }

    func flush() async {
        guard !batch.isEmpty else { return }
        let payload = batch
        batch.removeAll()
        await send(events: payload)
    }

    private func send(events: [RUMEvent]) async {
        guard let url = URL(string: "\(config.endpoint)/v1/mobile-rum/ingest") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(config.apiKey, forHTTPHeaderField: "X-Oleus-API-Key")
        guard let body = try? JSONEncoder().encode(["events": events]) else { return }
        req.httpBody = body
        for attempt in 1...3 {
            do {
                let (_, response) = try await URLSession.shared.data(for: req)
                if let http = response as? HTTPURLResponse, http.statusCode < 300 { return }
            } catch {
                if attempt == 3 { print("[OleusRUM] flush failed after 3 attempts: \(error)") }
                try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
            }
        }
    }
}
