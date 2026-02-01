//
//  priority_listApp.swift
//  priority_list
//
//  Created by 大大怪将军 on 2026/2/1.
//

import SwiftUI

@main
struct priority_listApp: App {
    var body: some Scene {
        // 菜单栏：点击图标在状态栏旁弹出四象限界面
        MenuBarExtra("Do it!", systemImage: "checkmark.square") {
            ContentView()
                .frame(minWidth: 720, minHeight: 760)
        }
        .menuBarExtraStyle(.window)

        // 保留窗口：可从菜单栏「打开窗口」或 Dock 启动
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 720, height: 760)
    }
}
