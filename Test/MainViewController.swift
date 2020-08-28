//
//  ViewController.swift
//  Test
//
//  Created by Ricol Wang on 28/8/20.
//  Copyright © 2020 DeepSpace. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController
{
    @IBOutlet weak var barItemRun: UIBarButtonItem!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBAction Methods
    
    @IBAction func barItemRunOnTapped(_ sender: Any)
    {
        callAPI()
    }
    
    // MARK: - Private Methods
    
    private func callAPI()
    {
        AF.request("https://api.github.com").responseJSON { (res) in
            if let json = res.value as? [String: String]
            {
                print(json)
            }
        }
    }
}
