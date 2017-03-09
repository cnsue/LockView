//
//  LockView.swift
//  Password
//
//  Created by cnsue on 2017/1/12.
//  Copyright © 2017年 scn. All rights reserved.
//

let pointCount = 8


@objc enum LockButtonStyle : Int {
    case normal
    case selected
    case warning
}

import UIKit
import Foundation

let LineWidth = 1/UIScreen.main.scale
let LineSelectedColor:UIColor = UIColor(red: 28/255.0, green: 168/255.0, blue: 213/255.0, alpha: 1.0)
let LineWarnColor:UIColor = UIColor.red

protocol LockViewDelegate {
    func lockView(lockView : LockView , lockPath:NSString) ->Bool
}

class LockView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var delegate : LockViewDelegate? = nil
    
    private var currentPoint : CGPoint = CGPoint.zero
    
    private var buttonArray : NSMutableArray = NSMutableArray.init()
    
    private var isTrue : Bool = true
    
    override init(frame : CGRect) {
        super.init(frame : frame)
        setUpViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)!
        setUpViews()
    }
    
    func setUpViews() {
        self.backgroundColor = UIColor.clear
        
        let buttonWidth = self.frame.size.width/4
        
        for index in 0...pointCount {
            let originx = (CGFloat)(index%3 * (Int)(buttonWidth + buttonWidth/2))
            let originy = (CGFloat)(index/3 * (Int)(buttonWidth + buttonWidth/2))
            
            let button = LockButton(frame: CGRect(x: originx, y: originy, width: buttonWidth, height: buttonWidth))
            button.buttonStyle = .normal
            button.tag = index
            self.addSubview(button)
        }
    }
    
    func pointWithTouch(touches : NSSet) -> CGPoint {
        let touch : UITouch = touches.anyObject() as! UITouch
        return touch.location(in: self)
    }
    
    func buttonWithPoint(point : CGPoint) -> LockButton? {
        for button : UIView in self.subviews {
            if button.isKind(of: LockButton.self) {
                if button.frame.contains(point) {
                    return button as? LockButton
                }
            }
        }
        return nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let startPoint:CGPoint = self.pointWithTouch(touches: touches as NSSet)
        let button = self.buttonWithPoint(point: startPoint)
        if  (button != nil) && button?.buttonStyle != .selected {
            button!.buttonStyle = .selected
            self.buttonArray.add(button!)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let startPoint = self.pointWithTouch(touches: touches as NSSet)
        let button = self.buttonWithPoint(point: startPoint)
        if  (button != nil) && button?.buttonStyle != .selected {
            button!.buttonStyle = .selected
            self.buttonArray.add(button!)
        }
        else
        {
            self.currentPoint = startPoint
        }
        self .setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let path = NSMutableString()
        for button in self.buttonArray {
            path.append("\((button as AnyObject).tag)")
        }
        let isTrue = self.delegate?.lockView(lockView: self, lockPath: path)
        for button in self.buttonArray {
            let lockButton = button as! LockButton
            if !isTrue! {
                lockButton.buttonStyle = .warning
                self.isTrue = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for button in self.buttonArray {
                let lockButton = button as! LockButton
                lockButton.buttonStyle = .normal
            }
            self.buttonArray.removeAllObjects()
            self.isTrue = true
            self.setNeedsDisplay()
        }
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if self.buttonArray.count == 0 {
            return
        }
        let path = UIBezierPath()
        path.lineWidth = 5;//设置其曲线宽度
        path.lineJoinStyle = .round;//设置其曲线连接样式
        if isTrue {
            LineSelectedColor.withAlphaComponent(0.5).set()
        }
        else
        {
            LineWarnColor.withAlphaComponent(0.5).set()
        }
        for index in 0..<self.buttonArray.count
        {
            let btn = self.buttonArray[index] as! LockButton
            if index == 0 {
                path .move(to: btn.center)
            }
            else
            {
                path.addLine(to: btn.center)
            }
        }
        path.addLine(to: self.currentPoint)
        path.stroke()
    }
    
}

class LockButton: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc var buttonStyle : LockButtonStyle = .normal {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let context : CGContext = UIGraphicsGetCurrentContext()!

        switch self.buttonStyle {
        case .normal:
            context.setStrokeColor(UIColor.gray.cgColor)
            context.setLineWidth(LineWidth)
            let endAngle = CGFloat(M_PI*2)
            context.addArc(center: CGPoint(x: rect.size.width/2, y: rect.size.height/2), radius: rect.size.width/2 - 2*LineWidth, startAngle: 0, endAngle: endAngle, clockwise: true)
            context.drawPath(using: .stroke)
            break
        case .selected:
            context.setStrokeColor(LineSelectedColor.cgColor)
            context.setLineWidth(LineWidth)
            let endAngle = CGFloat(M_PI*2)
            context.addArc(center: CGPoint(x: rect.size.width/2, y: rect.size.height/2), radius: rect.size.width/2 - 2*LineWidth, startAngle: 0, endAngle: endAngle, clockwise: true)
            context.drawPath(using: .stroke)
            
            context.setFillColor(LineSelectedColor.cgColor)
            context.addArc(center: CGPoint(x: rect.size.width/2, y: rect.size.height/2), radius: 5.0, startAngle: 0, endAngle: endAngle, clockwise: true)
            context.drawPath(using: .fill)
            break
        case .warning:
            context.setStrokeColor(LineWarnColor.cgColor)
            context.setLineWidth(LineWidth)
            let endAngle = CGFloat(M_PI*2)
            context.addArc(center: CGPoint(x: rect.size.width/2, y: rect.size.height/2), radius: rect.size.width/2 - 2*LineWidth, startAngle: 0, endAngle: endAngle, clockwise: true)
            context.drawPath(using: .stroke)
            context.setFillColor(LineWarnColor.cgColor)
            context.addArc(center: CGPoint(x: rect.size.width/2, y: rect.size.height/2), radius: 5.0, startAngle: 0, endAngle: endAngle, clockwise: true)
            context.drawPath(using: .fill)
            
            break
        }

    }
    
}
