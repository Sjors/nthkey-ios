//
//  SKProduct.swift
//  SKProduct
//
//  Repeated by Sergey Vinogradov on 16.05.2021.
//  Origin https://stackoverflow.com/a/56870047/1067147
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md


import Foundation

class PeriodFormatter {
    static var componentFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }

    static func format(unit: NSCalendar.Unit, numberOfUnits: Int) -> String? {
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        componentFormatter.allowedUnits = [unit]
        switch unit {
        case .day:
            dateComponents.setValue(numberOfUnits, for: .day)
        case .weekOfMonth:
            dateComponents.setValue(numberOfUnits, for: .weekOfMonth)
        case .month:
            dateComponents.setValue(numberOfUnits, for: .month)
        case .year:
            dateComponents.setValue(numberOfUnits, for: .year)
        default:
            return nil
        }

        return componentFormatter.string(from: dateComponents)
    }
}

import StoreKit

extension SKProduct {
    func formattedPrice() -> String {
      let formatter = NumberFormatter()
      formatter.numberStyle = .currency
      formatter.locale = self.priceLocale
      return formatter.string(from: self.price) ?? "\(self.price)"
    }
}

extension SKProduct.PeriodUnit {
    func toCalendarUnit() -> NSCalendar.Unit {
        switch self {
        case .day:
            return .day
        case .month:
            return .month
        case .week:
            return .weekOfMonth
        case .year:
            return .year
        @unknown default:
            debugPrint("Unknown period unit")
        }
        return .day
    }
}

extension SKProductSubscriptionPeriod {
    func localizedPeriod() -> String? {
        return PeriodFormatter.format(unit: unit.toCalendarUnit(), numberOfUnits: numberOfUnits)
    }
}
