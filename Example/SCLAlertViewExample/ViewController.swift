//
//  ViewController.swift
//  SCLAlertViewExample
//
//  Created by Viktor Radchenko on 6/6/14.
//  Copyright (c) 2014 Viktor Radchenko. All rights reserved.
//

import UIKit

let kSuccessTitle = "Congratulations"
let kErrorTitle = "Connection error"
let kNoticeTitle = "Notice"
let kWarningTitle = "Warning"
let kInfoTitle = "Info"
let kWaitTitle = "Wait"
let kSubtitle = "You've just displayed this awesome Pop Up View"

let kDefaultAnimationDuration = 2.0

class ViewController: UIViewController {
    var wait = SCLAlertView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showSuccess(sender: AnyObject) {
		let alert = SCLAlertView()
		alert.addButton("First Button", target:self, selector:Selector("firstButton"))
		alert.addButton("Second Button") {
			println("Second button tapped")
		}
        alert.showAlert(kSuccessTitle, subTitle: kSubtitle)
    }
    
    @IBAction func showError(sender: AnyObject) {
		SCLAlertView().showAlert("Hold On...", subTitle:"You have not saved your Submission yet. Please save the Submission before accessing the Responses list. Blah de blah de blah, blah. Blah de blah de blah, blah.Blah de blah de blah, blah.Blah de blah de blah, blah.Blah de blah de blah, blah.Blah de blah de blah, blah.", closeButtonTitle:"OK")
    }
    
    @IBAction func showNotice(sender: AnyObject) {
        SCLAlertView().showAlert(kNoticeTitle, subTitle: kSubtitle)
    }
    
    @IBAction func showWarning(sender: AnyObject) {
        SCLAlertView().showAlert(kWarningTitle, subTitle: kSubtitle)
    }
    
    @IBAction func showInfo(sender: AnyObject) {
        SCLAlertView().showAlert("登録が完了しました", subTitle: "ありがとうございます。管理ページより内容を確認してください。", colorStyle: UIColor(red: 255/255, green: 193/255, blue: 33/255, alpha: 1.0))
    }

	@IBAction func showEdit(sender: AnyObject) {
		let alert = SCLAlertView()
		let txt = alert.addTextField(title:"Enter your name")
		alert.addButton("Show Name") {
			println("Text value: \(txt.text)")
		}
		alert.showAlert(kInfoTitle, subTitle:kSubtitle)
	}
	
    @IBAction func showWait(sender: AnyObject) {
        println("start loading...")
        wait.showLoading("ロード中です", subTitle: "データ通信をしています。しばらくお待ちください。")
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector:"hideWait:", userInfo: nil, repeats: false)
    }
    
    func hideWait(timer: NSTimer) {
        println("finish loading...")
        wait.hideView()
    }
    
	func firstButton() {
		println("First button tapped")
	}
}
