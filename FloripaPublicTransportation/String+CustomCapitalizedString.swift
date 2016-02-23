//
//  String+CustomCapitalizedString.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/23/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import Foundation

let capitalNames = ["TITRI", "TICEN", "TICAN", "TISAN"]

extension String {
    var customCapitalizedString: String {
        var capitalized = self.capitalizedString
        
        for capitalName in capitalNames {
            capitalized =
                capitalized.stringByReplacingOccurrencesOfString(capitalName.capitalizedString, withString: capitalName)
        }
        
        // @todo Uncomment below when Swift starts to support \U in replacement template
        // This will allow to have capital letters after apostrophes, such as Gama D'Eça
        /*let characterAfterApostropheRegex = try! NSRegularExpression(pattern: "\\'\\w{1}", options: .CaseInsensitive)
        capitalized = characterAfterApostropheRegex.stringByReplacingMatchesInString(capitalized, options: [], range: NSMakeRange(0, capitalized.characters.count), withTemplate: "\\U$0")*/
        
        return capitalized
    }
}