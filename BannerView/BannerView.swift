//
//  BannerView.swift
//  BannerView
//
//  Created by Tanfanfan on 16/6/7.
//  Copyright © 2016年 Tanfanfan. All rights reserved.
//

import UIKit


@IBDesignable

public extension UIView {
    
    
}

public class BannerView: UIView {
    
    public var images = [UIImage]() {
        didSet {
            pageControl.numberOfPages = images.count
            pageControl.hidesForSinglePage = !carouselForSinglePage
            collectionView.reloadData()
            scrollToMiddle()
        }
    }
    
    public var duration: NSTimeInterval = 2.5
    
    public var carouselForSinglePage = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public var carouselAnimate = true
    
    private var timer: NSTimer?
    
    @objc private func addTimer() {
        
        if let _ = timer {
            return
        }
        
        timer = NSTimer(timeInterval: duration, target: self, selector: #selector(BannerView.carousel), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        timer?.fire()
    }
    
    private func removeTimer() {
        
        guard let _ = timer else {
            return
        }
        timer?.invalidate()
        timer = nil
    }
    
    
    @objc private func carousel() {
        
        guard let cell = collectionView.visibleCells().first else {
            return
        }
        
        
        guard let indexPath = collectionView.indexPathForCell(cell) else {
            return
        }
        
        if !carouselAnimate {
            
            removeTimer()
        }
        
        let item  = indexPath.item + 1
        if item >= images.count  {
            let middleIndexPath = NSIndexPath(forItem:  0 , inSection:  self.middleSection + 1)
            self.collectionView.scrollToItemAtIndexPath(middleIndexPath, atScrollPosition: .None, animated: true)
            pageControl.currentPage = 0
            self.performSelector(#selector(BannerView.scrollToMiddle), withObject: nil, afterDelay: 0.25)
            return
            
        }
        
        let middleIndexPath = NSIndexPath(forItem:  item , inSection:  self.middleSection)
        self.collectionView.scrollToItemAtIndexPath(middleIndexPath, atScrollPosition: .None, animated: true)
        pageControl.currentPage = item
    }
    
    public var scrollDirection: UICollectionViewScrollDirection = .Horizontal {
        didSet {
            let cell = collectionView.visibleCells().first
            let indexPath = collectionView.indexPathForCell(cell!)
            layout.scrollDirection = scrollDirection
            collectionView.reloadData()
            collectionView.scrollToItemAtIndexPath(indexPath!, atScrollPosition: .None, animated: false)
        }
    }
    
    private(set) lazy var pageControl: UIPageControl = {
       let pageControl =  UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    
   private class BannerViewCell: UICollectionViewCell {
    
        lazy var imageView: UIImageView = {
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
    
        override init(frame: CGRect) {
            super.init(frame: frame)
            initUI()
        }
    
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            initUI()
        }
    
        private func initUI() {
            let views = ["imageView":imageView]
            addSubview(imageView)
            let vhConstraints = [
                NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: [], metrics: nil, views: views),
                NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: [], metrics: nil, views: views)
            ].flatMap { (constraints) -> [NSLayoutConstraint] in
                return constraints
            }
            NSLayoutConstraint.activateConstraints(vhConstraints)
            
        }

    }
    
    private static let carouselSection = 3
    private static let section = 1
    private static  let fristItemInMiddleSection = 0
    private static  let reuseIdentifier = String(BannerViewCell)
    private  var section: Int {
       return (carouselForSinglePage || images.count > self.dynamicType.section) ?
            self.dynamicType.carouselSection : self.dynamicType.section
    }
    private  var middleSection: Int {
        
        return (section == self.dynamicType.section) ? self.dynamicType.section : (section / 2)
    }
    
    private lazy var collectionView: UICollectionView = { [unowned self] in
    
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsZero
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let view = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        view.delegate   = self
        view.dataSource = self
        view.pagingEnabled = true
        view.bounces = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.registerClass(BannerViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return view
    }()
    
    
    private var layout: UICollectionViewFlowLayout {
        
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    
    typealias DoSomething = Void ->Void
    
    private func delay(duration: NSTimeInterval,dosomething: DoSomething) {
        let delta = Int64(Double(NSEC_PER_USEC) * duration)
        dispatch_after( dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue()) { 
            dosomething()
        }
    }
    
    
    @objc private func scrollToMiddle() {
        
        let indexPath = NSIndexPath(forItem:  self.dynamicType.fristItemInMiddleSection, inSection:  middleSection)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
    }
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        do {
            let views = ["collectionView":collectionView]
            addSubview(collectionView)
            // flatMap 将二维数据转为一维数组
            let vhConstraints = [
                NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil, views: views),
                NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: [], metrics: nil, views: views)
                ].flatMap { (constraints) -> [NSLayoutConstraint] in
                return constraints
            }
            NSLayoutConstraint.activateConstraints(vhConstraints)
        }
        
        do {
            addSubview(pageControl)
            pageControl.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
            pageControl.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -8).active = true
        }
        
    }
    
    public override func didMoveToSuperview() {
        
        self .performSelector(#selector(BannerView.scrollToMiddle), withObject: nil, afterDelay: 0.01)
        addTimer()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard  let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.itemSize = bounds.size
    }

}

extension BannerView: UICollectionViewDataSource,UICollectionViewDelegate {
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return section;
    }
    
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.dynamicType.reuseIdentifier, forIndexPath: indexPath) as?  BannerViewCell else {
            return UICollectionViewCell()
        }
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        print(indexPath)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if images.count == 1 {
            return
        }
        
        //避免出现闪烁
        delay(0.01) { [unowned self] in
            guard let cell = self.collectionView.visibleCells().first else {
                return
            }
            
            guard let indexPath =  self.collectionView.indexPathForCell(cell) else {
                return
            }
            self.pageControl.currentPage = indexPath.item
            let middleIndexPath = NSIndexPath(forItem:  indexPath.item, inSection:  self.middleSection)
            self.collectionView.scrollToItemAtIndexPath(middleIndexPath, atScrollPosition: .None, animated: false)
        }
        
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        removeTimer()
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        NSObject .cancelPreviousPerformRequestsWithTarget(self, selector: #selector(BannerView.addTimer), object: nil)
        self.performSelector(#selector(BannerView.addTimer), withObject: nil, afterDelay: 1)
    }
    
}
