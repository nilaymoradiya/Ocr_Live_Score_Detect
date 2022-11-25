//
//  ViewController.swift
//  OcrDemo

import UIKit
import AVKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var ssImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    let processor = ScaledElementProcessor()
    var frameSublayer = CALayer()
    var player: AVPlayer?
    var playerController: AVPlayerViewController?
    var scannedText: String = "Detected text can be edited here." {
        didSet {
            textView.text = scannedText
        }
    }
    var timer: Timer?
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
    }
    
    // Setup Data
    private func setupData() {
        videoPlayer()
        ssImage.layer.addSublayer(frameSublayer)
        drawFeatures(in: ssImage)
    }
    
    // Remove Frames
    private func removeFrames() {
        guard let sublayers = frameSublayer.sublayers else { return }
        for sublayer in sublayers {
            sublayer.removeFromSuperlayer()
        }
    }
    
    // Draw Features
    private func drawFeatures(in imageView: UIImageView, completion: (() -> Void)? = nil) {
        removeFrames()
        processor.process(in: imageView) { text, elements in
            elements.forEach() { element in
                self.frameSublayer.addSublayer(element.shapeLayer)
            }
            self.scannedText = text
            completion?()
        }
    }
    
    // Video Player
    func videoPlayer() {
        guard let path = Bundle.main.path(forResource: "matchf", ofType: "mp4") else {
            debugPrint("matchf.mp4 not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        playerController = AVPlayerViewController()
        playerController?.player = player
        viewVideo.addSubview((playerController?.view)!)
        playerController?.view.frame = CGRect(x: 0, y: 0, width: self.viewVideo.bounds.width, height: self.viewVideo.bounds.height)
        player?.play()
    }
    
    // Start Timer
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc func timerAction() {
        let screenshot = self.viewVideo.takeScreenshot()
        ssImage.image = screenshot
        self.drawFeatures(in: self.ssImage)
    }
}


extension UIView {
    
    // Screenshot Recognize function
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        // get iamge
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if image != nil {
            return image!
        }
        return UIImage()
    }
}
