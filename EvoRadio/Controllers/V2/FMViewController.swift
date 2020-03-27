//
//  FMViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 2020/3/27.
//  Copyright © 2020 JQTech. All rights reserved.
//

import UIKit
import JQFisher
import PureLayout

class FMViewController: ViewController {

    private let tableView: UITableView = UITableView()
    
    fileprivate var dataSourceItems: [FMItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        prepareUI()
    }
    
    func prepareUI() {
        self.view.backgroundColor = ThemeColors.bgColorDark
        
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.showsVerticalScrollIndicator = false
        
        self.view.addSubview(tableView)
        tableView.autoPinEdge(toSuperviewEdge: .left)
        tableView.autoPinEdge(toSuperviewEdge: .top)
        tableView.autoPinEdge(toSuperviewEdge: .bottom)
        tableView.autoSetDimension(.width, toSize: 100)
        
    }
    
    
    func loadData() {
        let item01 = FMItem(icon: "", name: "私人电波")
        let item02 = FMItem(icon: "", name: "Evo精选")
        
        let item11 = FMItem(icon: "", name: "活动场景")
        let item11_01 = FMItem(icon: "", name: "工作学习")
        let item11_02 = FMItem(icon: "", name: "在路上")
        let item11_03 = FMItem(icon: "", name: "编程")
        let item11_04 = FMItem(icon: "", name: "发呆")
        let item11_05 = FMItem(icon: "", name: "浴室")
        item11.subItems = [item11_01, item11_02, item11_03, item11_04, item11_05]
        
        let item12 = FMItem(icon: "", name: "情绪场景")
        let item12_01 = FMItem(icon: "", name: "工作学习")
        let item12_02 = FMItem(icon: "", name: "在路上")
        item12.subItems = [item12_01, item12_02]
        
        let item13 = FMItem(icon: "", name: "文化场景")
        let item13_01 = FMItem(icon: "", name: "工作学习")
        let item13_02 = FMItem(icon: "", name: "在路上")
        item13.subItems = [item13_01, item13_02]
        
        let item14 = FMItem(icon: "", name: "流派场景")
        let item14_01 = FMItem(icon: "", name: "工作学习")
        let item14_02 = FMItem(icon: "", name: "在路上")
        item14.subItems = [item14_01, item14_02]
        
        dataSourceItems.removeAll()
        dataSourceItems.append(contentsOf: [item01, item02, item11, item12, item13, item14])
        
    }
    
    
}

extension FMViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourceItems.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionItem = dataSourceItems[section]
        if let subItems = sectionItem.subItems {
            return subItems.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        let sectionItem = dataSourceItems[indexPath.section]
        if let subItems = sectionItem.subItems {
            let item = subItems[indexPath.row]
            cell.textLabel?.text = item.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.frame = CGRect(w: 100, h: 100)
        header.backgroundColor = ThemeColors.bgColorDark
        
        let iconView = UIImageView()
        iconView.layer.cornerRadius = 20
        iconView.layer.masksToBounds = true
        iconView.backgroundColor = UIColor.green
        
        header.addSubview(iconView)
        iconView.autoAlignAxis(toSuperviewAxis: .vertical)
        iconView.autoAlignAxis(toSuperviewAxis: .horizontal)
        iconView.autoSetDimension(.width, toSize: 40)
        iconView.autoSetDimension(.height, toSize: 40)
        
        let nameLabel = UILabel()
        nameLabel.textColor = ThemeColors.textColorDark
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        
        header.addSubview(nameLabel)
        nameLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        nameLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        
        let arrowView = UIImageView()
        arrowView.backgroundColor = UIColor.gray
        arrowView.isHidden = true
        
        header.addSubview(arrowView)
        arrowView.autoPinEdge(.left, to: .right, of: nameLabel, withOffset: 2)
        arrowView.autoAlignAxis(.horizontal, toSameAxisOf: nameLabel)
        arrowView.autoSetDimension(.width, toSize: 10)
        arrowView.autoSetDimension(.height, toSize: 10)
        
        let sectionItem = dataSourceItems[section]
        iconView.image = UIImage(named: sectionItem.icon)
        nameLabel.text = sectionItem.name
        if let subItems = sectionItem.subItems, subItems.count > 0 {
            arrowView.isHidden = false
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100;
    }
}


class FMItem {
    var icon: String
    var name: String
    var subItems: [FMItem]?
    
    init(icon: String, name: String, subItems: [FMItem]? = nil) {
        self.icon = icon
        self.name = name
        self.subItems = subItems
    }
}
