//
//  MainViewController.swift
//  MyPlaces
//
//  Created by freelance on 07/10/2019.
//  Copyright © 2019 freelance. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    let places = Place.getPlaces()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        cell.nameLabel?.text = places[indexPath.row].name
        cell.locationLabel?.text = places[indexPath.row].location
        cell.typeLabel?.text = places[indexPath.row].type
        
        cell.imgeOfPlace?.image = UIImage(named: places[indexPath.row].image)
        cell.imgeOfPlace?.layer.cornerRadius = cell.imgeOfPlace.frame.height / 2
        cell.imgeOfPlace?.clipsToBounds = true
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    @IBAction func cancelAction(_ segue: UIStoryboardSegue) {}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
