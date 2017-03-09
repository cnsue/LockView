//
//  ViewController.swift
//  LockView
//
//  Created by cnsue on 2017/3/9.
//  Copyright © 2017年 scn. All rights reserved.
//

import UIKit

let LockPath = "LockPath"

class ViewController: UIViewController,LockViewDelegate {
    
    private var lockPath : NSString?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        verifyWithLockView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func lockView(lockView: LockView, lockPath: NSString) -> Bool {
        
        let path = UserDefaults.standard.object(forKey: LockPath) as? NSString
        if path != nil {
            if path!.isEqual(to: lockPath as String) {
                let alert = UIAlertController(title: "提示", message: "验证成功", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(alert, animated:true, completion: nil)
                return true
            }
        }
        else
        {
            if self.lockPath == nil {
                self.lockPath = lockPath as NSString?
                return true
            }
            else
            {
                
                if (self.lockPath?.isEqual(to: lockPath as String))!  {
                    let alert = UIAlertController(title: "提示", message: "设置完成", preferredStyle: .alert)
                    
                    UserDefaults.standard.setValue(self.lockPath, forKey: LockPath)
                    alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                    self.present(alert, animated:true, completion: nil)
                    return true
                }
                else
                {
                    let alert = UIAlertController(title: "提示", message: "两次不一致，重试", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                    self.present(alert, animated:true, completion: nil)
                    return false
                }
            }
        }
        return false
    }
    func verifyWithLockView() {
        let lockView = LockView(frame: CGRect(x: 20, y: 100, width: self.view.frame.size.width-100, height: self.view.frame.size.width - 100))
        lockView.center = self.view.center
        lockView.delegate = self
        self.view.addSubview(lockView)
    }
}

