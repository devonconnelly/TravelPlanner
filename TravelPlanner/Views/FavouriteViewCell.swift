//
//  FavouriteViewCell.swift
//  TravelPlanner
//
//  Created by Devon Connelly on 2025-04-15.
//

import Foundation
import UIKit

class FavouriteViewCell: UICollectionViewCell {
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var favImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    var unfavoriteButtonAction: (() -> Void)?
    @IBAction func unfavouriteTapped(_ sender: Any) {
        unfavoriteButtonAction?()
    }
}
