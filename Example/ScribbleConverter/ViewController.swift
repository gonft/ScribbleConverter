//
//  ViewController.swift
//  ScribbleConverter
//
//  Created by proghjy on 05/26/2022.
//  Copyright (c) 2022 proghjy. All rights reserved.
//

import UIKit
import ScribbleConverter
import PencilKit
import SwiftProtobuf

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PKDrawing data를 Scribble 데이터 변환하는 예시 입니다
        // 여기서 반환된 data를 사용가능한 Scribble(proto3) 객체는 공유하지 않고 있습니다
        let pkDrawing = PKDrawing()
        _ = ScribbleConverter.scribbleFrom(drawingData: pkDrawing.dataRepresentation())
        // OR
        _ = ScribbleConverter.scribbleFrom(pkDrawing: pkDrawing)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
