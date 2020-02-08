//
//  CaptureViewController.swift
//  Traveller
//
//  Created by Anthony on 25/10/19.
//  Copyright © 2019 EmeraldApps. All rights reserved.
//

import UIKit
import AVFoundation

class CaptureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    /// holds place variable
    var checkedInPlace = Place()
    
    let imagePickerController = UIImagePickerController()
    var image = UIImage()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?

    var photoOutput = AVCapturePhotoOutput()
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var captureSession = AVCaptureSession()
    var frontCameraActive = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setUpBackgroundColour()
        tabBarController?.tabBar.isHidden = true

        setUpCaptureButton()
        checkAuthorization()
    }
    
    // MARK: - Camera Authorisation
    func checkAuthorization(){
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        switch cameraAuthorizationStatus {
        case .denied:
            self.presentCameraAlert()
            break
        case .authorized:
            setUpCaptureSession()
            setUpDevice()
            setUpInputOutput()
            setUpPreviewLayer()
            setUpRunningCaptureSession()
            
            break
        case .restricted:
            print("Camera access is restricted")
            break

        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                    print("Granted access to \(cameraMediaType)")
                } else {
                    print("Denied access to \(cameraMediaType)")
                    self.presentCameraAlert()
                }
            }
        @unknown default:
            presentCameraAlert()
        }
    }
    
    
    // MARK: - View Setup
    func setUpCaptureButton(){
        captureButton.layer.cornerRadius = captureButton.bounds.height / 2
        captureButton.layer.borderColor = UIColor.gray.cgColor
        captureButton.layer.borderWidth = 7
        captureButton.backgroundColor = UIColor.white
    }
    
    // MARK: - Camera Session Setup
    func setUpCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setUpDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            // setting up cameras
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
                currentCamera = backCamera
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
                // set to back camera no matter what
                currentCamera = backCamera
            }
        }
    }
    
    
    func setUpInputOutput(){
        do {
             let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            
            photoOutput = AVCapturePhotoOutput()
            photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput)
        } catch {
            print(error)
        }
    }
    
    
    func setUpPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer!.frame = imageView.bounds
        self.imageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.imageView.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    
    func setUpRunningCaptureSession(){
        captureSession.startRunning()
    }

    // MARK: - Switch camera funcs
    func switchToFrontCamera(){
  
        if frontCamera?.isConnected == true {
          
            captureSession.stopRunning()
            let captureDevice: AVCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)!
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession = AVCaptureSession()
                captureSession.addInput(input)
                
                photoOutput = AVCapturePhotoOutput()
                photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
                captureSession.addOutput(photoOutput)
                setUpPreviewLayer()
                captureSession.startRunning()
                //print("test front")
            }
            catch {
                print(error)
            }
        }
    }
    
    
    func switchToBackCamera(){
          if backCamera?.isConnected == true {
            
            captureSession.stopRunning()
            let captureDevice: AVCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)!
              
              do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                  captureSession = AVCaptureSession()
                  captureSession.addInput(input)
                  photoOutput = AVCapturePhotoOutput()
                  photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
                  captureSession.addOutput(photoOutput)
                  setUpPreviewLayer()
                  captureSession.startRunning()
                  //print("test back")
              }
              catch {
                  print(error)
              }
          }
          
      }

    // MARK: - IBActions
    @IBAction func captureButton(_ sender: Any) {
        print("capture pressed")
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func switchCamera(_ sender: Any) {
        
        if frontCameraActive {
            frontCameraActive = false
            switchToBackCamera()
        } else {
            frontCameraActive = true
            switchToFrontCamera()
        }
    }
    
    
    // MARK: - Picking Image From Library
    @IBAction func chooseFromLibrary(_ sender: Any) {
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.image = image.fixOrientation()
        
        picker.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier:  "toFilterViewController"  , sender: self)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    /// setting image on next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let filterVC = segue.destination as! FilterViewController
        
        /// passing full size image to next vc
        filterVC.capturedImage = image
        
        /// passing downsized image to next vc for performance purposes
        filterVC.smallCapturedImage = image.resized(to: CGSize(width: image.size.width / 8, height: image.size.height / 8))
        
        /// passing place for use in new post controller
        filterVC.checkedInPlace = checkedInPlace
    }
}

/// For when photo is captures
extension CaptureViewController: AVCapturePhotoCaptureDelegate{
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            
            /// getting image and fixing orientation
            image = UIImage(data: imageData) ?? UIImage()
            image = image.fixOrientation()
            
            let flippedImage = UIImage(cgImage: self.image.cgImage!, scale: self.image.scale, orientation: .leftMirrored)
            
                /// flipping image captured from the front camera to display correctly on the next screen
                 if frontCameraActive {
                    image = flippedImage.rotate(radians: .pi / 2) ?? UIImage()
                 }
        
            performSegue(withIdentifier:  "toFilterViewController"  , sender: self)
        }
    }
}
