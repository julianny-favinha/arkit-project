//
//  CardNode.swift
//  MagicCards
//
//  Created by Julianny Favinha on 7/20/18.
//  Copyright © 2018 Julianny Favinha. All rights reserved.
//

import Foundation
import SceneKit

class CardNode: SCNNode {
    
    var card: Card
    
    init(card: Card) {
        self.card = card
        super.init()
        self.name = card.name
        
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
