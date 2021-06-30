//
//  CopyUILabel.swift
//  btcwallet
//
//  Created by Kazunori Tsuchiya on 2021/01/27.
//

import UIKit

class CopyUILabel: UILabel {
    @objc func handleLongPressGesture(_ recognizer: UIGestureRecognizer)
    {
        guard recognizer.state == .recognized else { return }

        if let recognizerView = recognizer.view, let recognizerSuperView = recognizerView.superview, recognizerView.becomeFirstResponder() {
            let menuController = UIMenuController.shared
            if #available(iOS 13.0, *) {
                menuController.showMenu(from: recognizerSuperView, rect: recognizerView.frame)
            } else {
                menuController.setTargetRect(recognizerView.frame, in: recognizerSuperView)
                menuController.setMenuVisible(true, animated: true)
            }
        }
    }
}
