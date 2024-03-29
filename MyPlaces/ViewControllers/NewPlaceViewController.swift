//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by freelance on 09/10/2019.
//  Copyright © 2019 freelance. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    var imageIsChanged = false
    
    var currentPlace : Place!
    
    @IBOutlet weak var imageOfPlace: UIImageView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var placeName: UITextField!
    
    @IBOutlet weak var placeLocation: UITextField!
    
    @IBOutlet weak var placeType: UITextField!
    
    @IBOutlet weak var ratingController: RatingController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1) )
        
        placeName.addTarget(self, action: #selector(nameFieldChanged), for: .editingChanged)
        
        setupEditScreen()
    }

    //MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0{
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let actionSheet = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default){_ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction (title: "Photo ", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            let identifier = segue.identifier,
            let mapVC = segue.destination as? MapViewController
            else { return }
        
        mapVC.incomeSegueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        
        
        if identifier == "showPlace" {
            
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text
            mapVC.place.type = placeType.text
            mapVC.place.imageData = imageOfPlace.image?.pngData()
        }
        
        
        
    }
    
    func savePlace(){
        
        var image : UIImage?
        
        if imageIsChanged {
            image = imageOfPlace.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
        let newPlace = Place()
        
        newPlace.name = placeName.text!
        newPlace.location = placeLocation.text
        newPlace.type = placeType.text
        newPlace.imageData = image?.pngData()
        newPlace.rating = Double(ratingController.rating)

        if currentPlace != nil{
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
        
    }
    
    private func setupEditScreen(){
        if currentPlace != nil{
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {
                return
            }
            
            setupNavigationBar()
            
            imageIsChanged = true
            
            imageOfPlace.image = image
            imageOfPlace.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            
            ratingController.rating = Int(currentPlace.rating)
        }
    }
    
    private func setupNavigationBar(){
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
}

//MARK: Text field delegate
extension NewPlaceViewController: UITextFieldDelegate{
    
    //hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func nameFieldChanged(){
        if placeName.text?.isEmpty == false{
            saveButton.isEnabled = true
        } else{
             saveButton.isEnabled = false
        }
    }
}


//MARK: Work with image
extension NewPlaceViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func chooseImagePicker(source : UIImagePickerController.SourceType){
        
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
 
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageOfPlace.image = info[.editedImage] as? UIImage
        imageOfPlace.contentMode = .scaleAspectFill
        imageOfPlace.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
    
}

extension NewPlaceViewController : MapViewControllerDelegate {
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
    
    
}
