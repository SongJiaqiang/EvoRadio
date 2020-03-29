//
//  FMViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 2020/3/27.
//  Copyright © 2020 JQTech. All rights reserved.
//

import UIKit
import JQFisher
import SnapKit
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
    
    private lazy var playerPanel: UIView = {
        let v = UIView()
        v.backgroundColor = ThemeColors.bgColorDark.alpha(0.6)
        
        return v
    }()
    
    private lazy var coverBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 8
        btn.backgroundColor = UIColor.systemGreen()
        return btn
    }()
    
    private lazy var infoBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "fm_player_info"), for: .normal)
        return btn
    }()

    private lazy var infosView: UIView = {
        let v = UIView()
        
        return v
    }()
    
    private lazy var songNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.systemLightGray6();
        label.font = UIFont.boldSize18()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var programNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.systemLightGray4();
        label.font = UIFont.size14()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var controlView: UIView = {
        let v = UIView()
        
        return v
    }()
    
    private lazy var playBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "fm_player_play"), for: .normal)
        return btn
    }()
    
    private lazy var deleteBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "fm_player_no"), for: .normal)
        return btn
    }()
    
    private lazy var loveBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "fm_player_yes"), for: .normal)
        return btn
    }()
    
    
    fileprivate var dataSourceItems: [FMItem] = []
    fileprivate var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        prepareUI()
        
        setupData()
    }
    
    func prepareUI() {
        self.view.backgroundColor = ThemeColors.bgColorDark
        
        self.view.addSubview(tableView)
        self.view.addSubview(playerPanel)
        playerPanel.addSubview(coverBtn)
        playerPanel.addSubview(infoBtn)
        playerPanel.addSubview(infosView)
        infosView.addSubview(songNameLabel)
        infosView.addSubview(programNameLabel)
        playerPanel.addSubview(controlView)
        controlView.addSubview(playBtn)
        controlView.addSubview(deleteBtn)
        controlView.addSubview(loveBtn)
        
        
        tableView.snp_makeConstraints { (maker) in
            maker.left.top.bottom.equalTo(self.view)
            maker.width.equalTo(100)
        }
        
        playerPanel.snp_makeConstraints { (maker) in
            maker.centerY.equalTo(self.view)
            maker.left.equalTo(tableView.snp_right).offset(16)
            maker.right.equalTo(self.view).offset(-16)
        }
        
        coverBtn.snp_makeConstraints { (maker) in
            maker.top.left.right.equalTo(playerPanel)
            maker.height.equalTo(playerPanel.snp_width)
        }
        
        infoBtn.snp_makeConstraints { (maker) in
            maker.top.equalTo(coverBtn).offset(4)
            maker.right.equalTo(coverBtn).offset(-4)
            maker.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        infosView.snp_makeConstraints { (maker) in
            maker.top.equalTo(coverBtn.snp_bottom).offset(16)
            maker.left.right.equalTo(playerPanel)
        }
        
        songNameLabel.snp_makeConstraints { (maker) in
            maker.left.right.top.equalTo(infosView)
        }
        
        programNameLabel.snp_makeConstraints { (maker) in
            maker.left.right.bottom.equalTo(infosView)
            maker.top.equalTo(songNameLabel.snp_bottom).offset(8)
        }
        
        controlView.snp_makeConstraints { (maker) in
            maker.top.equalTo(infosView.snp_bottom).offset(16)
            maker.left.right.bottom.equalTo(playerPanel)
            maker.height.equalTo(40).priorityHigh()
            maker.bottom.equalTo(playerPanel).priorityLow()
        }
        
        playBtn.snp_makeConstraints { (maker) in
            maker.center.equalTo(controlView)
            maker.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        deleteBtn.snp_makeConstraints { (maker) in
            maker.right.equalTo(playBtn.snp_left).offset(-16)
            maker.centerY.equalTo(controlView)
            maker.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        loveBtn.snp_makeConstraints { (maker) in
            maker.left.equalTo(playBtn.snp_right).offset(16)
            maker.centerY.equalTo(controlView)
            maker.size.equalTo(CGSize(width: 30, height: 30))
        }
        
    }
    
    func loadData() {
        dataSourceItems.removeAll()
        
        let favItem = FMItem(icon: "fm_list_love", name: "私人电波")
        let hotItem = FMItem(icon: "fm_list_hot", name: "Evo精选")
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
    
    func setupData() {
        songNameLabel.text = "- - - - -"
        programNameLabel.text = "- - - - -"
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
