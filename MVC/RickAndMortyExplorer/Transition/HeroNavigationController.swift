//
//  HeroNavigationController.swift
//  RickAndMortyExplorer
//
//  Created by Toly on 29.09.2025.
//

import UIKit

final class HeroNavigationController: UINavigationController, UINavigationControllerDelegate {
    var originFrame: CGRect = .zero
    var originImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return HeroTransition(presenting: operation == .push, originFrame: originFrame, originImage: originImage)
    }
}
