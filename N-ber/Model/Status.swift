//
//  Status.swift
//  N-ber
//
//  Created by Seyma on 21.08.2023.
//

import Foundation

enum Status: String, CaseIterable { // we have static array and append every object in there, and we are delete this arrayList and instead of doing that, we can just confirm to protocol of CaseIterable, which will give us access of an array with all these items of our struct
    
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
    
}

// So we dont have to write long array and put every extra every new item that we put inside.. So imagine tomorrow you come and write a new status here. You had to put it manually inside the array, otherwise it wouldnt be available.. but now with this CaseIterable protocol here, we just can do whatever we want and it's automatically available and will be saved in our user default
