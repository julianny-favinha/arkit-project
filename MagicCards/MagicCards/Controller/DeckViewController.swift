//
//  DeckViewController.swift
//  MagicCards
//
//  Created by Julianny Favinha on 7/16/18.
//  Copyright © 2018 Julianny Favinha. All rights reserved.
//

import UIKit

class DeckViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var deckSettings: DeckSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customTabBarController = self.tabBarController as! CustomTabBarController
        self.deckSettings = customTabBarController.deckSettings
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension DeckViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.deckSettings.deck.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deckCollectionViewCell", for: indexPath) as! DeckCollectionViewCell
        
        cell.image.image = UIImage(named: self.deckSettings.deck[indexPath.row].fileName)
        cell.name.text = self.deckSettings.deck[indexPath.row].name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.deckSettings.card = indexPath.row
        tabBarController?.selectedIndex = 0
    }
    
}
