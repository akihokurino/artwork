import SwiftUI
import UIKit

func randfloat(min: CGFloat, max: CGFloat) -> CGFloat {
    let random = CGFloat.random(in: 0 ..< 1)
    return floor(random * (max - min + 1)) + min
}

func randfloat(_ num: CGFloat) -> CGFloat {
    let random = CGFloat.random(in: 0 ..< 1)
    return random * num - num * 0.5
}

func centerPoint() -> CGPoint {
    return CGPoint(x: canvasWidth() / 2, y: canvasHeight() / 2)
}

func canvasWidth() -> CGFloat {
    return UIScreen.main.bounds.width
}

func canvasHeight() -> CGFloat {
    return UIScreen.main.bounds.height
}

func screenshot(rect: CGRect) -> UIImage? {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = scene.windows.first(where: { $0.isKeyWindow }),
          let topViewController = window.rootViewController?.topMostViewController()
    else {
        return nil
    }
    return topViewController.view.getImage(rect: rect)
}

struct RectangleGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { geometry in
            self.createView(proxy: geometry)
        }
    }

    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = proxy.frame(in: .global)
        }
        return Rectangle().fill(Color.clear)
    }
}

struct HeaderLayer: View {
    let dismiss: () -> Void
    let reset: () -> Void

    var body: some View {
        VStack {
            Spacer().frame(height: 60)
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                }
                Spacer()
                Button(action: {
                    reset()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                }
            }
            .padding(16)
            Spacer()
        }
    }
}

extension Shape {
    func fillAndStroke<S: ShapeStyle>(
        _ fillContent: S,
        strokeContent: S,
        strokeStyle: StrokeStyle
    ) -> some View {
        ZStack {
            self.fill(fillContent)
            self.stroke(strokeContent, style: strokeStyle)
        }
    }
}

extension UIView {
    func getImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        } else if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        } else if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
}
