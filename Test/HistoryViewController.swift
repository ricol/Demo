//
//  HistoryViewController.swift
//  Test
//
//  Created by Ricol Wang on 28/8/20.
//  Copyright © 2020 DeepSpace. All rights reserved.
//

import UIKit
import CoreData
import SVPullToRefresh

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var lblHint: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let ID = "HistoryTableViewCell_ID"
    let SEGUE_ID_SHOWDETAILS = "SegueID_ShowDetails"
    let df = DateFormatter()
    var observer: Any?
    
    var data = [Record]()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tableView.tableFooterView = UIView() //trick to show blank screen in table view
        df.dateFormat = "MM-dd-yyyy HH:mm:ss"
        self.tableView.addPullToRefresh {
            self.loadData()
        }
        
        self.lblHint.alpha = 0
        
        observer = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: Notif.Local.kNotificationNewRecord), object: nil, queue: nil) { (notif) in
            UIView.animate(withDuration: 0.3) {
                self.lblHint.alpha = 1
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    deinit
    {
        if let observer = self.observer
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let row = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath)
        if let date = row.timestamp
        {
            cell.textLabel?.text = df.string(from: date)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let indexpath = self.tableView.indexPathForSelectedRow, let id = segue.identifier, id == SEGUE_ID_SHOWDETAILS, let detailsVC = segue.destination as? DetailsViewController
        {
            let row = data[indexpath.row]
            if let data = row.data, let timestamp = row.timestamp
            {
                do
                {
                    if let dict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: String]
                    {
                        detailsVC.title = df.string(from: timestamp)
                        detailsVC.data = dict.keys.sorted()
                        detailsVC.value = dict
                    }
                }catch let error
                {
                    print(error)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadData()
    {
        guard let theAppDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        do
        {
            let request: NSFetchRequest<Record> = Record.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            let objects = try theAppDelegate.persistentContainer.viewContext.fetch(request)
            self.data = objects
            self.tableView.reloadData()
            self.tableView.pullToRefreshView.stopAnimating()
            UIView.animate(withDuration: 0.3) {
                self.lblHint.alpha = 0
            }
        }catch let error
        {
            print(error)
        }
    }

}
