//
//  SCLAlertView.swift
//  SCLAlertView Example
//
//  Created by Viktor Radchenko on 6/5/14.
//  Copyright (c) 2014 Viktor Radchenko. All rights reserved.
//

import Foundation
import UIKit

// Pop Up Styles
public enum SCLAlertViewStyle {
    case Alert, Loading
}

// Action Types
public enum SCLActionType {
    case None, Selector, Closure
}

// Button sub-class
public class SCLButton: UIButton {
    var actionType = SCLActionType.None
    var target:AnyObject!
    var selector:Selector!
    var action:(()->Void)!

    public init() {
        super.init(frame: CGRectZero)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    override public init(frame:CGRect) {
        super.init(frame:frame)
    }
}

// Allow alerts to be closed/renamed in a chainable manner
// Example: SCLAlertView().showSuccess(self, title: "Test", subTitle: "Value").close()
public class SCLAlertViewResponder {
    let alertview: SCLAlertView

    // Initialisation and Title/Subtitle/Close functions
    public init(alertview: SCLAlertView) {
        self.alertview = alertview
    }

    public func setTitle(title: String) {
        self.alertview.labelTitle.text = title
    }

    public func setSubTitle(subTitle: String) {
        self.alertview.viewText.text = subTitle
    }

    public func close() {
        self.alertview.hideView()
    }
}

// The Main Class
public class SCLAlertView: UIViewController, UITextFieldDelegate {
    let kDefaultShadowOpacity: CGFloat = 0.7
    let kTitleTop:CGFloat = 10.0
    let kTitleHeight:CGFloat = 40.0
    let kWindowWidth: CGFloat = 240.0
    var kWindowHeight: CGFloat = 158.0
    var kTextHeight: CGFloat = 90.0

    // UI Colour
    var viewColor = UIColor()
    var pressBrightnessFactor = 0.85

    // Members declaration
    var baseView = UIView()
    var labelTitle = UILabel()
    var viewText = UITextView()
    var contentView = UIView()
    var durationTimer: NSTimer!
    private var inputs = [UITextField]()
    private var buttons = [SCLButton]()
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    required public init() {
        super.init(nibName:nil, bundle:nil)
        // Set up main view
        view.frame = UIScreen.mainScreen().bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        view.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:kDefaultShadowOpacity)
        view.addSubview(baseView)
        // Base View
        baseView.frame = view.frame
        baseView.addSubview(contentView)
        // Content View
        contentView.backgroundColor = UIColor(white:1, alpha:1)
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.addSubview(labelTitle)
        contentView.addSubview(viewText)
        // Title
        labelTitle.numberOfLines = 1
        labelTitle.textAlignment = .Center
        labelTitle.font = UIFont.systemFontOfSize(20)
        labelTitle.frame = CGRect(x:12, y:kTitleTop, width: kWindowWidth - 24, height:kTitleHeight)
        // View text
        viewText.editable = false
        viewText.textAlignment = .Center
        viewText.textContainerInset = UIEdgeInsetsZero
        viewText.textContainer.lineFragmentPadding = 0;
        viewText.font = UIFont.systemFontOfSize(14)
        // Colours
        contentView.backgroundColor = UIColorFromRGB(0xFFFFFF)
        labelTitle.textColor = UIColorFromRGB(0x4D4D4D)
        viewText.textColor = UIColorFromRGB(0x4D4D4D)
        contentView.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var sz = UIScreen.mainScreen().bounds.size
        let sver = UIDevice.currentDevice().systemVersion as NSString
        let ver = sver.floatValue
        if ver < 8.0 {
            // iOS versions before 7.0 did not switch the width and height on device roration
            if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
                let ssz = sz
                sz = CGSize(width:ssz.height, height:ssz.width)
            }
        }
        // Set background frame
        view.frame.size = sz
        // Set frames
        var x = (sz.width - kWindowWidth) / 2
        var y = (sz.height - kWindowHeight) / 2
        contentView.frame = CGRect(x:x, y:y, width:kWindowWidth, height:kWindowHeight)
        // Subtitle
        y = kTitleTop + kTitleHeight
        viewText.frame = CGRect(x:12, y:y, width: kWindowWidth - 24, height:kTextHeight)
        // Text fields
        y += kTextHeight + 14.0
        for txt in inputs {
            txt.frame = CGRect(x:12, y:y, width:kWindowWidth - 24, height:30)
            txt.layer.cornerRadius = 3
            y += 40
        }
        // Buttons
        for btn in buttons {
            btn.frame = CGRect(x:12, y:y, width:kWindowWidth - 24, height:35)
            btn.layer.cornerRadius = 3
            y += 45.0
        }
    }
    
    override public func touchesEnded(touches:Set<NSObject>, withEvent event:UIEvent) {
        if event.touchesForView(view)?.count > 0 {
            view.endEditing(true)
        }
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    public func addTextField(title:String?=nil)->UITextField {
        // Update view height
        kWindowHeight += 40.0
        // Add text field
        let txt = UITextField()
        txt.delegate = self
        txt.borderStyle = UITextBorderStyle.RoundedRect
        txt.font = UIFont.systemFontOfSize(14)
        txt.autocapitalizationType = UITextAutocapitalizationType.Words
        txt.clearButtonMode = UITextFieldViewMode.WhileEditing
        txt.layer.masksToBounds = true
        txt.layer.borderWidth = 1.0
        if title != nil {
            txt.placeholder = title!
        }
        contentView.addSubview(txt)
        inputs.append(txt)
        //Gesture Recognizer for tapping outside the textinput
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard"))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        return txt
    }

    public func addButton(title:String, action:()->Void)->SCLButton {
        let btn = addButton(title)
        btn.actionType = SCLActionType.Closure
        btn.action = action
        btn.addTarget(self, action:Selector("buttonTapped:"), forControlEvents:.TouchUpInside)
        btn.addTarget(self, action:Selector("buttonTapDown:"), forControlEvents:.TouchDown | .TouchDragEnter)
        btn.addTarget(self, action:Selector("buttonRelease:"), forControlEvents:.TouchUpInside | .TouchUpOutside | .TouchCancel | .TouchDragOutside )
        return btn
    }

    public func addButton(title:String, target:AnyObject, selector:Selector)->SCLButton {
        let btn = addButton(title)
        btn.actionType = SCLActionType.Selector
        btn.target = target
        btn.selector = selector
        btn.addTarget(self, action:Selector("buttonTapped:"), forControlEvents:.TouchUpInside)
        btn.addTarget(self, action:Selector("buttonTapDown:"), forControlEvents:.TouchDown | .TouchDragEnter)
        btn.addTarget(self, action:Selector("buttonRelease:"), forControlEvents:.TouchUpInside | .TouchUpOutside | .TouchCancel | .TouchDragOutside )
        return btn
    }

    private func addButton(title:String)->SCLButton {
        // Update view height
        kWindowHeight += 45.0
        // Add button
        let btn = SCLButton()
        btn.layer.masksToBounds = true
        btn.setTitle(title, forState: .Normal)
        btn.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        contentView.addSubview(btn)
        buttons.append(btn)
        return btn
    }
    
    private func addActivityIndicator()->SCLButton {
        // Update view height
        kWindowHeight += 45.0
        // Add button
        let btn = SCLButton()
        btn.layer.masksToBounds = true
        // Add loading indicator
        let indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, kWindowWidth - 24, 35))
        indicator.activityIndicatorViewStyle = .Gray
        indicator.startAnimating()
        btn.addSubview(indicator)
        contentView.addSubview(btn)
        buttons.append(btn)
        return btn
    }

    func buttonTapped(btn:SCLButton) {
        if btn.actionType == SCLActionType.Closure {
            btn.action()
        } else if btn.actionType == SCLActionType.Selector {
            let ctrl = UIControl()
            ctrl.sendAction(btn.selector, to:btn.target, forEvent:nil)
        } else {
            println("Unknow action type for button")
        }
        hideView()
    }


    func buttonTapDown(btn:SCLButton) {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        btn.backgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        //brightness = brightness * CGFloat(pressBrightness)
        btn.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    func buttonRelease(btn:SCLButton) {
        btn.backgroundColor = viewColor
    }
    
    //Dismiss keyboard when tapped outside textfield
    func dismissKeyboard(){
        self.view.endEditing(true)
    }

    // showAlert(view, title, subTitle)
    public func showAlert(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:NSTimeInterval=0.0, colorStyle: UInt=0x727375, colorTextButton: UInt=0xFFFFFF) -> SCLAlertViewResponder {
        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Alert, colorStyle: colorStyle, colorTextButton: colorTextButton)
    }

    // showLoading(view, title, subTitle)
    public func showLoading(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:NSTimeInterval=0.0, colorStyle: UInt?=0xFFFFFF, colorTextButton: UInt=0xFFFFFF) -> SCLAlertViewResponder {
        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Loading, colorStyle: colorStyle, colorTextButton: colorTextButton)
    }

    // showTitle(view, title, subTitle, duration, style)
    public func showTitle(title: String, subTitle: String, duration: NSTimeInterval?, completeText: String?, style: SCLAlertViewStyle, colorStyle: UInt?, colorTextButton: UInt?) -> SCLAlertViewResponder {
        view.alpha = 0
        let rv = UIApplication.sharedApplication().keyWindow! as UIWindow
        rv.addSubview(view)
        view.frame = rv.bounds
        baseView.frame = rv.bounds

        // Alert colour/icon
        viewColor = UIColor()

        // Icon style
        switch style {
        case .Alert:
            viewColor = UIColorFromRGB(colorStyle!)
            
        case .Loading:
            viewColor = UIColorFromRGB(colorStyle!)
        }

        // Title
        if !title.isEmpty {
            self.labelTitle.text = title
        }

        // Subtitle
        if !subTitle.isEmpty {
            viewText.text = subTitle
            // Adjust text view size, if necessary
            let str = subTitle as NSString
            let attr = [NSFontAttributeName:viewText.font]
            let sz = CGSize(width: kWindowWidth - 24, height:90)
            let r = str.boundingRectWithSize(sz, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:attr, context:nil)
            let ht = ceil(r.size.height)
            if ht < kTextHeight {
                kWindowHeight -= (kTextHeight - ht)
                kTextHeight = ht
            }
        }

        // Done button
        if style == .Loading {
            addActivityIndicator()
        } else {
            let txt = completeText != nil ? completeText! : "閉じる"
            addButton(txt, target:self, selector:Selector("hideView"))
        }

        for txt in inputs {
            txt.layer.borderColor = viewColor.CGColor
        }
        for btn in buttons {
            btn.backgroundColor = viewColor
            btn.setTitleColor(UIColorFromRGB(colorTextButton!), forState:UIControlState.Normal)
        }

        // Adding duration
        if duration > 0 {
            durationTimer?.invalidate()
            durationTimer = NSTimer.scheduledTimerWithTimeInterval(duration!, target: self, selector: Selector("hideView"), userInfo: nil, repeats: false)
        }

        // Animate in the alert view
        self.baseView.frame.origin.y = -400
        UIView.animateWithDuration(0.2, animations: {
            self.baseView.center.y = rv.center.y + 15
            self.view.alpha = 1
            }, completion: { finished in
                UIView.animateWithDuration(0.2, animations: {
                    self.baseView.center = rv.center
                })
        })
        // Chainable objects
        return SCLAlertViewResponder(alertview: self)
    }

    // Close SCLAlertView
    public func hideView() {
        UIView.animateWithDuration(0.2, animations: {
            self.view.alpha = 0
            }, completion: { finished in
                self.view.removeFromSuperview()
        })
    }

    // Helper function to convert from RGB to UIColor
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
