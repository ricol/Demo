//
//  ViewController.swift
//  Test
//
//  Created by Ricol Wang on 28/8/20.
//  Copyright © 2020 DeepSpace. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    let ID = "TableViewCell_ID"
    var data = [String]()
    var value = [String: String]()
    let indicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //schedule a timer to call api every 5 seconds
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            self.callAPI()
        }
        
        //add the indicator as left barButtonItem
        let barBtn = UIBarButtonItem(customView: indicator)
        self.navigationItem.leftBarButtonItem = barBtn
        
        self.tableView.tableFooterView = UIView() //trick to blank screen in table view
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let row = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath)
        cell.textLabel?.text = row
        cell.detailTextLabel?.text = value[row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    
    // MARK: - Private Methods
    
    private func callAPI()
    {
        indicator.startAnimating()
        AF.request("https://api.github.com").responseJSON { (res) in
            if let json = res.value as? [String: String]
            {
                self.data = json.keys.sorted()
                self.value = json
                //save to coredata
                if let theAppDelete = UIApplication.shared.delegate as? AppDelegate
                {
                    let managedContext = theAppDelete.persistentContainer.viewContext
                    let record = NSEntityDescription.entity(forEntityName: "record", in: managedContext)
                    record?.setValue(res, forKey: "data")
                    record?.setValue(Date(), forKey: "timestamp")
                    do
                    {
                        try managedContext.save()
                        print("data saved.")
                    }catch let error
                    {
                        print("error: \(error)")
                    }
                }
                self.tableView.reloadData()
                self.indicator.stopAnimating()
            }
        }
    }
}
