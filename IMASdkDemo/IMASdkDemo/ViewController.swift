import UIKit
import AVKit
import GoogleInteractiveMediaAds

class ViewController: UIViewController, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerItem: AVPlayerItem?
    
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background color
        self.view.backgroundColor = .black
        
        // Create the AVPlayerItem with an HLS video stream URL
//        if let url = URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8") {
        if let url = URL(string: "http://192.168.86.121:8085/index.m3u8") {
            playerItem = AVPlayerItem(url: url)
            
            // Add observer for status and error
            playerItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
            playerItem?.addObserver(self, forKeyPath: "error", options: [.new, .initial], context: nil)
            
            // Create the AVPlayer with the player item
            player = AVPlayer(playerItem: playerItem)
            
            // Create the AVPlayerLayer and add it to the view's layer
            playerLayer = AVPlayerLayer(player: player)
            if let playerLayer = playerLayer {
                self.view.layer.addSublayer(playerLayer)
            }
            
            // Initialize the IMAAdsLoader
            adsLoader = IMAAdsLoader(settings: nil)
            adsLoader.delegate = self
            
            // Request ads using an ad tag
            let adDisplayContainer = IMAAdDisplayContainer(adContainer: self.view, viewController: self)
            let request = IMAAdsRequest(adTagUrl: "https://your_ad_tag_url_here",
                                        adDisplayContainer: adDisplayContainer,
                                        contentPlayhead: nil,
                                        userContext: nil)
            adsLoader.requestAds(with: request)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Calculate the width and height for a 16:9 aspect ratio
        let width = self.view.bounds.width
        let height = width * 9 / 16
        
        // Get the top of the safe area
        let safeAreaTop = self.view.safeAreaInsets.top
        
        // Set the player layer's frame to the calculated width and height, positioned below the safe area's top anchor
        playerLayer?.frame = CGRect(x: 0, y: safeAreaTop, width: width, height: height)
    }
    
    // MARK: - IMAAdsLoaderDelegate
    
    func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        // Initialize the ads manager
        adsManager = adsLoadedData.adsManager
        adsManager?.delegate = self
        adsManager?.initialize(with: nil)
    }
    
    func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        print("Error loading ads: \(adErrorData.adError.message ?? "unknown error")")
        player?.play()
    }
    
    // MARK: - IMAAdsManagerDelegate
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
        if event.type == IMAAdEventType.LOADED {
            // Start playing the ads
            adsManager.start()
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        print("Ads Manager error: \(error.message ?? "unknown error")")
        player?.play()
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        // Pause the content for the ad
        player?.pause()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        // Resume the content after the ad
        player?.play()
    }
    
    // Observe changes to the AVPlayerItem's status and error properties
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            switch playerItem?.status {
            case .readyToPlay:
                print("Player item is ready to play.")
            case .failed:
                print("Player item failed with error: \(playerItem?.error?.localizedDescription ?? "Unknown error")")
            case .unknown:
                print("Player item status is unknown.")
            default:
                break
            }
        } else if keyPath == "error" {
            if let error = playerItem?.error {
                print("Player item encountered an error: \(error.localizedDescription)")
            }
        }
    }
    
    // Remove observers when the view controller is deinitialized
    deinit {
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "error")
    }
}
