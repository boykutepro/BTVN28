//
//  CountdownProgressBar.swift
//  Countdown
//
//  Created by Thiện Tùng on 2/6/20.
//  Copyright © 2020 tung. All rights reserved.
//

import Foundation
import UIKit
 
class CountdownProgressBar: UIView {
    
    private var timer = Timer()
    
    private var duration = 5.0
    private var remainingTime = 0.0
    private var showPulse = false
    
    // Label hiện thời gian đếm ngược
    private lazy var remainingTimeLabel: UILabel = {
        let remainingTimeLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0)
            , size: CGSize(width: bounds.width, height: bounds.height)))
        remainingTimeLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        remainingTimeLabel.textAlignment = NSTextAlignment.center
        return remainingTimeLabel
    }()
    
    // Nền chạy animated gradient
    private lazy var foregroundLayer: CAShapeLayer = {
        let foregroundLayer = CAShapeLayer()
        foregroundLayer.lineWidth = 10
        foregroundLayer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        foregroundLayer.lineCap = .round
        foregroundLayer.fillColor = UIColor.clear.cgColor
        foregroundLayer.strokeEnd = 0
        foregroundLayer.frame = bounds
        return foregroundLayer
    }()
    
    // Đường dẫn màu xám
    private lazy var backgroundLayer: CAShapeLayer = {
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.lineWidth = 10
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        backgroundLayer.lineCap = .round
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.frame = bounds
        return backgroundLayer
    }()
    
    // Hiệu ứng pulse của vòng tròn
    private lazy var pulseLayer: CAShapeLayer = {
        let pulseLayer = CAShapeLayer()
        pulseLayer.lineWidth = 10
        pulseLayer.strokeColor = UIColor.lightGray.cgColor
        pulseLayer.lineCap = .round
        pulseLayer.fillColor = UIColor.clear.cgColor
        pulseLayer.frame = bounds
        return pulseLayer
    }()
    
    // Được gọi khi dùng code
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadLayers()
    }
    
    
    // Được gọi khi dùng storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadLayers()
    }
    
    deinit {
        timer.invalidate()
    }
    
    
    private lazy var foregroundGradientLayer: CAGradientLayer = {
        let foregroundGradientLayer = CAGradientLayer()
        foregroundGradientLayer.frame = bounds
        let startColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor
        let secondColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor
        foregroundGradientLayer.colors = [startColor, secondColor]
        foregroundGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        foregroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return foregroundGradientLayer
    }()
    
    private lazy var pulseGradientLayer: CAGradientLayer = {
        let pulseGradientLayer = CAGradientLayer()
        pulseGradientLayer.frame = bounds
        let startColor = #colorLiteral(red: 0.5090036988, green: 0.04135338217, blue: 0.2113225758, alpha: 1).cgColor
        let secondColor = #colorLiteral(red: 0.4990308285, green: 0.3679353595, blue: 0.1137484089, alpha: 1).cgColor
        pulseGradientLayer.colors = [startColor, secondColor]
        pulseGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        pulseGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return pulseGradientLayer
    }()
    
    private func loadLayers() {
        
        // Lấy điểm chính giữa
        let centerPoint = CGPoint(x: frame.width/2 , y: frame.height/2)
        // Tạo một đường tròn nhỏ hơn UIView
        // Vẽ đường
        let circularPath = UIBezierPath(arcCenter: centerPoint, radius: bounds.width / 2 - 20, startAngle: -CGFloat.pi/2,
                                        endAngle: 2 * CGFloat.pi - CGFloat.pi/2, clockwise: true)
        
        // Cung cấp cho CAShapeLayers đường dẫn tròn để đi theo
        // các lớp pluse và foreground sẽ là mặt nạ trên các lớp gradient
        // Thêm nền CAShapeLayer và lớp thứ 2 CAGradientLayer dưới dạng lớp con
        pulseLayer.path = circularPath.cgPath
        
        pulseGradientLayer.mask = pulseLayer
        
        layer.addSublayer(pulseGradientLayer)
        
        backgroundLayer.path = circularPath.cgPath
        
        layer.addSublayer(backgroundLayer)
        
        foregroundLayer.path = circularPath.cgPath
        
        foregroundGradientLayer.mask = foregroundLayer
        
        layer.addSublayer(foregroundGradientLayer)
        
        addSubview(remainingTimeLabel)
        
        print(remainingTimeLabel.frame)
        
    }
    
    private func beginAnimation() {
        
        animateForegroundLayer()
        
        // Chỉ hiện lớp pulse khi cần thiết
        if showPulse {
            animatePulseLayer()
        }
        
    }
    
    private func animateForegroundLayer() {
        let foregroundAnimation = CABasicAnimation(keyPath: "strokeEnd")
        foregroundAnimation.fromValue = 0
        foregroundAnimation.toValue = 1
        foregroundAnimation.duration = CFTimeInterval(duration)
        foregroundAnimation.fillMode = CAMediaTimingFillMode.forwards
        foregroundAnimation.isRemovedOnCompletion = false
        foregroundAnimation.delegate = self
        
        foregroundLayer.add(foregroundAnimation, forKey: "foregroundAnimation")
    }
    
    private func animatePulseLayer() {
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.2
        
        let pulseOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        pulseOpacityAnimation.fromValue = 0.7
        pulseOpacityAnimation.toValue = 0.0
        
        let groupedAnimation = CAAnimationGroup()
        groupedAnimation.animations = [pulseAnimation, pulseOpacityAnimation]
        groupedAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        groupedAnimation.duration = 1.0
        groupedAnimation.repeatCount = Float.infinity
        
        pulseLayer.add(groupedAnimation, forKey: "pulseAnimation")
    }
    
    @objc private func handleTimerTick() {
        
        if remainingTime > 0 {
            remainingTime -= 0.1
        }
        else {
            remainingTime = 0
            timer.invalidate()
        }
        
        DispatchQueue.main.async {
            self.remainingTimeLabel.text = "\(String.init(format: "%.1f", self.remainingTime))"
        }
    }
    
    //MARK: - Public Functions
    
    /**
     Bắt đầu đếm ngược với thời gian xác định
     
     - Parameter duration: Thời gian đếm ngược.
     - Parameter showPulse: Theo mặc định là false, được đặt thành true để hiển thị xung quanh thanh tiến trình đếm ngược.
     
     - Returns: null.
     */
    
    func startCoundown(duration: Double, showPulse: Bool = false) {
        self.duration = duration
        self.showPulse = showPulse
        remainingTime = duration
        remainingTimeLabel.text = "\(remainingTime)"
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleTimerTick), userInfo: nil, repeats: true)
        beginAnimation()
        
    }
    
}
 
 
extension CountdownProgressBar: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        pulseLayer.removeAllAnimations()
        timer.invalidate()
    }
}
