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
import ObjectMapper

class FMViewController: ViewController {

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .plain)
        tv.dataSource = self
        tv.delegate = self
        tv.register(FMChannelTableViewCell.self, forCellReuseIdentifier: "FMChannelTableViewCell")
        tv.showsVerticalScrollIndicator = false
        tv.backgroundColor = UIColor.clear
        tv.separatorStyle = .none
        
        return tv
    }()
    
    fileprivate var dataSourceItems: [FMItem] = []
    fileprivate var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        prepareUI()
    }
    
    func prepareUI() {
        self.view.backgroundColor = ThemeColors.bgColorDark
        
        
        self.view.addSubview(tableView)
        tableView.autoPinEdge(toSuperviewEdge: .left)
        tableView.autoPinEdge(toSuperviewEdge: .top)
        tableView.autoPinEdge(toSuperviewEdge: .bottom)
        tableView.autoSetDimension(.width, toSize: 100)
    }
    
    func loadData() {
        dataSourceItems.removeAll()
        
        let favItem = FMItem(icon: "local_favorites", name: "私人电波")
        let hotItem = FMItem(icon: "local_favorites", name: "Evo精选")
        dataSourceItems.append(favItem)
        dataSourceItems.append(hotItem)
        
        if let radiosJsonPath = Bundle.main.path(forResource: "api_radios.json", ofType: nil) {
            do {
                let radiosJsonURL = URL(fileURLWithPath: radiosJsonPath)
                let radiosJsonData = try Data(contentsOf: radiosJsonURL)
                if let radiosJson = try JSONSerialization.jsonObject(with: radiosJsonData, options: .allowFragments) as? [String: Any] {
                    if let radiosArray = radiosJson["data"] as? [[String: Any]]{
                        let radios = Mapper<Radio>().mapArray(JSONArray: radiosArray)
                        for radio in radios {
                            if let radioName = radio.radioName, let channels = radio.channels {
                                let radioItem = FMItem(icon: "local_favorites", name: radioName)
                                
                                var channelItems: [FMItem] = []
                                for channel in channels {
                                    if let channelName = channel.channelName {
                                        let channelItem = FMItem(icon: nil, name: channelName)
                                        channelItems.append(channelItem)
                                    }
                                }
                                radioItem.subItems = channelItems
                                dataSourceItems.append(radioItem)
                            }
                        }
                    }
                }
                
            } catch let error {
                print(error)
            }
        }

    }
    
    @objc func onTapSectionDetail(_ gesture: UITapGestureRecognizer) {
        guard let tapedView = gesture.view else {
            return
        }
        
        let index = tapedView.tag
        if index > 0 && index < dataSourceItems.count {
            toggleSectionDetail(atIndex: index)
        }
    }
    
    func toggleSectionDetail(atIndex index: Int) {
        let sectionItem = dataSourceItems[index]
        sectionItem.isOpen = !sectionItem.isOpen
        
        tableView.reloadSections([index], with: .none)
        //TODO: 滚动到合适位置
//        if sectionItem.isOpen {
//            tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
//        }
    }
    
    func toggleCellStatus(atIndexPath indexPath: IndexPath, isOpen: Bool) -> Bool {
        let sectionItem = dataSourceItems[indexPath.section]
        if let subItems = sectionItem.subItems {
            let item = subItems[indexPath.row]
            item.isOpen = isOpen
        }
        
        return sectionItem.isOpen
    }
    
}

extension FMViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourceItems.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionItem = dataSourceItems[section]
        if sectionItem.isOpen, let subItems = sectionItem.subItems {
            return subItems.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FMChannelTableViewCell", for: indexPath) as? FMChannelTableViewCell else {
            return UITableViewCell()
        }
        
        let sectionItem = dataSourceItems[indexPath.section]
        if let subItems = sectionItem.subItems {
            let item = subItems[indexPath.row]
            cell.setupTitle(item.name, isSelected: item.isOpen)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.frame = CGRect(w: 100, h: 100)
        header.backgroundColor = ThemeColors.bgColorDark
        header.tag = section
        
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.layer.cornerRadius = 20
        iconView.layer.masksToBounds = true
        
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
        if let itemIcon = sectionItem.icon {
            iconView.image = UIImage(named: itemIcon)
        }
        nameLabel.text = sectionItem.name
        if let subItems = sectionItem.subItems, subItems.count > 0 {
            arrowView.isHidden = false
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapSectionDetail(_:)))
        header.addGestureRecognizer(tap)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var needReloadPaths: [IndexPath] = []
        
        if let oldIndexPath = selectedIndexPath {
            let sectionIsOpened = toggleCellStatus(atIndexPath: oldIndexPath, isOpen: false)
            if sectionIsOpened {
                needReloadPaths.append(oldIndexPath)
            }
        }
        let _ = toggleCellStatus(atIndexPath: indexPath, isOpen: true)
        needReloadPaths.append(indexPath)
        
//        tableView.reloadRows(at: needReloadPaths, with: .none)
        tableView.reloadData()
        selectedIndexPath = indexPath
    }
}


class FMItem {
    var icon: String?
    var name: String
    var subItems: [FMItem]?
    var isOpen: Bool = false
    
    init(icon: String?, name: String, subItems: [FMItem]? = nil, isOpen: Bool = false) {
        self.icon = icon
        self.name = name
        self.subItems = subItems
        self.isOpen = isOpen
    }
}
