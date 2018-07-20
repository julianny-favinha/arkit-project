//
//  DeckSettings.swift
//  MagicCards
//
//  Created by Julianny Favinha on 7/16/18.
//  Copyright © 2018 Julianny Favinha. All rights reserved.
//

import Foundation
import SceneKit

class DeckSettings {
    
    let deck: [Card] = [Card(fileName: "Anjo-da-Esperanca", name: "Anjo da Esperança", power: 8, resistence: 8),
                        Card(fileName: "Cataro-Fervoroso", name: "Cataro Fervoroso", power: 2, resistence: 1),
                        Card(fileName: "Dragao-das-Asas-Arqueadas", name: "Dragão das Asas Arqueadas", power: 4, resistence: 4),
                        Card(fileName: "Explorador-do-Brejolonge", name: "Explorador do Brejolonge", power: 2, resistence: 3),
                        Card(fileName: "Lobo-Errante", name: "Lobo Errante", power: 2, resistence: 1),
                        Card(fileName: "Mago-da-Forca-Confiavel", name: "Mago da Força Confiável", power: 2, resistence: 2)]
    
    var card: Int = 0
    
    func currentCardPiece() -> CardNode {
        let cardNode = CardNode(card: deck[card])
        return cardNode
    }
    
    func getCard(name: String) -> Card? {
        for card in deck where card.name == name {
            return card
        }
        
        return nil
    }
    
}
