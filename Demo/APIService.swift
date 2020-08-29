//
//  APIService.swift
//  Demo
//
//  Created by Ricol Wang on 29/8/20.
//  Copyright © 2020 DeepSpace. All rights reserved.
//

import Foundation
import Alamofire

typealias TComplete = ([String: String]) -> Void

class APIService
{
    static func github(complete: @escaping TComplete)
    {
        AF.request("https://api.github.com").responseJSON { (res) in
            if let dict = res.value as? [String: String]
            {
                complete(dict)
            }
        }
    }
}
