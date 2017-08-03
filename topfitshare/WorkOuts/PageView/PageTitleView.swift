//
//  PageTitleView.swift
//  DYTV
//
//  Created by coderLL on 16/9/28.
//  Copyright © 2016 coderLL. All rights reserved.
//

import UIKit

protocol PageTitleViewDelegate : class {
    func pageTitltView(_ titleView: PageTitleView, selectedIndex index : Int)
}

private let kScrollLineH : CGFloat = 2
private let kNormalColor : (CGFloat, CGFloat, CGFloat) = (255, 255, 255)
private let kSelectColor : (CGFloat, CGFloat, CGFloat) = (255, 0, 0)

class PageTitleView: UIView {
    
    fileprivate var currentIndex : Int = 0
    var titles:[String]
    var titleType:String
    weak var delegate : PageTitleViewDelegate?
    
    fileprivate lazy var  titleLabels: [UIView] = [UIView]()
    
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
        return scrollView
    }()
    
    fileprivate lazy var scrollLine: UIView = {
        let scrollLine = UIView()
        scrollLine.backgroundColor = UIColor.red
        return scrollLine
    }()

    init(frame: CGRect, titles: [String], type: String) {
        self.titles = titles;
        self.titleType = type
        
        super.init(frame: frame);
        
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension PageTitleView {
    
    fileprivate func setupUI() {
        
        addSubview(scrollView)
        scrollView.frame = bounds
        scrollView.backgroundColor = UIColor(red: 39.0/255, green: 54.0/255, blue: 183.0/255, alpha: 1.0) //fitshare blue
        
        if titleType == "image" {
            setupTitleImages()
 //           setupBottomLineAndScrollLine()
            setupTopLineAndScrollLine()
        }else{
            setupTitleLabels()
            setupBottomLineAndScrollLine()
        }
        
    }
    fileprivate func setupTitleLabels() {
        
        let labelW : CGFloat = frame.width/CGFloat(titles.count)
        let labelH : CGFloat = frame.height - kScrollLineH
        let labelY : CGFloat = 0
        
        for (index, title) in titles.enumerated() {
            let label = UILabel()
            
            label.text = title
            label.tag = index
            label.font = UIFont.systemFont(ofSize: 16.0)
            label.textColor = UIColor(red: kNormalColor.0/255.0, green: kNormalColor.1/255.0, blue: kNormalColor.2/255.0, alpha: 1.0)
            label.textAlignment = .center
            
            let labelX : CGFloat = labelW * CGFloat(index)
            label.frame = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)
            
            scrollView.addSubview(label)
            titleLabels.append(label)
            
            label.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(PageTitleView.titleLabelClick(_:)))
            label.addGestureRecognizer(tapGes)
        }
    }
    fileprivate func setupTitleImages() {
        
        let labelW : CGFloat = frame.width/CGFloat(titles.count)// - 240/CGFloat(titles.count)
        let labelH : CGFloat = frame.height - kScrollLineH
        let labelY : CGFloat = 0
        
        let imageW : CGFloat = 20
        let imageH : CGFloat = 20
        let scalX : CGFloat = (labelW - imageW)/2
        let scalY : CGFloat = (labelH - imageH)/2

        for (index, title) in titles.enumerated() {
            
            var image = UIImageView()
            let pView = UIView()
            
            image = UIImageView.init(image: UIImage.init(named: title))
            pView.tag = index
            
            let labelX : CGFloat = labelW * CGFloat(index)
            image.frame = CGRect(x: scalX, y: scalY, width: imageW, height: imageH)
            pView.frame = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)
            
            pView.addSubview(image)
            scrollView.addSubview(pView)
            titleLabels.append(pView)
            
            
            pView.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(PageTitleView.titleLabelClick(_:)))
            pView.addGestureRecognizer(tapGes)
        }
    }
    
    fileprivate func setupBottomLineAndScrollLine() {
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.lightGray
        let lineH : CGFloat = 0.5
        bottomLine.frame = CGRect(x: 0, y: frame.height - lineH, width: frame.width, height: lineH)
        addSubview(bottomLine)
        
        guard let firstLabel = titleLabels.first else { return}
        scrollView.addSubview(scrollLine)
        
        scrollLine.frame = CGRect(x: firstLabel.frame.origin.x, y: frame.height - kScrollLineH, width: firstLabel.frame.width, height: kScrollLineH)
    }
    
    fileprivate func setupTopLineAndScrollLine(){
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.lightGray
        let lineH : CGFloat = 0.5
        bottomLine.frame = CGRect(x: 0, y: frame.height - lineH, width: frame.width, height: lineH)
        addSubview(bottomLine)
        
        guard let firstLabel = titleLabels.first else { return}
        scrollView.addSubview(scrollLine)
        
        scrollLine.frame = CGRect(x: firstLabel.frame.origin.x, y: 0, width: firstLabel.frame.width, height: kScrollLineH)
    }
}


extension PageTitleView {
    @objc fileprivate func titleLabelClick(_ tapGes: UITapGestureRecognizer) {
        
        guard let currentLabel = tapGes.view else  { return }
        
        
        if currentLabel.tag == currentIndex { return }
        
        currentIndex = currentLabel.tag
        
        let scrollLineX = CGFloat(currentLabel.tag) * scrollLine.frame.width
        
        UIView.animate(withDuration: 0.15, animations: { 
            self.scrollLine.frame.origin.x = scrollLineX
        }) 
        
        delegate?.pageTitltView(self, selectedIndex: currentIndex)
    }
}

extension PageTitleView {
    func setTitleWithProgress(_ progress: CGFloat, sourceIndex: Int, targetIndex: Int)  {
        
        let sourceLabel = titleLabels[sourceIndex]
        let targetLabel = titleLabels[targetIndex]
        
        
        let moveTotalX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
        let moveX = moveTotalX * progress
        scrollLine.frame.origin.x = sourceLabel.frame.origin.x + moveX
        
        currentIndex = targetIndex
    }
}
