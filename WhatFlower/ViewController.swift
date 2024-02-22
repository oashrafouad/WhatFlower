//
//  ViewController.swift
//  WhatFlower
//
//  Created by Omar Ashraf on 16/02/2024.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private let picker = UIImagePickerController()
    
    private var request: VNCoreMLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
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

        guard let result = detect(flowerImage: convertedCIImage) else {
            fatalError()
        }
        
        imageView.image = userPickedImage
        self.navigationItem.title = "\(result.identifier.capitalized)"
        picker.dismiss(animated: true)
    }
}

func detect(flowerImage: CIImage) -> VNClassificationObservation?{
    
    var firstResult: VNClassificationObservation?
    guard let model = try? VNCoreMLModel(for: FlowerClassifier(configuration: .init()).model) else {
        fatalError("Failed loading MLModel")
    }
    
    let request = VNCoreMLRequest(model: model) { request, error in
        guard let results = request.results as? [VNClassificationObservation] else {
            fatalError()
        }
        firstResult = results.first!
    }
    
    let handler = VNImageRequestHandler(ciImage: flowerImage)
    
    do {
        try handler.perform([request])
        return firstResult ?? nil
    } catch {
        print("Error performing VNCoreMLRequest: \(error)")
    }
    return nil
}

func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    print("cancelled")
    picker.dismiss(animated: true)
}
