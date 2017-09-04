//
//  DoEnterViewController.swift
//  KaoPass
//
//  Created by masuda.shigeki on 2017/08/24.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class DoEnterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var name: String = ""
    var sessionIds: [Int] = []
    var tableData: JSON = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sessonTable: UITableView!
    @IBOutlet weak var message: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request("\(Settings.apiBaseUrl)/api/sessions", method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                self.tableData = JSON(response.result.value!)
                self.sessonTable.reloadData()
                
            }
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        message.text = "\(self.name)様の登録済みセッション"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let rowData = tableData[sessionIds[indexPath.row]]
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["time"].string
        cell.imageView?.image = UIImage(named: "session_dummy")
        return cell
    }
}
