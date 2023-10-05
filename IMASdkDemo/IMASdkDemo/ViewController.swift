import UIKit
import AVKit
import GoogleInteractiveMediaAds

class ViewController: UIViewController, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerItem: AVPlayerItem?
    
    private var contentPlayhead: IMAAVPlayerContentPlayhead?
    private let adsLoader = IMAAdsLoader(settings: nil)
    private var adsManager: IMAAdsManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background color
        self.view.backgroundColor = .black
        
        // Create the AVPlayerItem with an HLS video stream URL
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
            
            // Set up our content playhead and contentComplete callback.
            contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player!)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(ViewController.contentDidFinishPlaying(_:)),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: player?.currentItem)
            
            // Play the video
            //            player?.play()
            
            adsLoader.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        requestAds()
    }
    
    
    @objc func contentDidFinishPlaying(_ notification: Notification) {
        // Make sure we don't call contentComplete as a result of an ad completing.
        if (notification.object as! AVPlayerItem) == player?.currentItem {
            adsLoader.contentComplete()
        }
    }
    
    private func requestAds() {
        // Create ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(
            adContainer: self.view, viewController: self, companionSlots: nil)
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: "https://voyagegroup.github.io/FluctSDK-Hosting/sdk/gsm-vast.xml",
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil)
        
        adsLoader.requestAds(with: request)
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
    
    // MARK: - IMAAdsLoaderDelegate
    
    func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
        adsManager = adsLoadedData.adsManager
        adsManager?.delegate = self
        
        // Create ads rendering settings and tell the SDK to use the in-app browser.
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.linkOpenerPresentingController = self
        
        // Initialize the ads manager.
        adsManager?.initialize(with: adsRenderingSettings)
    }
    
    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        print("Error loading ads: \(adErrorData.adError.message ?? "nil")")
        player?.play()
    }
    
    // MARK: - IMAAdsManagerDelegate
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        if event.type == IMAAdEventType.LOADED {
            // When the SDK notifies us that ads have been loaded, play them.
            adsManager.start()
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        // Something went wrong with the ads manager after ads were loaded. Log the error and play the
        // content.
        print("AdsManager error: \(error.message ?? "nil")")
        player?.play()
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        // The SDK is going to play ads, so pause the content.
        player?.pause()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        // The SDK is done playing ads (at least for now), so resume the content.
        player?.play()
    }
    
    // Remove observers when the view controller is deinitialized
    deinit {
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "error")
    }
}

