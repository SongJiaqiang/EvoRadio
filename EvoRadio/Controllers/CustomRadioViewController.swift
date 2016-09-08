//
//  CustomRadioViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/24.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class CustomRadioViewController: ViewController {
    let cellID = "customCellID"

    var tableView = UITableView()
    var dataSource = [Radio]()
    var selectedRadios = [Radio]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupBackButton()
        title = "定制电台"
        let rightItem = UIBarButtonItem(title: "确定", style: .Plain, target: self, action: #selector(CustomRadioViewController.rightItemPressed))
        navigationItem.rightBarButtonItem = rightItem
        
        prepareTableView()
        
        let customRadiosData = CoreDB.getCustomRadios()
        selectedRadios = [Radio](dictArray: customRadiosData)
        
        api.fetch_all_channels({[weak self] (items) in
            
            let allRadios = items
            self?.dataSource.appendContentsOf(allRadios)
            
            self?.tableView.reloadData()
            }, onFailed: nil)
    }
    
    func prepareTableView() {
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
    }
    
    func rightItemPressed() {
        if selectedRadios.count != 3 {
            return
        }
        
        CoreDB.saveCustomRadios(Radio.dictArrayForRadios(selectedRadios))
        
        NSNotificationCenter.defaultCenter().postNotificationName("CustomRadiosChanged", object: nil)
        navigationController?.popViewControllerAnimated(true)
    }
}


extension CustomRadioViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID)
        
        let radio = dataSource[indexPath.row]
        cell!.textLabel?.text = radio.radioName
        cell?.textLabel?.textColor = UIColor.grayColor7()

        let aView = UIImageView()
        aView.image = UIImage(named: "icon_check")
        aView.frame = CGRectMake(0, 0, 20, 20)
        cell?.accessoryView = aView
        
        
        for r in selectedRadios {
            if r.radioID == radio.radioID {
                cell?.textLabel?.textColor = UIColor.grayColor5()
                if selectedRadios.count != 3 {
                    aView.image = UIImage(named: "icon_checked_error")
                }else {
                    aView.image = UIImage(named: "icon_checked")
                }
                break
            }
        }

        return cell!
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let radio = dataSource[indexPath.row]
        
        for i in 0..<selectedRadios.count {
            let r = selectedRadios[i]
            if r.radioID == radio.radioID {
                selectedRadios.removeAtIndex(i)
                tableView.reloadData()
                return
            }
        }

        selectedRadios.append(radio)
        tableView.reloadData()
    }
    
}

