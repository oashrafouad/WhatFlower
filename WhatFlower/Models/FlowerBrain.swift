//
//  FlowerBrain.swift
//  WhatFlower
//
//  Created by Omar Ashraf on 23/02/2024.
//

import UIKit
import Vision

struct FlowerBrain {
    
    func detectFlowerName(flowerImage: CIImage) -> String? {
        
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
            return firstResult?.identifier.capitalized ?? nil
        } catch {
            print("Error performing VNCoreMLRequest: \(error)")
        }
        return nil
    }
    
    func getFlowerInfo(flowerName: String) -> FlowerData? {
        var flowerInfo: FlowerData? = nil
        
        let url = URL(string: "https://en.wikipedia.org/w/api.php?action=query&prop=extracts|pageimages&exsentences=10&pithumbsize=500&titles=\(flowerName)&explaintext=1&formatversion=2&format=json")
        print(flowerName)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url!) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            if let safeData = data {
                do {
                    flowerInfo = try JSONDecoder().decode(FlowerData.self, from: safeData)
                } catch {
                    print("Error decoding JSON response: \(error)")
                }
                print("2")
            }
            else {
                print("Error")
            }
        }
        task.resume()
        
        while (!task.progress.isFinished) { /* empty loop to block executing further code before we're sure task is finished */ }
        Thread.sleep(forTimeInterval: 0.01) // for some reason there is a tiny delay between when the while loop finishing and the task completion handler executing, that messes the code order and function returns with nil, so I added a small delay to sync things up
        print("3")
        return flowerInfo
    }
    
    
}
