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
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let rowData = tableData[sessionIds[indexPath.row]]
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["time"].string
        cell.imageView?.image = UIImage(named: "session_\(indexPath.row).jpg")
        print(cell)
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
