//
//  DeckSettings.swift
//  MagicCards
//
//  Created by Julianny Favinha on 7/16/18.
//  Copyright © 2018 Julianny Favinha. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

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

class CardNode: SCNNode {

    var card: Card
    
    init(card: Card) {
        self.card = card
        super.init()
        self.name = "Virtual object root node"
        
        let scene = SCNScene(named: "art.scnassets/card.scn")
        let child = (scene?.rootNode.childNode(withName: "card", recursively: false))!
        let imageMaterial = SCNMaterial()
        imageMaterial.isDoubleSided = false
        imageMaterial.diffuse.contents = UIImage(named: card.fileName)
        
        child.geometry?.materials[4] = imageMaterial
        self.addChildNode(child)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func isNodePartOfCardNode(_ node: SCNNode) -> Bool {
        if node.name == "CardNode root node" {
            return true
        }
        
        if node.parent != nil {
            return isNodePartOfCardNode(node.parent!)
        }
        
        return false
    }
    
}

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
    
}
