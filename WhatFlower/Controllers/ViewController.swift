//
//  ViewController.swift
//  WhatFlower
//
//  Created by Omar Ashraf on 16/02/2024.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var flowerDescriptionTextLabel: UILabel!
    @IBOutlet weak var placeHolderTextLabel: UILabel!
    
    private let picker = UIImagePickerController()
    var session: URLSession?
    var flowerBrain = FlowerBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        session = URLSession(configuration: .default)
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        let actionController = UIAlertController(title: "How do you want to choose your photo?", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionController.addAction(cameraAction)
        actionController.addAction(photoLibraryAction)
        actionController.addAction(cancelAction)
        present(actionController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[.originalImage] as? UIImage else {
            fatalError("Failed to get image picked by user.")
        }
        
        guard let convertedCIImage = CIImage(image: userPickedImage) else {
            fatalError("Failed to convert UIImage to CIImage")
        }
        
        guard let flowerName = flowerBrain.detectFlowerName(flowerImage: convertedCIImage) else {
            fatalError()
        }
        
        if let flowerInfo = flowerBrain.getFlowerInfo(flowerName: flowerName) {
            // Get image from url
            let url = URL(string: flowerInfo.query.pages[0].thumbnail.source)
            let task = session!.dataTask(with: url!) { data, response, error in
                if let safeData = data {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: safeData)
                    }
                }
            }
            task.resume()
            self.flowerDescriptionTextLabel.text = flowerInfo.query.pages[0].extract
            self.navigationItem.title = "\(flowerName)"
        } else {
            imageView.image = userPickedImage
            self.flowerDescriptionTextLabel.text = "No info about this flower was found."
            self.navigationItem.title = "\(flowerName)"
        }
        placeHolderTextLabel.isHidden = true
        flowerDescriptionTextLabel.isHidden = false
        imageView.isHidden = false
        picker.dismiss(animated: true)
    }
}

func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
}
