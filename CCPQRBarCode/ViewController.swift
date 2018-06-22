//
//  ViewController.swift
//  CCPQRBarCode
//
//  Created by 储诚鹏 on 2018/6/21.
//  Copyright © 2018年 储诚鹏. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        QRScan(supview: self.view)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

