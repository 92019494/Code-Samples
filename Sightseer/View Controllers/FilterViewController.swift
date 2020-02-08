//
//  FilterViewController.swift
//  Traveller
//
//  Created by Anthony on 29/10/19.
//  Copyright © 2019 EmeraldApps. All rights reserved.
//

import UIKit


class FilterViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    var checkedInPlace = Place()
    var capturedImage = UIImage()
    var smallCapturedImage = UIImage()
    /// Image filters
    var filters = [ Filter(title: "Default", name: "Default"),
                    Filter(title: "CISepiaTone", name: "Sepia" ),
                    Filter(title: "CIPhotoEffectTransfer", name: "Cool" ),
                    Filter(title: "CIColorPosterize", name: "Cartoon" ),
                    Filter(title: "CIPhotoEffectChrome", name: "Chrome" ),
                    Filter(title: "CIPhotoEffectFade", name: "Fade" ),
                    Filter(title: "CIPhotoEffectInstant", name: "Daylight" ),
                    Filter(title: "CIPhotoEffectMono", name: "Mono" ),
                    Filter(title: "CIColorClamp", name: "Clamp" ),
                    Filter(title: "CILinearToSRGBToneCurve", name: "Desert" ),
                    Filter(title: "CIVibrance", name: "Vibrant" ),
                    Filter(title: "CIUnsharpMask", name: "Darken" ),
                    Filter(title: "CIVignette", name: "Vignette" ),
                    Filter(title: "CIPhotoEffectNoir", name: "Noir" )]
    var context: CIContext!
    var currentFilter: CIFilter!
    /// setting hardcoded intensity filter
    var intensity = 0.5
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = CIContext()
        currentFilter = CIFilter()
        setUpRightBarButton()
        imageView.image = capturedImage
    }
    
    // MARK: - IBActions
    @IBAction func nextButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        /// checking what screen to send the user to next
        if Variables.isLandmarkUpload {
            let vc = storyboard.instantiateViewController(withIdentifier: "newPlaceViewController") as! NewPlaceViewController
            vc.capturedImage = self.imageView.image!
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = storyboard.instantiateViewController(withIdentifier: "newPostViewController") as! NewPostViewController
            vc.capturedImage = self.imageView.image!
            
            /// passing place for use in new post controller
            vc.checkedInPlace = checkedInPlace
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Filter Functionality 
    func applyProcessing(){
        let inputKeys = currentFilter.inputKeys
        /// checking what keys the current filter has
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensity * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: capturedImage.size.width / 2, y: capturedImage.size.height / 2), forKey: kCIInputCenterKey)
        }

        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent){
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
        }
    }
    
    /// changing main image view
    func setFilter(name: String){

        currentFilter = CIFilter(name: name)
        
        let beginImage = CIImage(image: capturedImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    /// Applying flters to collection view cells using the small image
    func applyCellFilter(name: String) -> UIImage {
        
        /// using smaller image for better performance
        currentFilter = CIFilter(name: name)
        
        let beginImage = CIImage(image: smallCapturedImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
          let inputKeys = currentFilter.inputKeys
              // checking what keys the current filter has
              if inputKeys.contains(kCIInputIntensityKey) {
                  currentFilter.setValue(intensity, forKey: kCIInputIntensityKey)
              }
              if inputKeys.contains(kCIInputRadiusKey) {
                  currentFilter.setValue(intensity * 200, forKey: kCIInputRadiusKey)
              }
              if inputKeys.contains(kCIInputScaleKey) {
                  currentFilter.setValue(intensity * 10, forKey: kCIInputScaleKey)
              }
              if inputKeys.contains(kCIInputCenterKey) {
                  currentFilter.setValue(CIVector(x: capturedImage.size.width / 2, y: capturedImage.size.height / 2), forKey: kCIInputCenterKey)
              }

              guard let outputImage = currentFilter.outputImage else { return UIImage() }
              
              if let cgImage = context.createCGImage(outputImage, from: outputImage.extent){
                  let processedImage = UIImage(cgImage: cgImage)
                  return processedImage
              }
        return UIImage()
    }

    // MARK: - Segue Preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          let newPostVC = segue.destination as! NewPostViewController
            newPostVC.capturedImage = self.imageView.image!
      }

}

// MARK: - CollectionView Setup
extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! FilterCollectionViewCell
        cell.filterLabel.text = filters[indexPath.row].name
        
        if indexPath.row == 0 {
            cell.image.image = smallCapturedImage
        } else {
        cell.image.image = applyCellFilter(name: filters[indexPath.row].title)
        }
        
        if cell.isSelected {
            cell.filterLabel.textColor = UIColor.black
            cell.filterLabel.font = UIFont(name: cell.filterLabel.font.fontName, size: 16)
        } else {
            cell.filterLabel.textColor = UIColor(named: "DetailGrey")
            cell.filterLabel.font = UIFont(name: cell.filterLabel.font.fontName, size: 13)
        }
        return cell
    }

    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        if let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell {
            cell.filterLabel.textColor = UIColor.black
            cell.filterLabel.font = UIFont(name: cell.filterLabel.font.fontName, size: 16)
        }

        if indexPath.row == 0 {
            imageView.image = capturedImage
        } else {
            setFilter(name: filters[indexPath.row].title)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell {
            cell.filterLabel.textColor = UIColor(named: "DetailGrey")
            cell.filterLabel.font = UIFont(name: cell.filterLabel.font.fontName, size: 13)
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 120, height: 140)
    }
}
