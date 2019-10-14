//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by freelance on 09/10/2019.
//  Copyright © 2019 freelance. All rights reserved.
//

import RealmSwift

class Place : Object{
    
    @objc dynamic var name = ""
    @objc dynamic var location : String?
    @objc dynamic var type : String?
    @objc dynamic var imageData : Data?
    
    let restaurantNames = [
            "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
            "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
            "Speak Easy", "Morris Pub", "Вкусные истории",
            "Классик", "Love&Life", "Шок", "Бочка"
        ]

    func savePlaces() {
    
        
        for place in restaurantNames {
            let newPlace = Place()
            
            newPlace.name = place
            newPlace.location = "Moscow"
            newPlace.type = "Restaurant"
            guard let imageData = UIImage(named: place)?.pngData() else{return}
            
            newPlace.imageData = imageData
            
            StorageManager.saveObject(newPlace)
        }
        
    }
    
}
