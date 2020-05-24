//
//  ViewController.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 24.05.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import MediaPlayer

class MainViewController: UIViewController {
    
    @IBOutlet weak var artImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var bgContainer: BackgroundView!
    @IBOutlet weak var nextBgButton: UIButton!
    @IBOutlet weak var prevBgButton: UIButton!
    
    private var disposeBag = DisposeBag()
    
    private var currentBg: Int = 0
    private var backgrounds: [[String: String]] = []
    
    private let statusService = StatusService()
    private let playback: PlaybackService
    private let metadata: MetadataService
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.playback = PlaybackService();
        self.metadata = MetadataService(playback: playback)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        self.playback = PlaybackService();
        self.metadata = MetadataService(playback: playback)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTimer()
        self.bindStatusToUI()
        self.commonInit()
    }
    
    @IBAction func onTriggerPlayButton(_ sender: Any) {
        self.playback.toggle()
        self.controlButton.setTitle(self.playback.paused ? "Play" : "Pause", for: .normal)
    }
    
    func commonInit() {
        RestClient.shared.restClient.send(RequestToGetBackgrounds()) {[unowned self] (result, error) in
            if let bg = result as? [[String: String]] {
                self.backgrounds = bg
                self.updateBg()
            }
        }
    }
    
    private func updateBg() {
        
        let bgObj = self.backgrounds[self.currentBg];
        
        let url = URL(string: bgObj["video_src"]! )!;
        
        self.bgContainer.setUrl(url: url)
        
        self.prevBgButton.isEnabled = self.currentBg > 0;
        self.nextBgButton.isEnabled = self.currentBg < self.backgrounds.count - 1
    }
    
    
    var timer: Timer?
    
    private func setupTimer() {
        self.timer = Timer(fire: Date(), interval: 1, repeats: true, block: { [weak self] (timer) in
            do {
                let status = try self?.statusService.status$.value()
                if let status = status {
                    self?.metadata.setMetadata(status: status)
                    self?.updateDurationLabel(status: status)
                }
            } catch { }
        })
        if let timer = self.timer {
            RunLoop.current.add(timer, forMode: .default);
        }
    }
    
    func bindStatusToUI() {
        statusService.status$.distinctUntilChanged().subscribe { [weak self] (event) in
            if let status = event.element as? Status {
                self?.artistLabel.text = status.playback.artist
                self?.songLabel.text = status.playback.title
                self?.artImageView.image = status.image;
                self?.metadata.setMetadata(status: status)
                self?.updateDurationLabel(status: status)
            }
            
        }.disposed(by: disposeBag)
    }
    
    func updateDurationLabel(status: Status) {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [ .minute, .second ]
        formatter.zeroFormattingBehavior = [ .pad ]
        
        let currTimeString = formatter.string(from: status.getPosition())!
        let lengthTimeString = formatter.string(from: Double(status.playback.length))!
        self.durationLabel.text = "\(currTimeString) / \(lengthTimeString)"
    }
    
    
    @IBAction func prevBackground(_ sender: Any) {
        self.currentBg -= 1;
        self.updateBg()
    }

    @IBAction func nextBackground(_ sender: Any) {
        self.currentBg += 1;
        self.updateBg()
    }
}

