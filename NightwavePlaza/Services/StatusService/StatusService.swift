//
//  StatusService.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 24.05.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class StatusService: NSObject {
    
    var status$ = BehaviorSubject<Status?>(value: nil) //: Observable<Status>;
    
    private var updateBag: DisposeBag?
    private var timer: Timer?
    
    private let updateScheduler = UpdateScheduler()
    
    override init() {
        super.init()
        self.startUpdates()
    }
    
    func startUpdates() {
        
        if (self.updateBag != nil) {
            return
        }
        
        let bag = DisposeBag();
        
        updateScheduler.tick.flatMapLatest { (i) -> Observable<Status> in
            return self.getStatus()
        }
        .distinctUntilChanged()
        .map({ (status) -> Status in
            self.updateScheduler.schedule(status: status)
            return status
        })
        .flatMapLatest { (status) -> Observable<Status> in
            return self.loadAlbumImage(status: status)
        }.bind(to: self.status$ ).disposed(by: bag)
        
        self.updateBag = bag
        
    }
    
    func stopUpdates() {
        self.updateBag = nil;
    }
    
    
    private func getStatus() -> Observable<Status> {
        return Observable.create({ (observer) -> Cancelable in
            let handler = RestClient.shared.restClient.send(RequestToGetStatus()) { (res: Any?, err: Error?) in
                if let status = res as? Status {
                    observer.onNext(status)
                }
                else if let error = err {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            return Disposables.create {
                handler?.cancel()
            }
        });
    }
    
    private func loadAlbumImage(status: Status) -> Observable<Status> {
        return Observable.create({ (observer) in
            let handler = RestClient.shared.restClient.send(RequestToGetImage(url: status.playback.artwork)) { (image, error) in
                if let image = image as? UIImage {
                    status.image = image
                }
                observer.onNext(status)
                observer.onCompleted()
            }
            return Disposables.create {
                handler?.cancel()
            }
        });
    }
}
