//
//  CollectionScene.swift
//  Demo
//
//  Created by zhuchao on 15/5/13.
//  Copyright (c) 2015年 zhuchao. All rights reserved.
//

import UIKit
import EasyIOS
import Bond
import SVProgressHUD

class CollectionScene: EUScene,UICollectionViewDelegate {

    var sceneModel = CollectionSceneModel()
    var collectionView:UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBarButton(.LEFT, title: "返回", fontColor: UIColor.greenColor())
        self.sceneModel.req.requestNeedActive.value = true
        
        self.sceneModel.req.state *->> Bond<RequestState>(){
            switch $0 {
            case .Sending :
                SVProgressHUD.show()
            case .Success,.SuccessFromCache :
                SVProgressHUD.dismiss()
                self.collectionView?.pullToRefreshView?.stopAnimating()
            case .Error :
                SVProgressHUD.showErrorWithStatus("数据加载失败")
            default :
                return
            }
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //接收xml里的下拉刷新事件
    func handlePullRefresh (collectionView:UICollectionView){
        self.sceneModel.req.requestNeedActive.value = true
    }
    
    //接收xml里的上拉加载事件
    func handleInfinite (collectionView:UICollectionView){
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(3.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            collectionView.infiniteScrollingView?.stopAnimating()
            collectionView.infiniteScrollingView?.setEnded()
        }
    }
    
    override func eu_collectionViewDidLoad(collectionView: UICollectionView?) {
        self.collectionView = collectionView
        collectionView?.delegate = self
        self.sceneModel.viewModelList.map { (data:CollectionCellViewModel,index:Int) -> UICollectionViewCell in
            return collectionView!.dequeueReusableCell(
                "cell",
                forIndexPath:NSIndexPath(forItem: index, inSection: 0),
                target: self,bind:data) as UICollectionViewCell
            } ->> self.eu_collectionViewDataSource!
    }

    override func leftButtonTouch() {
        URLNavigation.dismissCurrentAnimated(true)
    }
}
