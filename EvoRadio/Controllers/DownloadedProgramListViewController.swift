//
//  DownloadedProgramListViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class DownloadedProgramListViewController: ViewController {

    let cellID = "downloadedProgramsCellID"
    
    let tableView = UITableView()
    var dataSource = [Program]()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.greenColor()
        
        prepareTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: prepare ui
    func prepareTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clearColor()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, playerBarHeight, 0)
        tableView.separatorStyle = .None
        tableView.snp_makeConstraints(closure: {(make) in
            make.edges.equalTo(UIEdgeInsetsZero)
        })
        
        tableView.registerClass(SongListTableViewCell.self, forCellReuseIdentifier: cellID)
        
    }
    
    
}

extension DownloadedProgramListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! SongListTableViewCell
        
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let program = dataSource[indexPath.row]
        
        let listController = SongListViewController()
        listController.program = program
        navigationController?.pushViewController(listController, animated: true)
    }
    
}