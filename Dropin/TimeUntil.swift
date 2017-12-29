//
//  TimeAgo.swift
//  Dropin
//
//  Created by Christopher Pratt on 10/27/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import Foundation

struct DateComponentUnitFormatter {
    
    private struct DateComponentUnitFormat {
        let unit: Calendar.Component
        
        let singularUnit: String
        let pluralUnit: String
        
        let futureSingular: String
        let pastSingular: String
    }
    
    private let formats: [DateComponentUnitFormat] = [
        
        DateComponentUnitFormat(unit: .year,
                                singularUnit: "year",
                                pluralUnit: "years",
                                futureSingular: "next year",
                                pastSingular: "last year"),
        
        DateComponentUnitFormat(unit: .month,
                                singularUnit: "month",
                                pluralUnit: "months",
                                futureSingular: "next month",
                                pastSingular: "last month"),
        
        DateComponentUnitFormat(unit: .weekOfYear,
                                singularUnit: "week",
                                pluralUnit: "weeks",
                                futureSingular: "next week",
                                pastSingular: "last week"),
        
        DateComponentUnitFormat(unit: .day,
                                singularUnit: "day",
                                pluralUnit: "days",
                                futureSingular: "tomorrow",
                                pastSingular: "yesterday"),
        
        DateComponentUnitFormat(unit: .hour,
                                singularUnit: "hr",
                                pluralUnit: "hrs",
                                futureSingular: "an hr",
                                pastSingular: "an hr ago"),
        
        DateComponentUnitFormat(unit: .minute,
                                singularUnit: "min",
                                pluralUnit: "mins",
                                futureSingular: "a min",
                                pastSingular: "a min ago"),
        
        DateComponentUnitFormat(unit: .second,
                                singularUnit: "sec",
                                pluralUnit: "secs",
                                futureSingular: "just now",
                                pastSingular: "just now"),
        
        ]
    
    func string(forDateComponents dateComponents: DateComponents, useNumericDates: Bool) -> String {
        for format in self.formats {
            let unitValue: Int
            
            switch format.unit {
            case .year:
                unitValue = dateComponents.year ?? 0
            case .month:
                unitValue = dateComponents.month ?? 0
            case .weekOfYear:
                unitValue = dateComponents.weekOfYear ?? 0
            case .day:
                unitValue = dateComponents.day ?? 0
            case .hour:
                unitValue = dateComponents.hour ?? 0
            case .minute:
                unitValue = dateComponents.minute ?? 0
            case .second:
                unitValue = dateComponents.second ?? 0
            default:
                assertionFailure("Date does not have requried components")
                return ""
            }
            
            switch unitValue {
            case 2 ..< Int.max:
                return "\(unitValue) \(format.pluralUnit) ago"
            case 1:
                return useNumericDates ? "\(unitValue) \(format.singularUnit) ago" : format.pastSingular
            case -1:
                return useNumericDates ? "\(-unitValue) \(format.singularUnit)" : format.futureSingular
            case Int.min ..< -1:
                return "\(-unitValue) \(format.pluralUnit)"
            default:
                break
            }
        }
        
        return "just now"
    }
}

extension Date {
    func timeAgoSinceNow(useNumericDates: Bool = false) -> String {
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()

        let components = calendar.dateComponents(unitFlags, from: self, to: now)
        
        let formatter = DateComponentUnitFormatter()
        return formatter.string(forDateComponents: components, useNumericDates: useNumericDates)
    }
}
