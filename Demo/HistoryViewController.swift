//
//  HistoryViewController.swift
// Demo
//
//  Created by Ricol Wang on 28/8/20.
//  Copyright © 2020 DeepSpace. All rights reserved.
//

import CoreData
import SVPullToRefresh
import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var btnHint: UIButton!
    @IBOutlet var tableView: UITableView!

    let ID = "HistoryTableViewCell_ID"
    let SEGUE_ID_SHOWDETAILS = "SegueID_ShowDetails"
    let df = DateFormatter()
    var observer: Any?
    var bShowNewRecord = false

    var data = [Record]()

    // MARK: - View Life Cycle

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tableView.tableFooterView = UIView() // trick to show blank screen in table view
        df.dateFormat = "MM-dd-yyyy HH:mm:ss"
        tableView.addPullToRefresh {
            self.bShowNewRecord = true
            self.loadData()
        }

        btnHint.alpha = 0
        btnHint.isHidden = true

        observer = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: Notif.Local.kNotificationNewRecord), object: nil, queue: nil, using: { _ in
            self.btnHint.isHidden = false
            self.btnHint.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.btnHint.alpha = 1
            }
        })
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
        cell.backgroundColor = UIColor.clear
        if let date = row.timestamp
        {
            cell.textLabel?.text = df.string(from: date)
            if bShowNewRecord, indexPath.row == 0
            {
                cell.backgroundColor = UIColor.systemGreen
            }
        }
        return cell
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int
    {
        return data.count
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?)
    {
        if let indexpath = tableView.indexPathForSelectedRow, let id = segue.identifier, id == SEGUE_ID_SHOWDETAILS, let detailsVC = segue.destination as? DetailsViewController
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
                }
                catch
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
            data = objects
            tableView.reloadData()
            tableView.pullToRefreshView.stopAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.btnHint.alpha = 0
            }) { _ in
                self.btnHint.isHidden = true
            }
        }
        catch
        {
            print(error)
        }
    }

    // MARK: - IBAction Methods

    @IBAction func btnHintOnTapped(_: Any)
    {
        bShowNewRecord = true
        loadData()
    }

    @IBAction func btnClearOnTapped(_: Any)
    {
        let alert = UIAlertController(title: "Confirm", message: "Clear all history records?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { _ in
            guard let theAppDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            do
            {
                let request: NSFetchRequest<NSFetchRequestResult> = Record.fetchRequest()
                let delete = NSBatchDeleteRequest(fetchRequest: request)
                try theAppDelegate.persistentContainer.viewContext.execute(delete)
                self.data = []
                self.tableView.reloadData()
                self.tableView.pullToRefreshView.stopAnimating()
                UIView.animate(withDuration: 0.3, animations: {
                    self.btnHint.alpha = 0
                }) { _ in
                    self.btnHint.isHidden = true
                }
            }
            catch
            {
                print(error)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(yes)
        present(alert, animated: true, completion: nil)
    }
}
