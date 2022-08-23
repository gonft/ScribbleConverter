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
import Foundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PKDrawing data를 Scribble 데이터 변환하는 예시 입니다
        // 여기서 반환된 data를 사용가능한 Scribble(proto3) 객체는 공유하지 않고 있습니다
//        let pkDrawing = PKDrawing()
//        _ = ScribbleConverter.scribbleFrom(drawingData: pkDrawing.dataRepresentation(), imageWidth: 1024)
//        // OR
//        _ = ScribbleConverter.scribbleFrom(pkDrawing: pkDrawing, imageWidth: 1024)
        let path = Bundle.main.path(forResource: "97691_1", ofType: "bin")
        print("path: \(path)")
        if let path = path {
            let data = FileManager.default.contents(atPath: path)
            _ = ScribbleConverter.fixScribble(
                                src: data!,
                                srcWidth: 3484.0,
                                corectSize: CGSize(
                                    width: 2433.0,
                                    height: 3484.0
                                )
                            )
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
