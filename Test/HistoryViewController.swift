//
//  HistoryViewController.swift
//  Test
//
//  Created by Ricol Wang on 28/8/20.
//  Copyright © 2020 DeepSpace. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    let ID = "HistoryTableViewCell_ID"
    let df = DateFormatter()
    
    var data = [NSManagedObject]()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tableView.tableFooterView = UIView() //trick to blank screen in table view
        df.dateFormat = "MM-dd-yyyy HH:mm:ss"
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let row = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath)
        if let date = row.value(forKey: "timestamp") as? Date
        {
            cell.textLabel?.text = df.string(from: date)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    
    // MARK: - Private Methods
    
    private func loadData()
    {
        guard let theAppDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        do
        {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            if let objects = try theAppDelegate.persistentContainer.viewContext.fetch(request) as? [NSManagedObject]
            {
                self.data = objects
                self.tableView.reloadData()
                print("load \(objects.count) records")
            }else
            {
                print("not found")
            }
        }catch let error
        {
            print(error)
        }
    }

}
