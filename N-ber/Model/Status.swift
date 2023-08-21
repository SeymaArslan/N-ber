//
//  Status.swift
//  N-ber
//
//  Created by Seyma on 21.08.2023.
//

import Foundation

enum Status: String {
    case Available = "Müsait"
    case Busy = "Meşgul"
    case AtSchool = "Okulda"
    case AtTheMovies = "Sinemada"
    case AtWork = "İşte"
    case BatteryAboutToDie = "Pili bitmek üzere"
    case CantTalk = "Konuşamam"
    case InAMeeting = "Toplantıda"
    case AtTheGym = "Sporda"
    case Sleepig = "Uyuyor"
    case UrgentCallsOnly = "Yalnızca acil aramalar"
    
    static var array: [Status] {
        var a: [Status] = []
        
        switch Status.Available {
        case .Available:
            a.append(.Available); fallthrough
        case .Busy:
            a.append(.Busy); fallthrough
        case .AtSchool:
            a.append(.AtSchool); fallthrough
        case .AtTheMovies:
            a.append(.AtTheMovies); fallthrough
        case .AtWork:
            a.append(.AtWork); fallthrough
        case .BatteryAboutToDie:
            a.append(.BatteryAboutToDie); fallthrough
        case .CantTalk:
            a.append(.CantTalk); fallthrough
        case .InAMeeting:
            a.append(.InAMeeting); fallthrough
        case .AtTheGym:
            a.append(.AtTheGym); fallthrough
        case .Sleepig:
            a.append(.Sleepig); fallthrough
        case .UrgentCallsOnly:
            a.append(.UrgentCallsOnly);
            return a
        }
    }
}
