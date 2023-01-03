//
//  GoogleSignInButton.swift
//  PassSafe
//
//  Created by Hamd Waseem on 01/01/2023.
//

import SwiftUI
import GoogleSignIn

struct GoogleSignInButton: UIViewRepresentable {
  @Environment(\.colorScheme) var colorScheme
  
    private var button = GIDSignInButton()

  func makeUIView(context: Context) -> GIDSignInButton {
      button.colorScheme = colorScheme == .dark ? .dark : .light
      button.style = .wide
      return button
  }

  func updateUIView(_ uiView: UIViewType, context: Context) {
      button.colorScheme = colorScheme == .dark ? .dark : .light
  }
}
