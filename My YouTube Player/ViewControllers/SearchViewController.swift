//
//  SearchViewController.swift
//  My YouTube Player
//
//  Created by Pin Yiu on 24/1/2021.
//  Copyright © 2021 Pin Yiu. All rights reserved.
//

import UIKit
import WebKit
import XCDYouTubeKit
import SnapKit

class SearchViewController: UIViewController {
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Search"
        
        webView = WKWebView()
        webView.navigationDelegate = self
        
        
        view.addSubview(webView)
        webView.snp.makeConstraints({ make in
            if let statusBarHeight = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.windowScene?.statusBarManager?.statusBarFrame.height {
                make.height.equalTo(view).offset(-statusBarHeight)
                make.top.equalTo(view).offset(statusBarHeight)
            } else {
                make.height.equalTo(view)
            }
            make.width.equalTo(view)
            
        })
        
        let url = URL(string: "https://www.youtube.com/")!
        DispatchQueue.main.async { [weak self] in
            self?.webView.load(URLRequest(url: url))
        }
        
        webView.allowsBackForwardNavigationGestures = true
        
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = change?[NSKeyValueChangeKey.newKey] {
            let urlString = "\(key)"
            if urlString.contains("https://m.youtube.com/watch?v=") || urlString.contains("https://www.youtube.com/watch?v=") {
                let index = urlString.index(urlString.endIndex, offsetBy: -11)
                let vid = String(urlString[index...])
                webView.goBack()
                webView.reload()
                if !vid.isEmpty {
                    XCDYouTubeClient.default().getVideoWithIdentifier(vid) { (video, error) in
                        guard error == nil else {
                            print("error")
                            return
                        }
                        guard let video = video else {
                            return
                            
                        }
                        
                        guard let tabBar = self.tabBarController?.tabBar else {
                            return
                        }
                        
                        let actionSheet = UIAlertController(title: "Add to playlist?", message: video.title, preferredStyle: .actionSheet)
                        for playlistModel in Data.playlistModels {
                            let action = UIAlertAction(title: playlistModel.name, style: .default, handler: { _ in
                                let songModel = SongModel(id: String(vid), name: video.title, isDownloaded: false)
                                PlaylistFunctions.addSong(id: playlistModel.id, songModel: songModel)
                            })
                            actionSheet.addAction(action)
                        }
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        actionSheet.addAction(cancelAction)
                        if (UIDevice.current.userInterfaceIdiom == .pad) {
                            if let currentPopoverpresentioncontroller = actionSheet.popoverPresentationController{
                                currentPopoverpresentioncontroller.sourceView = tabBar
                                currentPopoverpresentioncontroller.sourceRect = tabBar.bounds
                                currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.up
                                self.present(actionSheet, animated: true, completion: nil)
                            }
                        } else {
                            self.present(actionSheet, animated: true)
                        }
                        
                    }
                }
                
                
            }
        }
    }
}

extension SearchViewController: WKNavigationDelegate {
  
}
