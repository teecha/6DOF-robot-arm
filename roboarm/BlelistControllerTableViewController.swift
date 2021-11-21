//
//  BlelistControllerTableViewController.swift
//  roboarm
//
//  Created by Subrahmanya Sai Krishna Teja on 10/12/21.
//

import UIKit

class BlelistControllerTableViewController: UITableViewController {
    var names = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "bleCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bleCell", for: indexPath)
        cell.textLabel?.text = names[indexPath.row]
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.backgroundColor = .gray
        cell.alpha = 0.7
        return cell
    }
}
