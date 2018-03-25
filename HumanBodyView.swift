//
//  HumanBodyView.swift
//  Human-Body-View
//
//  Created by admin on 4/18/16.
//  Copyright © 2016 __ASIAINFO__. All rights reserved.
//

import UIKit

class HumanBodyView: UIView {
    
	lazy var backgroundImageView: UIImageView = { [unowned self] in
		let result = UIImageView()
		result.image = UIImage(named: "intelligence_background")
		self.addSubview(result)
		return result
	}()
    
	lazy var bodyImageView: UIImageView = { [unowned self] in
		let result = UIImageView()
		result.image = UIImage(named: self.plistName)
		self.addSubview(result)
		return result
	}()
	
	lazy var highlightedImageView: UIImageView = { [unowned self] in
		let result = UIImageView()
		result.hidden = true
		self.bodyImageView.addSubview(result)
		return result
	}()
	
	lazy var backSideSwitch: UISwitch = { [unowned self] in
		let result = UISwitch()
		self.addSubview(result)
		result.addTarget(self, action: #selector(HumanBodyView.backSideSwitchValueChanged(_:)), forControlEvents: .ValueChanged)
		return result
	}()
	
	lazy var backButton: UIButton = { [unowned self] in
		let result = UIButton()
		result.setTitle("返回", forState: .Normal)
		result.setTitleColor(UIColor.blueColor(), forState: .Normal)
		result.sizeToFit()
		result.hidden = true
		result.addTarget(self, action: #selector(HumanBodyView.backButtonPressed(_:)), forControlEvents: .TouchUpInside)
		self.addSubview(result)
		return result
	}()
	
	lazy var roleSwitch: UISegmentedControl = { [unowned self] in
		let result = UISegmentedControl(items: ["男", "女", "小孩"])
		result.sizeToFit()
		result.selectedSegmentIndex = 0
		result.addTarget(self, action: #selector(HumanBodyView.roleSwitchValueChanged(_:)), forControlEvents: .ValueChanged)
		self.addSubview(result)
		return result
	}()
	
	struct Constants {
		static let margin: CGFloat = 20
	}
	
	var selectedHotArea: HotArea? {
		didSet {
			if let selectedHotArea = selectedHotArea {
				highlightedImageView.image = UIImage(named: "intelligence_highlight_" + selectedHotArea.areaCode)
				highlightedImageView.sizeToFit()
				var frame = highlightedImageView.frame
				frame.origin = selectedHotArea.position
				highlightedImageView.frame = frame
				highlightedImageView.hidden = false
			} else {
				highlightedImageView.hidden = true
			}
		}
	}
	
	var plistName: String = "intelligence_body_male" {
		didSet {
			bodyImageView.image = UIImage(named: plistName)
			hotAreas = hotAreasWithPlist(plistName)
			setNeedsLayout()
		}
	}
	
	func hotAreasWithPlist(plist: String) -> [HotArea] {
		var result = [HotArea]()
		if let path = NSBundle.mainBundle().pathForResource(plist, ofType: "plist") {
			let hotAreaDics = NSArray(contentsOfFile: path)!
			for hotAreaDic in hotAreaDics {
				result.append(HotArea(dic: hotAreaDic as! NSDictionary))
			}
		}
		return result
	}
	
	lazy var hotAreas: [HotArea] = { [unowned self] in
		return self.hotAreasWithPlist(self.plistName)
	}()
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let margin = Constants.margin
		backgroundImageView.frame = bounds
		
		bodyImageView.sizeToFit()
		bodyImageView.center = center
		
		bringSubviewToFront(backSideSwitch)
		var frame = backSideSwitch.frame
		frame.origin.x = CGRectGetWidth(bounds) - frame.width - margin
		frame.origin.y = CGRectGetHeight(bounds) - frame.height - margin
		backSideSwitch.frame = frame
		
		bringSubviewToFront(backButton)
		frame = backButton.frame
		frame.origin.x = CGRectGetWidth(bounds) - frame.width - margin
		frame.origin.y = margin
		backButton.frame = frame
		
		bringSubviewToFront(roleSwitch)
		frame = roleSwitch.frame
		frame.origin.x = margin
		frame.origin.y = CGRectGetHeight(bounds) - frame.height - margin
		roleSwitch.frame = frame
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let point = touches.first?.locationInView(bodyImageView)
		if let point = point {
			selectedHotArea = hotAreaOfPoint(point)
		}
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let point = touches.first?.locationInView(bodyImageView)
		if let point = point, selectedHotArea = selectedHotArea {
			if selectedHotArea.areaCode == hotAreaOfPoint(point)?.areaCode {
				switch selectedHotArea.areaCode {
				case "0100":
					plistName = "intelligence_body_male_face"
					backSideSwitch.hidden = true
					roleSwitch.hidden = true
					backButton.hidden = false
				case "0200":
					plistName = "intelligence_body_female_face"
					backSideSwitch.hidden = true
					roleSwitch.hidden = true
					backButton.hidden = false
				case "0300":
					plistName = "intelligence_body_child_face"
					backSideSwitch.hidden = true
					roleSwitch.hidden = true
					backButton.hidden = false
				default:
					print("area code is " + selectedHotArea.areaCode)
					break
				}
			}
		}
		selectedHotArea = nil
	}
	
	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		selectedHotArea = nil
	}
	
	func hotAreaOfPoint(point: CGPoint) -> HotArea? {
		for a in hotAreas {
			let isIn = a.containsPoint(point)
			if isIn {
				print("areaCode is " + a.areaCode + " inside is " + (isIn ? "yes" : "no"))
				return a
			}
		}
		return nil
	}
	
	// MARK: - target actions
	func backSideSwitchValueChanged(sender: UISwitch) {
		let isBack = plistName.containsString("back")
		if isBack {
			plistName.removeRange(plistName.rangeOfString("_back")!)
		} else {
			plistName = plistName + "_back"
		}
	}
	
	func backButtonPressed(sender: UIButton) {
		plistName.removeRange(plistName.rangeOfString("_face")!)
		sender.hidden = true
		backSideSwitch.hidden = false
		roleSwitch.hidden = false
	}
	
	func roleSwitchValueChanged(sender: UISegmentedControl) {
		let roles = ["male", "female", "child"]
		plistName = "intelligence_body_" + roles[sender.selectedSegmentIndex]
	}
}

struct HotArea {
	var areaCode: String
	var position: CGPoint
	var polygons: [CGPoint]
	var path: UIBezierPath
}

extension HotArea {
	init(dic: NSDictionary) {
		self.areaCode = dic["areaCode"] as! String
		self.position = CGPoint(dic: dic["position"] as! NSDictionary)
		let polygonDics = dic["polygon"] as! NSArray
		var polygons = [CGPoint]()
		for polygonDic in polygonDics {
			polygons.append(CGPoint(dic: polygonDic as! NSDictionary))
		}
		self.polygons = polygons
		
		let path = UIBezierPath()
		for (i, point) in polygons.enumerate() {
			if i == 0 {
				path.moveToPoint(point)
			} else {
				path.addLineToPoint(point)
			}
		}
		self.path = path
	}
	
	func containsPoint(point: CGPoint) -> Bool {
		return path.containsPoint(point)
	}
}

extension CGPoint {
	init(dic: NSDictionary) {
		self.init(x: dic["x"]!.doubleValue, y: dic["y"]!.doubleValue)
	}
}
