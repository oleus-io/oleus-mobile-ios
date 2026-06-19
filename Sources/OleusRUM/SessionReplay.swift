#if canImport(UIKit)
import UIKit

final class SessionReplay {
    private let sdk: OleusRUM
    private var timer: Timer?
    private let captureIntervalSeconds: TimeInterval = 2.0

    init(sdk: OleusRUM) { self.sdk = sdk }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: captureIntervalSeconds, repeats: true) { [weak self] _ in
            self?.captureFrame()
        }
    }

    func stop() { timer?.invalidate(); timer = nil }

    private func captureFrame() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        let wireframe = buildWireframe(view: window)
        sdk.trackReplayFrame(wireframe: wireframe)
    }

    private func buildWireframe(view: UIView) -> [String: Any] {
        var node: [String: Any] = [
            "type":   String(describing: type(of: view)),
            "frame":  ["x": view.frame.origin.x, "y": view.frame.origin.y,
                       "w": view.frame.size.width, "h": view.frame.size.height],
            "hidden": view.isHidden,
            "alpha":  view.alpha,
        ]
        // PII masking: blank out UITextField/UITextView/UILabel content
        if let label = view as? UILabel {
            node["text"] = label.isSensitive ? "[masked]" : label.text ?? ""
        } else if view is UITextField || view is UITextView {
            node["text"] = "[masked]"  // always mask input fields
        }
        node["children"] = view.subviews.map { buildWireframe(view: $0) }
        return node
    }
}

private extension UIView {
    var isSensitive: Bool {
        // Heuristic: if parent is a UITableViewCell or has "password"/"email"/"card" in accessibilityLabel
        let hint = accessibilityLabel?.lowercased() ?? ""
        return hint.contains("password") || hint.contains("card") || hint.contains("secret")
    }
}
#endif
