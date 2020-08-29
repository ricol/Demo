//
//  ViewController.swift
// Demo
//
//  Created by Ricol Wang on 28/8/20.
//  Copyright © 2020 DeepSpace. All rights reserved.
//

import CoreData
import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var tableView: UITableView!

    let ID = "TableViewCell_ID"
    var data = [String]()
    var value = [String: String]()
    let indicator = UIActivityIndicatorView(style: .medium)

    // MARK: - View Life Cycle

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // schedule a timer to call api every 5 seconds
        RunLoop.main.add(Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.callAPI()
        }, forMode: .common)

        // add the indicator as left barButtonItem
        let barBtn = UIBarButtonItem(customView: indicator)
        navigationItem.leftBarButtonItem = barBtn

        tableView.tableFooterView = UIView() // trick to show blank screen in table view
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        fetchTopRecord()
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

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int
    {
        return data.count
    }

    // MARK: - Private Methods

    private func callAPI()
    {
        print("\(Date()) calling...")
        indicator.startAnimating()
        APIService.github { (json) in
            self.data = json.keys.sorted()
            self.value = json
            // save to coredata
            if let theAppDelete = UIApplication.shared.delegate as? AppDelegate
            {
                let managedContext = theAppDelete.persistentContainer.viewContext
                let record = Record(context: managedContext)
                do
                {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: json, requiringSecureCoding: true)
                    record.data = data
                    record.timestamp = Date()
                    try managedContext.save()
                    NotificationCenter.default.post(name: Notification.Name(Notif.Local.kNotificationNewRecord), object: nil)
                    print("data saved. \(Thread.isMainThread)")
                }
                catch
                {
                    print("error: \(error)")
                }
            }
            self.tableView.reloadData()
            self.indicator.stopAnimating()
        }
    }

    private func fetchTopRecord()
    {
        guard let theAppDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        do
        {
            let request: NSFetchRequest<Record> = Record.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            request.fetchLimit = 1
            let objects = try theAppDelegate.persistentContainer.viewContext.fetch(request)
            if let first = objects.first, let data = first.value(forKey: "data") as? Data, let json = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: String]
            {
                self.data = json.keys.sorted()
                value = json
                tableView.reloadData()
            }
            else
            {
                print("not found")
            }
        }
        catch
        {
            print(error)
        }
    }
}
