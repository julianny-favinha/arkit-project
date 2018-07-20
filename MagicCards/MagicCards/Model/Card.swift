//
//  Card.swift
//  MagicCards
//
//  Created by Julianny Favinha on 7/20/18.
//  Copyright © 2018 Julianny Favinha. All rights reserved.
//

import Foundation

class Card {
    
    var fileName: String
    var name: String
    var power: Int
    var resistence: Int
    
    init(fileName: String, name: String, power: Int, resistence: Int) {
        self.fileName = fileName
        self.name = name
        self.power = power
        self.resistence = resistence
    }
    
}
