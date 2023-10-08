import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "http://localhost:8085/index.m3u8") else {
            print("Invalid URL")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        playerItem.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        
        player = AVPlayer(playerItem: playerItem)
        
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        
        if let playerVC = playerViewController {
            addChild(playerVC)
            view.addSubview(playerVC.view)
            playerVC.view.frame = view.bounds
            playerVC.didMove(toParent: self)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let status = AVPlayerItem.Status(rawValue: change?[.newKey] as! Int) {
                switch status {
                case .failed:
                    print("Error: \(String(describing: player?.currentItem?.error?.localizedDescription))")
                case .readyToPlay:
                    print("Ready to play")
                case .unknown:
                    print("Unknown error occurred")
                @unknown default:
                    print("Unknown status")
                }
            }
        }
    }

    deinit {
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
    }
}
