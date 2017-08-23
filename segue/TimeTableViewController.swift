//
//  TimeTableViewController.swift
//  segue
//
//  Created by masuda.shigeki on 2017/08/22.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//

import UIKit
import SwiftyJSON

class TimeTableViewController: UITableViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBAction func doneClick(_ sender: Any) {
        self.navigationController!.pushViewController(self.storyboard!.instantiateViewController(withIdentifier: "thank_you"), animated: true)
    }
    var tableData: JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = Bundle.main.path(forResource: "sessions", ofType: "json")
        
        let jsonStr = try? String(contentsOfFile: path!)
        tableData = JSON.parse(jsonStr!)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.tableView.allowsMultipleSelection = true
        
   }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let rowData = tableData[indexPath.row]
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["time"].string
        cell.imageView?.image = UIImage(named: "session_\(indexPath.row).jpg")
        
        return cell
    }
    
    
    // セル選択時
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        cell?.accessoryType = .checkmark
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    // セルの選択解除時
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        cell?.accessoryType = .none
        if(getSelectedRowIds().count > 0){
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func getSelectedRowIds() -> [Int] {
        var numbers = [Int]()
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            for i in 0 ..< indexPaths.count {
                numbers.append(indexPaths[i].row)
                
            }
        }
        return numbers
    }
}
