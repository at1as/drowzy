import XCTest
@testable import DrowzyCore

final class SleepDelayTests: XCTestCase {
    func testDelayDurationsMatchMenuOptions() {
        XCTAssertEqual(SleepDelay.tenMinutes.seconds, 600)
        XCTAssertEqual(SleepDelay.thirtyMinutes.seconds, 1_800)
        XCTAssertEqual(SleepDelay.oneHour.seconds, 3_600)
        XCTAssertEqual(SleepDelay.twoHours.seconds, 7_200)
        XCTAssertEqual(SleepDelay.fiveHours.seconds, 18_000)
    }

    func testMenuTitlesAreHumanReadable() {
        XCTAssertEqual(
            SleepDelay.allCases.map(\.menuTitle),
            ["10 Minutes", "30 Minutes", "1 Hour", "2 Hours", "5 Hours"]
        )
    }

    func testEndDateAddsDelayToStartDate() {
        let startDate = Date(timeIntervalSince1970: 1_700_000_000)

        XCTAssertEqual(
            SleepDelay.twoHours.endDate(from: startDate),
            Date(timeIntervalSince1970: 1_700_007_200)
        )
    }

    func testRemainingTimeFormatting() {
        XCTAssertEqual(SleepDelay.formattedRemaining(0), "0m")
        XCTAssertEqual(SleepDelay.formattedRemaining(1), "1m")
        XCTAssertEqual(SleepDelay.formattedRemaining(60), "1m")
        XCTAssertEqual(SleepDelay.formattedRemaining(61), "2m")
        XCTAssertEqual(SleepDelay.formattedRemaining(3_600), "1h")
        XCTAssertEqual(SleepDelay.formattedRemaining(3_660), "1h 1m")
        XCTAssertEqual(SleepDelay.formattedRemaining(18_000), "5h")
    }

    func testTimedModeExpiresAtEndDate() {
        let startDate = Date(timeIntervalSince1970: 1_700_000_000)
        let mode = AwakeMode.timed(.tenMinutes, until: SleepDelay.tenMinutes.endDate(from: startDate))

        XCTAssertFalse(mode.hasExpired(at: startDate))
        XCTAssertEqual(mode.remaining(at: startDate), 600)
        XCTAssertTrue(mode.hasExpired(at: startDate.addingTimeInterval(600)))
        XCTAssertEqual(mode.remaining(at: startDate.addingTimeInterval(601)), 0)
    }
}
