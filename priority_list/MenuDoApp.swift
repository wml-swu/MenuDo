//
//  MenuDoApp.swift
//  MenuDo
//
//  Created by 大大怪将军 on 2026/2/1.
//

import SwiftUI

@main
struct MenuDoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
