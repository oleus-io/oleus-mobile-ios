#if canImport(UIKit)
import UIKit

final class ViewTracker {
    private let sdk: OleusRUM
    private var currentViewId: String?
    private var currentViewName: String?
    private var viewStartTime: Date?

    init(sdk: OleusRUM) {
        self.sdk = sdk
        swizzleViewControllerLifecycle()
    }

    private func swizzleViewControllerLifecycle() {
        let original = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewDidAppear(_:)))!
        let swizzled = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.oleus_viewDidAppear(_:)))!
        method_exchangeImplementations(original, swizzled)

        let originalDisappear = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewDidDisappear(_:)))!
        let swizzledDisappear = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.oleus_viewDidDisappear(_:)))!
        method_exchangeImplementations(originalDisappear, swizzledDisappear)
    }
}

extension UIViewController {
    @objc func oleus_viewDidAppear(_ animated: Bool) {
        oleus_viewDidAppear(animated)  // calls original
        let name = String(describing: type(of: self))
        OleusRUM.shared?.trackViewStart(name: name)
    }

    @objc func oleus_viewDidDisappear(_ animated: Bool) {
        oleus_viewDidDisappear(animated)
        let name = String(describing: type(of: self))
        OleusRUM.shared?.trackViewEnd(name: name)
    }
}
#endif
