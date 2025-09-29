//
//  HeroTransition.swift
//  RickAndMortyExplorer
//
//  Created by Toly on 29.09.2025.
//

import UIKit

final class HeroTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.6
    let presenting: Bool
    var originFrame: CGRect
    var originImage: UIImage?

    init(presenting: Bool, originFrame: CGRect, originImage: UIImage? = nil) {
        self.presenting = presenting
        self.originFrame = originFrame
        self.originImage = originImage
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { duration }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }

        // Snapshot image view
        let snapshot = UIImageView(image: originImage ?? fromVC.view.snapshot())
        snapshot.contentMode = .scaleAspectFill
        snapshot.clipsToBounds = true
        snapshot.layer.cornerRadius = presenting ? 8 : 0
        snapshot.layer.masksToBounds = true

        let initialFrame = presenting ? originFrame : fromVC.view.frame
        let finalFrame = presenting ? toVC.view.frame : originFrame
        snapshot.frame = initialFrame

        let dimView = UIView(frame: container.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(presenting ? 0 : 0.3)

        if presenting {
            container.addSubview(toVC.view)
            toVC.view.alpha = 0
            container.addSubview(dimView)
            container.addSubview(snapshot)
        } else {
            container.insertSubview(toVC.view, belowSubview: fromVC.view)
            container.addSubview(dimView)
            container.addSubview(snapshot)
            fromVC.view.alpha = 1
        }

        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0.6,
                       options: [.curveEaseInOut]) {
            snapshot.frame = finalFrame
            snapshot.layer.cornerRadius = self.presenting ? 0 : 8
            dimView.backgroundColor = UIColor.black.withAlphaComponent(self.presenting ? 0.3 : 0)
            if self.presenting {
                toVC.view.alpha = 1
            } else {
                fromVC.view.alpha = 0
            }
        } completion: { _ in
            snapshot.removeFromSuperview()
            dimView.removeFromSuperview()
            if !self.presenting {
                fromVC.view.alpha = 1
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

private extension UIView {
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let snap = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return snap
    }
}
