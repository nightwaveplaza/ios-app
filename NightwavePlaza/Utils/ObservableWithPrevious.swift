//
//  ObservableWithPrevious.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 21.09.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {

    func withPrevious() -> Observable<(Element?, Element)> {
    return scan([], accumulator: { (previous, current) in
        Array(previous + [current]).suffix(2)
      })
        .map({ (arr) -> (previous: Element?, current: Element) in
        (arr.count > 1 ? arr.first : nil, arr.last!)
      })
  }
}
