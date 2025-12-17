// MARK: - StatusItem.swift
// Menu bar status item controller.
// Manages the popover display, icon updates, and menu bar title.
// Updated for macOS 26 Tahoe with transparent menu bar support.

import SwiftUI

// MARK: - Constants

private let digitFont = NSFont.monospacedDigitSystemFont(ofSize: 0, weight: .medium)
private let popoverWidth: CGFloat = 320

// MARK: - TBStatusItem

class TBStatusItem: NSObject, NSApplicationDelegate {
    private var popover = NSPopover()
    private var statusBarItem: NSStatusItem?
    static var shared: TBStatusItem!

    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(_: Notification) {
        let view = TBPopoverView()

        popover.behavior = .transient
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: view)

        if let contentViewController = popover.contentViewController {
            popover.contentSize.height = contentViewController.view.intrinsicContentSize.height
            popover.contentSize.width = popoverWidth
        }

        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.imagePosition = .imageLeft
        setIcon(name: .idle)
        statusBarItem?.button?.action = #selector(TBStatusItem.togglePopover(_:))
    }

    // MARK: - Public Methods

    func setTitle(title: String?) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.9
        paragraphStyle.alignment = NSTextAlignment.center

        let attributedTitle = NSAttributedString(
            string: title != nil ? " \(title!)" : "",
            attributes: [
                NSAttributedString.Key.font: digitFont,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )
        statusBarItem?.button?.attributedTitle = attributedTitle
    }

    func setIcon(name: NSImage.Name) {
        if let image = NSImage(named: name) {
            // Ensure template rendering for transparent menu bar support in macOS 26
            image.isTemplate = true
            statusBarItem?.button?.image = image
        }
    }

    func showPopover(_: AnyObject?) {
        guard let button = statusBarItem?.button else { return }
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
}
