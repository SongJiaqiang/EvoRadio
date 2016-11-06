//
//  DownloadedProgramListViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class DownloadedProgramListViewController: ViewController {

    var cellID = "downloadedProgramsCellID"
    
    var tableView: UITableView!
    var dataSource = [Program]()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        
        let label = UILabel()
        view.addSubview(label)
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.text = "以歌单形式展现，利于播放"
        label.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: prepare ui
    func prepareTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.contentInset = UIEdgeInsetsMake(0, 0, playerBarHeight, 0)
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints({(make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        })
        
        tableView.register(SongListTableViewCell.self, forCellReuseIdentifier: cellID)
        
    }
    
    
}

extension DownloadedProgramListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! SongListTableViewCell
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let program = dataSource[(indexPath as NSIndexPath).row]
        
        let listController = SongListViewController()
        listController.program = program
        navigationController?.pushViewController(listController, animated: true)
    }
    
}
