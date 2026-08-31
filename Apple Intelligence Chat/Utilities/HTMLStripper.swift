//
//  HTMLStripper.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

import Foundation

enum HTMLStripper {

    static func strip(_ html: String) -> String {
        var text = html

        while let start = text.range(of: "<"),
              let end = text.range(of: ">", range: start.lowerBound..<text.endIndex) {
            text.removeSubrange(start.lowerBound...end.upperBound)
        }

        return text
    }

    static func excerpt(_ html: String, maxLength: Int = 800) -> String {
        String(strip(html).prefix(maxLength))
    }
}
