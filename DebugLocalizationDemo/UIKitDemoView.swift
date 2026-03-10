import SwiftUI
import DebugLocalizationCore

struct UIKitDemoView: UIViewControllerRepresentable {
    let localizer: DebugLocalizer

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = UIKitDemoViewController(localizer: localizer)
        return UINavigationController(rootViewController: controller)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
