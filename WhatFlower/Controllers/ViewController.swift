//
//  ViewController.swift
//  WhatFlower
//
//  Created by Omar Ashraf on 16/02/2024.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textLabel: UILabel!
    private let picker = UIImagePickerController()
    
    private var request: VNCoreMLRequest?
    
    private var session: URLSession?
    
    var flowerBrain = FlowerBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        
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
        
        guard var flowerName = flowerBrain.detectFlowerName(flowerImage: convertedCIImage) else {
            fatalError()
        }
        
        flowerName = "Flower"
        
//        let flowerInfo = flowerBrain.getFlowerInfo(flowerName: flowerName)
//        print(flowerInfo)
//        // loop until flowerInfo is not nil
//        while flowerInfo == nil {
//            print("waiting for flowerInfo")
//            if flowerInfo != nil {
//                print("not nil")
//            }
//        }
        if let flowerInfo = flowerBrain.getFlowerInfo(flowerName: flowerName) {
            //        print(flowerInfo)
            print("3")
            
            // get image from url
            let url = URL(string: flowerInfo.query.pages[0].thumbnail.source)
//            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let task = session!.dataTask(with: url!) { data, response, error in
                if let safeData = data {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: safeData)
                    }
                }
            }
            task.resume()
            self.textLabel.text = flowerInfo.query.pages[0].extract
            self.navigationItem.title = "\(flowerName)"
        } else {
            imageView.image = userPickedImage
            self.textLabel.text = "No info about this flower was found."
        }
        textLabel.isHidden = false
        picker.dismiss(animated: true)
    }
    
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        print("completed")
//    }
//    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
//        print("created")
//    }
//    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print("received")
//    }
//    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
//        print("finished")
//    }
}

func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
}


