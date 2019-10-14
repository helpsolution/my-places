//
//  MainViewController.swift
//  MyPlaces
//
//  Created by freelance on 07/10/2019.
//  Copyright © 2019 freelance. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    
    var places: Results<Place>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]


        cell.nameLabel?.text = place.name
        cell.locationLabel?.text = place.location
        cell.typeLabel?.text = place.type
        cell.imgeOfPlace.image = UIImage(data: place.imageData!)

        cell.imgeOfPlace?.layer.cornerRadius = cell.imgeOfPlace.frame.height / 2
        cell.imgeOfPlace?.clipsToBounds = true

        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else {
            print ("Error customization newPlaceVC")
            return
        }
        
        newPlaceVC.savePlace()
        
        tableView.reloadData()
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete"){(_,_) in
            
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return [deleteAction]
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetails" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let place = places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

}
