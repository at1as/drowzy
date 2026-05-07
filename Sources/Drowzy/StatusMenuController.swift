import AppKit
import DrowzyCore

final class StatusMenuController: NSObject, NSMenuDelegate {
    private enum MenuTag {
        static let off = -1
        static let indefinite = 0
    }

    private let assertionController: PowerAssertionControlling
    private let menu = NSMenu()
    private let now: () -> Date
    private let statusItem: NSStatusItem

    private var mode: AwakeMode = .off
    private var updateTimer: Timer?

    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    init(
        assertionController: PowerAssertionControlling = PowerAssertionController(),
        now: @escaping () -> Date = Date.init
    ) {
        self.assertionController = assertionController
        self.now = now
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        super.init()

        configureMenu()
        configureStatusItem()
        observeSystemWake()
        rebuildMenu()
        updatePresentation()
    }

    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        shutDown()
    }

    func shutDown() {
        updateTimer?.invalidate()
        updateTimer = nil
        assertionController.deactivate()
    }

    func menuWillOpen(_ menu: NSMenu) {
        refreshState()
        rebuildMenu()
    }

    private func configureMenu() {
        menu.autoenablesItems = false
        menu.delegate = self
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else {
            return
        }

        button.imagePosition = .imageOnly
        button.toolTip = "Drowzy: Off"
        statusItem.menu = menu
    }

    private func observeSystemWake() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleSystemWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    private func rebuildMenu() {
        menu.removeAllItems()

        addDisabledItem("Drowzy")
        addDisabledItem(statusText())
        menu.addItem(.separator())

        addModeItem(title: "Off", tag: MenuTag.off, isSelected: mode == .off)
        addModeItem(title: "On Until Turned Off", tag: MenuTag.indefinite, isSelected: isIndefinite)

        menu.addItem(.separator())
        addDisabledItem("Delay Sleep")

        for delay in SleepDelay.allCases {
            addModeItem(
                title: delay.menuTitle,
                tag: delay.rawValue,
                isSelected: mode.selectedDelay == delay
            )
        }

        menu.addItem(.separator())
        menu.addItem(menuItem(title: "About Drowzy", action: #selector(showAboutPanel)))
        menu.addItem(menuItem(title: "Quit Drowzy", action: #selector(quit)))
    }

    private func addDisabledItem(_ title: String) {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        menu.addItem(item)
    }

    private func addModeItem(title: String, tag: Int, isSelected: Bool) {
        let item = menuItem(title: title, action: #selector(selectMode(_:)))
        item.tag = tag
        item.state = isSelected ? .on : .off
        menu.addItem(item)
    }

    private func menuItem(title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        item.isEnabled = true
        return item
    }

    @objc private func selectMode(_ sender: NSMenuItem) {
        switch sender.tag {
        case MenuTag.off:
            setMode(.off)
        case MenuTag.indefinite:
            setMode(.indefinite)
        default:
            guard let delay = SleepDelay(rawValue: sender.tag) else {
                return
            }

            setMode(.timed(delay, until: delay.endDate(from: now())))
        }

        rebuildMenu()
    }

    @objc private func showAboutPanel() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: "Drowzy",
            .applicationVersion: Bundle.main.releaseVersion,
            .version: Bundle.main.buildVersion,
            .credits: NSAttributedString(string: "A small macOS menu bar app for delaying idle sleep.")
        ])
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    @objc private func handleSystemWake() {
        refreshState()
        scheduleTimer()
    }

    private func setMode(_ newMode: AwakeMode) {
        if newMode == .off {
            assertionController.deactivate()
            mode = .off
            scheduleTimer()
            updatePresentation()
            return
        }

        do {
            try assertionController.activate(reason: assertionReason(for: newMode))
            mode = newMode
            scheduleTimer()
            updatePresentation()
        } catch {
            mode = .off
            scheduleTimer()
            updatePresentation()
            showAssertionError(error)
        }
    }

    private func scheduleTimer() {
        updateTimer?.invalidate()
        updateTimer = nil

        guard case let .timed(_, until) = mode else {
            return
        }

        let interval = max(1, min(30, until.timeIntervalSince(now())))
        let timer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            self?.timerFired()
        }

        RunLoop.main.add(timer, forMode: .common)
        updateTimer = timer
    }

    private func timerFired() {
        updateTimer = nil
        refreshState()
        scheduleTimer()
    }

    private func refreshState() {
        if mode.hasExpired(at: now()) {
            assertionController.deactivate()
            mode = .off
        }

        updatePresentation()
    }

    private func updatePresentation() {
        guard let button = statusItem.button else {
            return
        }

        button.image = StatusIconFactory.menuBarImage(for: mode)
        button.toolTip = toolTipText()
    }

    private func showAssertionError(_ error: Error) {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Drowzy could not delay sleep."
        alert.informativeText = error.localizedDescription
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private var isIndefinite: Bool {
        guard case .indefinite = mode else {
            return false
        }

        return true
    }

    private func statusText() -> String {
        switch mode {
        case .off:
            return "Off"
        case .indefinite:
            return "Keeping this Mac awake"
        case let .timed(delay, until):
            let remaining = SleepDelay.formattedRemaining(until.timeIntervalSince(now()))
            let endTime = timeFormatter.string(from: until)
            return "\(delay.shortTitle) selected, \(remaining) left until \(endTime)"
        }
    }

    private func toolTipText() -> String {
        switch mode {
        case .off:
            return "Drowzy: Off"
        case .indefinite:
            return "Drowzy: On until turned off"
        case let .timed(_, until):
            let remaining = SleepDelay.formattedRemaining(until.timeIntervalSince(now()))
            return "Drowzy: \(remaining) remaining"
        }
    }

    private func assertionReason(for mode: AwakeMode) -> String {
        switch mode {
        case .off:
            return "Drowzy is off."
        case .indefinite:
            return "Drowzy is keeping this Mac awake until turned off."
        case let .timed(delay, _):
            return "Drowzy is delaying idle sleep for \(delay.menuTitle.lowercased())."
        }
    }
}

private extension Bundle {
    var releaseVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
    }

    var buildVersion: String {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
}
