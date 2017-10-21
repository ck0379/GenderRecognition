//
//  ViewController.swift
//  Tensorswift
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, TensorDelegate {

    @IBOutlet var first_result: UILabel!
    @IBOutlet var second_result: UILabel!
    
    @IBOutlet var first_label: UILabel!
    @IBOutlet var second_label: UILabel!

    
    @IBOutlet weak var previewView: UIView!
    
    var bridge:TensorBridge = TensorBridge()
    

     private var videoCapture: VideoCapture!
     private var ciContext : CIContext!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let videoCapture = videoCapture else {return}
        videoCapture.startCapture()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bridge.loadModel()
        bridge.delegate = self
        
        let spec = VideoSpec(fps: 3, size: CGSize(width: 640, height: 480))
        videoCapture = VideoCapture(cameraType: .back,
                                    preferredSpec: spec,
                                    previewContainer: previewView.layer)
     
        videoCapture.imageBufferHandler = {[unowned self] (imageBuffer, timestamp, outputBuffer) in
            self.bridge.runCNN(onFrame: imageBuffer)
        }
    }

    override func viewDidAppear(_ animated: Bool) {

    }
    
    

    // seen objects enter here
    
    func tensorLabelListUpdated(_ recognizedObjects:[AnyHashable : Any]){
        var limit = 0
        var result = [String :Double]()
        for seenObject in recognizedObjects {
            let label = String(describing: seenObject.key)
            //print(label)
            let confidence = seenObject.value as! Double
            let conPct = (confidence * 100).rounded()
            result[label] = conPct
            // change the debug confidence here
            if confidence > 0.5 {
                //print(result)
                //lable_result.text = "\(conPct)% sure that's a \(label)"
                //lable_result.text = "\(conPct)%  that's a \(label) \n "
                //print("\(conPct)% sure that's a \(label)")
                }
        }
        let final_result = result.sorted{$0.1 > $1.1}
        for lable in final_result{
                if limit == 0 {
                    first_result.text? = ("\(lable.value)% :")
                    first_label.text? = ("\(lable.key)")
                }else {
                    second_result.text? = ("\(lable.value)% :")
                    second_label.text? = ("\(lable.key)")
                }
                limit += 1
                if limit >= 2 {
                    break
                }
        }
        //print(final_result)
//        var label_layer = CATextLayer.init(layer: <#T##Any#>)
//        self.view.layer.addSublayer(label_layer)
    }

    @IBAction func takePicture(_ sender: UIButton) {
        if videoCapture.captureSession.isRunning{
            videoCapture.stopCapture()
            
            UIView.animate(withDuration: 0.2, animations: {self.previewView.alpha = 0.9;})
            //            UIView.animate(withDuration: 0.2, animations: {self.previewView.alpha = 0.0;}, completion: (BOOL finished),{ self.previewView.removeFromSuperview(); })
        }else{
            videoCapture.startCapture()
            UIView.animate(withDuration: 0.2, animations: {self.previewView.alpha = 1.0;})
        }

    }
    
    @IBAction func switchCamera(_ sender: UIButton) {
          UIView.animate(withDuration: 0.2, animations: {self.videoCapture.switchCamera();})

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

