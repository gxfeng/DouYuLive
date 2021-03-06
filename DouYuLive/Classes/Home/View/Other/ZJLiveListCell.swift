//
//  ZJLiveListCell.swift
//  DouYuLive
//
//  Created by 邓志坚 on 2018/8/7.
//  Copyright © 2018年 邓志坚. All rights reserved.
//

import UIKit
private let kItemW = (kScreenW - 10) / 2
private let kItemH = kItemW * 6 / 7
private let kCateCollectionHeadView = "ZJCateCollectionHeadView"

protocol ZJChildCateSelectDelegate : class {
    func childCateSelectAction(cateId: String,index : Int)
}

enum ZJCellType {
    case ZJCellHomeLOL  // lol
    case ZJCellRecreationOutDoor    // 户外
}

// 滚动回调
typealias ScrollBlock = (Bool) -> ()

class ZJLiveListCell: ZJBaseTableCell {
    // 子分类的代理方法
    weak var delegate : ZJChildCateSelectDelegate?
    
    // 滚动回调
    var scrollBlock : ScrollBlock?
    // 全部 id
    var allId : Int? = 1
    // cell 类型
    var cellType : ZJCellType = .ZJCellHomeLOL
    // MArk: 直播列表
    
    private lazy var headView : ZJCateCollectionHeadView = {
        let headView = ZJCateCollectionHeadView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: Adapt(40)))
        headView.backgroundColor = kWhite
        headView.allID = self.allId
        headView.delegate = self
        return headView
    }()
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.itemSize = CGSize(width: kItemW, height: kItemH)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: Adapt(40), width: kScreenW, height: kContentHeight), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = kWhite
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ZJLiveListItem.self, forCellWithReuseIdentifier: ZJLiveListItem.identifier())
        collectionView.register(ZJCateCollectionHeadView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier:kCateCollectionHeadView )
        return collectionView
    }()
    
    var liveRoomList : [ZJLiveItemModel]? {
        
        didSet{
            
            self.collectionView.reloadData()
        }
    }
    
    var outDoorsList : [ZJLiveItemModel]? {
        
        didSet{
            
            self.collectionView.reloadData()
        }
    }
    
    var cateListData : [ZJChildCateList]? {
        
        didSet{
            headView.cateList = self.cateListData
        }
    }
    
    // MARK: 视频列表
    lazy var mainTable : UITableView = {
        let mainTable = UITableView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kContentHeight), style: .plain)
        mainTable.delegate = self
        mainTable.dataSource = self
        mainTable.register(ZJVideoListCell.self, forCellReuseIdentifier: ZJVideoListCell.identifier())
        mainTable.rowHeight = ZJVideoListCell.cellHeight()
        mainTable.backgroundColor = kWhite
        return mainTable
    }()
    override func zj_initWithView() {
        addSubview(collectionView)
        addSubview(mainTable)
        addSubview(headView)

        collectionView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(Adapt(40))
        }
        
        mainTable.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetY = scrollView.contentOffset.y
        
        if offSetY > 120 {
            if (scrollBlock != nil) {
                scrollBlock!(true)
            }
        }else{
            if (scrollBlock != nil) {
                scrollBlock!(false)
            }
        }
    }
    
    
    func configShowView(index : Int) {
        if index == 0 {
            self.collectionView.isHidden = false
            self.mainTable.isHidden = true
        }else if index == 1{
            self.collectionView.isHidden = true
            self.mainTable.isHidden = false
        }
    }
    
    
}


// MARK: - collectionViewDelegate && collectionViewDatasource
extension ZJLiveListCell : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.cellType == .ZJCellHomeLOL{
            return self.liveRoomList?.count ?? 0
        }else if self.cellType == .ZJCellRecreationOutDoor {
            return self.outDoorsList?.count ?? 0
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZJLiveListItem.identifier(), for: indexPath) as! ZJLiveListItem
        
        switch self.cellType {
            
        case .ZJCellHomeLOL:
            
            cell.liveModel = self.liveRoomList?[indexPath.item]
            
        case .ZJCellRecreationOutDoor:
            
            cell.liveModel = self.outDoorsList?[indexPath.item]
            
        }
        
        
        return cell
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kCateCollectionHeadView, for: indexPath) as! ZJCateCollectionHeadView
//        headerView.allID = self.allId
//        headerView.cateList = self.cateListData
//        headerView.delegate = self
//        return headerView
//
//    }
 
}



// MARK: - ZJCateItemSelectedDelegate
extension ZJLiveListCell : ZJCateItemSelectedDelegate {
    
    func cateItemSelected(cateId: String, index: Int) {
        
        delegate?.childCateSelectAction(cateId: cateId ,index: index)
    }
    
}


// MARK: - 视频列表
extension  ZJLiveListCell : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: ZJVideoListCell.identifier(), for: indexPath)
        return cell
    }
}

