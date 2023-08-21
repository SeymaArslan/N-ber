//
//   GlobalFunctions.swift
//  N-ber
//
//  Created by Seyma on 21.08.2023.
//

import Foundation

func fileNameFrom(fileUrl: String) -> String {
    return ((fileUrl.components(separatedBy: "_").last)!.components(separatedBy: "?").first!).components(separatedBy: ".").first!
}
