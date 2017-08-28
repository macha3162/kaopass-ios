//
//  DoEnterViewController.swift
//  segue
//
//  Created by masuda.shigeki on 2017/08/24.
//  Copyright © 2017年 masuda.shigeki. All rights reserved.
//

import UIKit
import SwiftyJSON

class DoEnterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var name: String = ""
    var sessionIds: [Int] = []
    var tableData: JSON = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var message: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = Bundle.main.path(forResource: "sessions", ofType: "json")
        let jsonStr = try? String(contentsOfFile: path!)
        tableData = JSON.parse(jsonStr!)
        
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
        cell.imageView?.image = UIImage(named: "session_\(rowData["number"]).jpg")
        return cell
    }
}
