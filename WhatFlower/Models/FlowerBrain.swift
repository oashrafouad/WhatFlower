//
//  FlowerBrain.swift
//  WhatFlower
//
//  Created by Omar Ashraf on 23/02/2024.
//

import CoreML
import Vision
import CoreImage

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
            print("1")
            if let safeData = data {
                do {
                    //                    print(String(data: safeData, encoding: .utf8)!)
                    flowerInfo = try JSONDecoder().decode(FlowerData.self, from: safeData)
                    //                    flowerInfo = flowerData.query.pages[0].extract
                    //                    print(flowerInfo)
                    
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
        
        sleep(2) // task can finish AFTER function return, so this fixes that TODO: replace that with better way
        //        print(flowerInfo)
        return flowerInfo
        
    }
    
    
}
