//
//  ChatViewInteractionWithSwiftUI.swift
//  Manifеst
//
//  Created by Нурдаулет Даулетхан on 15.01.2025.
//

import UIKit
import SwiftUI

class ChatViewInteractionWithSwiftUI: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let chatView = ChatView()
        let hostingController = UIHostingController(rootView: chatView)
        
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
