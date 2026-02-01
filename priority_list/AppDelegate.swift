//
//  AppDelegate.swift
//  priority_list
//
//  菜单栏图标：左键显示窗口（与 MenuBarExtra 一致），右键显示「退出」菜单（位置与系统一致）
//

import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var mainWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "checkmark.square", accessibilityDescription: "Do it!")
        statusItem?.button?.action = #selector(statusItemClicked)
        statusItem?.button?.target = self
        statusItem?.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        let contentView = ContentView()
        let hosting = NSHostingView(rootView: contentView)
        let size = NSSize(width: 720, height: 760)
        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        mainWindow?.contentView = hosting
        mainWindow?.isReleasedWhenClosed = false
        mainWindow?.title = "Do it!"
        // 禁止系统/用户对窗口缩放：固定内容尺寸，不可拖拽改变大小
        mainWindow?.contentMinSize = size
        mainWindow?.contentMaxSize = size
        mainWindow?.minSize = size
        mainWindow?.maxSize = size
    }

    @objc private func statusItemClicked(_ sender: Any?) {
        guard let event = NSApp.currentEvent else {
            showMainWindow()
            return
        }
        if event.type == .rightMouseUp {
            showQuitMenu()
        } else {
            showMainWindow()
        }
    }

    /// 图标在屏幕上的矩形（与系统对 MenuBarExtra/状态项定位一致）
    private func statusItemScreenRect() -> NSRect? {
        guard let button = statusItem?.button, let window = button.window else { return nil }
        let rectInWindow = button.convert(button.bounds, to: nil)
        return window.convertToScreen(rectInWindow)
    }

    /// 右键菜单：位置与左键窗口一致，与图标下方留相同 gap
    private func showQuitMenu() {
        let menu = NSMenu()
        let quitItem = NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        guard let rect = statusItemScreenRect() else { return }
        let gap: CGFloat = 4
        let menuTopLeft = NSPoint(x: rect.minX, y: rect.minY - gap)
        menu.popUp(positioning: nil, at: menuTopLeft, in: nil)
    }

    @objc private func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        guard let window = mainWindow, let screenRect = statusItemScreenRect() else {
            mainWindow?.makeKeyAndOrderFront(nil)
            return
        }
        let gap: CGFloat = 4
        let winSize = window.frame.size
        let x = screenRect.midX - winSize.width / 2
        let y = screenRect.minY - gap - winSize.height
        window.setFrameOrigin(NSPoint(x: x, y: y))
        window.makeKeyAndOrderFront(nil)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
