//
//  FlowersDetectorModel.swift
//  FlowersDetector
//
//  Created by Anna Volkova on 19.01.2021.
//

import SwiftUI
import CoreML
import Vision

class FlowersDetectorModel: ObservableObject {
    
    @Published var index = 1
    @Published var showingAlert = false
    var flowerName: String?
    var baseName = "image"
    var fullName: String {
        "\(baseName)\(index)"
    }
    var image: Image {
        Image(self.fullName)
    }
    
    init() {
        self.setupModel()
    }
    
    let flowersDetector = FlowersDetector()
    var flowersVisionModel: VNCoreMLModel?
    var flowersRequest: VNCoreMLRequest?
    
    func setupModel() {
        if let flowersModel = try? VNCoreMLModel(for: flowersDetector.model) {
            self.flowersVisionModel = flowersModel
            flowersRequest = VNCoreMLRequest(model: flowersModel, completionHandler: visionRequestDidComplete)
        }
    }
    
    // post-processing
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        if let observations = request.results as? [VNClassificationObservation],
            let segmentationmap = observations.first?.identifier {
            self.flowerName = segmentationmap
            self.showingAlert = true
        }
    }
    
    func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var image = CIImage(image: UIImage(named: self.fullName)!)!
            image = image.transformed(by: CGAffineTransform(scaleX: 513/image.extent.width, y: 513/image.extent.height))
            let context = CIContext(options: nil)
            if let cgimage = context.createCGImage(image, from: image.extent) {
                self.predict(with: cgimage)
            }
        }
    }
    
    func predict(with image: CGImage) {
        guard let request = flowersRequest else { fatalError() }
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([request])
    }
}
