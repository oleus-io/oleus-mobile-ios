import Foundation

final class OleusURLProtocol: URLProtocol {
    private var task: URLSessionDataTask?
    private var startTime: Date = Date()

    override class func canInit(with request: URLRequest) -> Bool {
        guard URLProtocol.property(forKey: "OleusHandled", in: request) == nil else { return false }
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        var mutable = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: "OleusHandled", in: mutable)

        // Inject W3C traceparent
        let traceId = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        let spanId  = String(format: "%016llx", UInt64.random(in: 0..<UInt64.max))
        mutable.setValue("00-\(traceId)-\(spanId)-01", forHTTPHeaderField: "traceparent")

        startTime = Date()
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        task = session.dataTask(with: mutable as URLRequest) { [weak self] data, response, error in
            guard let self else { return }
            let duration = Date().timeIntervalSince(self.startTime) * 1000
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            OleusRUM.shared?.trackResource(
                url: self.request.url?.absoluteString ?? "",
                method: self.request.httpMethod ?? "GET",
                statusCode: status,
                durationMs: duration,
                traceId: traceId,
                spanId: spanId
            )
            if let error { self.client?.urlProtocol(self, didFailWithError: error) }
            else {
                if let data { self.client?.urlProtocol(self, didLoad: data) }
                self.client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }
        task?.resume()
    }

    override func stopLoading() { task?.cancel() }
}
