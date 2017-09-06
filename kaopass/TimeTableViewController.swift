//
//  TimeTableViewController.swift
//  KaoPass
//
//  Created by masuda.shigeki on 2017/08/22.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON

class TimeTableViewController: UITableViewController {
    
    var userId = 0
    var tableData: JSON = []
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet var sessonTable: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "finish_registration"){
            let params = ["session_numbers": getSelectedRowIds()]
            
            Alamofire.request("\(Settings.apiBaseUrl)/api/users/\(userId)/session_histories", method: .post, parameters: params).responseJSON {
                response in
                if response.result.isSuccess {}
            }
            
            self.present(self.storyboard!.instantiateViewController(withIdentifier: "thank_you"), animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request("\(Settings.apiBaseUrl)/api/sessions", method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                self.tableData = JSON(response.result.value!)
                self.sessonTable.reloadData()

            }
        }
        
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
        cell.imageView?.image = UIImage(named: "session_dummy.jpg")
        
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
