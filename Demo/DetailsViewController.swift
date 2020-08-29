//
//  DetailsViewController.swift
// Demo
//
//  Created by Ricol Wang on 29/8/20.
//  Copyright © 2020 DeepSpace. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var tableView: UITableView!

    let ID = "TableViewCell_ID"
    var data = [String]()
    var value = [String: String]()

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        tableView.reloadData()
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
}
