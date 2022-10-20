//
//  STPAnalyticsClient+PaymentSheetTests.swift
//  StripeApplePayTests
//

import Foundation
import XCTest
@_spi(STP) @testable import StripePaymentSheet
@_spi(STP) @testable import StripeCore

class STPAnalyticsClientPaymentSheetTest: XCTestCase {
    func testPaymentSheetSDKVariantPayload() throws {
        // setup
        let analytic = PaymentSheetAnalytic(
            event: .paymentMethodCreation,
            productUsage: [],
            additionalParams: [:]
        )
        let client = STPAnalyticsClient()
        let payload = client.payload(from: analytic)
        XCTAssertEqual("paymentsheet", payload["pay_var"] as? String)
    }
}