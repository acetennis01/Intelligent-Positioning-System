//
//  ViewController.swift
//  CameraTest2
//
//  Created by Abhiram Annaluru on 12/26/20.
//

import Foundation
import UIKit
import AVFoundation
import ScreenTime

class ViewController: UIViewController {
    
    let session = AVCaptureSession()
    var camera : AVCaptureDevice?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var cameraCaptureOutput : AVCapturePhotoOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCaptureSession()
        //startCapturing()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func displayCapturedPhoto(capturedPhoto : UIImage)
    {
        let imagePreviewViewController = storyboard?.instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
        imagePreviewViewController.capturedImage = capturedPhoto
        
        navigationController?.pushViewController(imagePreviewViewController, animated: true)
    }
    
    /*
    func startCapturing()
    {
        while true {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2)
            { [self] in
                self.takePicture(self)
            }
        }
    }
    */
    
    @IBAction func takePicture(_ sender: Any) {
        print("taking pic")
        takePicture()
    }
    
    func initializeCaptureSession()
    {
        print("Hello")
        session.sessionPreset = AVCaptureSession.Preset.high
        camera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let cameraCaptureInput = try AVCaptureDeviceInput(device: camera!)
            cameraCaptureOutput = AVCapturePhotoOutput()
            
            session.addInput(cameraCaptureInput)
            session.addOutput(cameraCaptureOutput!)
        } catch {
            print(error.localizedDescription)
        }
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.bounds
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
        session.startRunning()
    }
    
    func takePicture()
    {
        let settings = AVCapturePhotoSettings()
        cameraCaptureOutput?.capturePhoto(with: settings, delegate: self)
        
        
    }

}

extension ViewController : AVCapturePhotoCaptureDelegate{
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let unwrapped = error
        {
            print(unwrapped.localizedDescription)
        } else
        {
            guard let dataImage = photo.fileDataRepresentation() else { return }
            
            displayCapturedPhoto(capturedPhoto: UIImage(data: dataImage)!)
            
            /*
            if let dataImage = photo.fileDataRepresentation()
            {
                if let finalImage = UIImage(data: dataImage)
                {
                    displayCapturedPhoto(capturedPhoto: finalImage)
                }
            }
 */
        }
    }
    
}
