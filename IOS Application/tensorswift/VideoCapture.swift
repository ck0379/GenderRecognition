import AVFoundation
import Foundation


struct VideoSpec {
    var fps: Int32?
    var size: CGSize?
}

typealias ImageBufferHandler = ((_ imageBuffer: CVPixelBuffer, _ timestamp: CMTime, _ outputBuffer: CVPixelBuffer?) -> ())

class VideoCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
     let captureSession = AVCaptureSession()
     var videoDevice: AVCaptureDevice!
     var videoConnection: AVCaptureConnection!
     var audioConnection: AVCaptureConnection!
     var previewLayer: AVCaptureVideoPreviewLayer?
     var videoDeviceInput: AVCaptureDeviceInput?
    
    var imageBufferHandler: ImageBufferHandler?
    
    init(cameraType: CameraType, preferredSpec: VideoSpec?, previewContainer: CALayer?)
    {
        super.init()
        
        videoDevice = cameraType.captureDevice()

        
        // setup video format
        do {
            captureSession.sessionPreset = AVCaptureSessionPresetInputPriority
            if let preferredSpec = preferredSpec {
                // update the format with a preferred fps
                
                videoDevice.updateFormatWithPreferredVideoSpec(preferredSpec: preferredSpec)
            }
        }
        
        // setup video device input
        do {
            
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            }
            catch {
                fatalError("Could not create AVCaptureDeviceInput instance with error: \(error).")
            }
            guard captureSession.canAddInput(videoDeviceInput) else {
                fatalError()
            }
            captureSession.addInput(videoDeviceInput)
        }
                
        // setup preview
        if let previewContainer = previewContainer {
            guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else {fatalError()}
            previewLayer.frame = previewContainer.bounds
            previewLayer.contentsGravity = kCAGravityResizeAspectFill
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewContainer.insertSublayer(previewLayer, at: 0)
            self.previewLayer = previewLayer
        }
        
        // setup video output
        do {
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: NSNumber(value: kCVPixelFormatType_32BGRA)]
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            let queue = DispatchQueue(label: "jz.videosamplequeue")
            videoDataOutput.setSampleBufferDelegate(self, queue: queue)
            guard captureSession.canAddOutput(videoDataOutput) else {
                fatalError()
            }
            captureSession.addOutput(videoDataOutput)
            
            videoConnection = videoDataOutput.connection(withMediaType: AVMediaTypeVideo)
        }
        
        // setup audio output
        do {
            let audioDataOutput = AVCaptureAudioDataOutput()
            let queue = DispatchQueue(label: "jz.audiosamplequeue")
            audioDataOutput.setSampleBufferDelegate(self, queue: queue)
            guard captureSession.canAddOutput(audioDataOutput) else {
                fatalError()
            }
            captureSession.addOutput(audioDataOutput)
            
            audioConnection = audioDataOutput.connection(withMediaType: AVMediaTypeAudio)
        }

    }
    
    func startCapture() {
        print("\(self.classForCoder)/" + #function)
        if captureSession.isRunning {
            print("already running")
            return
        }
        captureSession.startRunning()
    }
    
    func stopCapture() {
        print("\(self.classForCoder)/" + #function)
        if !captureSession.isRunning {
            print("already stopped")
            return
        }
        captureSession.stopRunning()
    }
    
    func resizePreview() {
        if let previewLayer = previewLayer {
            guard let superlayer = previewLayer.superlayer else {return}
            previewLayer.frame = superlayer.bounds
        }
    }
    
    // =========================================================================
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        //        print("\(self.classForCoder)/" + #function)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!)
    {
        // FIXME: temp
        if connection.videoOrientation != .portrait {
            connection.videoOrientation = .portrait
            return
        }
        
        if let imageBufferHandler = imageBufferHandler, let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) , connection == videoConnection
        {
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            imageBufferHandler(imageBuffer, timestamp, nil)
        }
    }
    
    func switchCamera() -> Bool {
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        if self.videoDeviceInput?.device.position == .back {
            for device in devices! where (device as AnyObject).position == .front {
                let videoInput = try? AVCaptureDeviceInput(device: device as! AVCaptureDevice)
                self.captureSession.stopRunning()
                self.captureSession.beginConfiguration()
                self.captureSession.removeInput(videoDeviceInput)
                if self.captureSession.canAddInput(videoInput) {
                    self.captureSession.addInput(videoInput)
                    self.videoDeviceInput = videoInput!
                }
                else{
                    self.captureSession.addInput(self.videoDeviceInput)
                }
                self.captureSession.commitConfiguration()
                captureSession.startRunning()
            }
            return true
        }else if self.videoDeviceInput?.device.position == .front{
            for device in devices! where (device as AnyObject).position == .back {
                let videoInput = try? AVCaptureDeviceInput(device: device as! AVCaptureDevice)
                self.captureSession.stopRunning()
                self.captureSession.beginConfiguration()
                self.captureSession.removeInput(videoDeviceInput)
                if self.captureSession.canAddInput(videoInput) {
                    self.captureSession.addInput(videoInput)
                    self.videoDeviceInput = videoInput!
                }
                else{
                    self.captureSession.addInput(self.videoDeviceInput)
                }
                self.captureSession.commitConfiguration()
                captureSession.startRunning()
            }
            return true
        }else{
            return false
        }
        
    }
}


enum CameraType : Int {
    case back
    case front
    
    func captureDevice() -> AVCaptureDevice {
        switch self {
        case .front:
           guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)else {break}
            //print("devices:\(devices)")
            for device in devices where (device as AnyObject).position == .front {
                return device as! AVCaptureDevice
            }
        default:
            break
        }
        return AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    }
}
