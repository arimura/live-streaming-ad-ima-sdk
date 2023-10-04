import UIKit
import AVKit

class ViewController: UIViewController {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerItem: AVPlayerItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background color
        self.view.backgroundColor = .black
        
        // Create the AVPlayerItem with an HLS video stream URL
        if let url = URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8") {
            playerItem = AVPlayerItem(url: url)
            
            // Add observer for status and error
            playerItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
            playerItem?.addObserver(self, forKeyPath: "error", options: [.new, .initial], context: nil)
            
            // Create the AVPlayer with the player item
            player = AVPlayer(playerItem: playerItem)
            
            // Create the AVPlayerLayer and add it to the view's layer
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = self.view.bounds
            playerLayer?.videoGravity = .resizeAspectFill
            if let playerLayer = playerLayer {
                self.view.layer.addSublayer(playerLayer)
            }
            
            // Play the video
            player?.play()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update the player layer's frame when the view's layout changes
        playerLayer?.frame = self.view.bounds
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
