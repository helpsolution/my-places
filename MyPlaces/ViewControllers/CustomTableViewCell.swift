//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by freelance on 09/10/2019.
//  Copyright © 2019 freelance. All rights reserved.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imgeOfPlace: UIImageView!{
        didSet{
            imgeOfPlace?.layer.cornerRadius = imgeOfPlace.frame.height / 2
            imgeOfPlace?.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
     
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var cosmosView: CosmosView!{
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
    
}
