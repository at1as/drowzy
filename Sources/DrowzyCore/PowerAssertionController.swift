import Foundation
import IOKit.pwr_mgt

public protocol PowerAssertionControlling: AnyObject {
    var isActive: Bool { get }

    func activate(reason: String) throws
    func deactivate()
}

public enum PowerAssertionError: Error, Equatable, LocalizedError {
    case creationFailed(code: IOReturn)

    public var errorDescription: String? {
        switch self {
        case let .creationFailed(code):
            "IOKit could not create a no-idle-sleep assertion. Error code: \(code)."
        }
    }
}

public final class PowerAssertionController: PowerAssertionControlling {
    private var assertionID = IOPMAssertionID(0)

    public private(set) var isActive = false

    public init() {}

    deinit {
        deactivate()
    }

    public func activate(reason: String) throws {
        deactivate()

        var newAssertionID = IOPMAssertionID(0)
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason as CFString,
            &newAssertionID
        )

        guard result == kIOReturnSuccess else {
            throw PowerAssertionError.creationFailed(code: result)
        }

        assertionID = newAssertionID
        isActive = true
    }

    public func deactivate() {
        guard isActive else {
            return
        }

        IOPMAssertionRelease(assertionID)
        assertionID = IOPMAssertionID(0)
        isActive = false
    }
}
