//
//  ViewController.swift
//  Countdown
//
//  Created by Thiện Tùng on 2/6/20.
//  Copyright © 2020 tung. All rights reserved.
//

import UIKit
 
class ViewController: UIViewController, CAAnimationDelegate {
    
    
    let gradient = CAGradientLayer()
    
    // Tạo mảng màu
    var gradientSet = [[CGColor]]()
    // Màu hiện tại của gradient
    var currentGradient: Int = 0
    
    // Màu được thêm vào mảng gradientSet
    let colorOne = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1).cgColor
    let colorTwo = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor
    let colorThree = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor
    
    @IBOutlet weak var countdownProgressBar: CountdownProgressBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        createGradientView()
        //Nếu muốn có hiệu ứng pulse thì để là true
        countdownProgressBar.startCoundown(duration: 10, showPulse: true)
        // Tắt hiệu ứng pulse thì để false
        //countdownProgressBar.startCoundown(duration: 10, showPulse: false)
        
        countdownProgressBar.backgroundColor = .clear
    }
    
    /// Tạo gradient view
    
    func createGradientView() {
        
        // Tạo 3 bộ màu
        gradientSet.append([colorOne, colorTwo])
        gradientSet.append([colorTwo, colorThree])
        gradientSet.append([colorThree, colorOne])
        
        // Đặt kích thước cho gradient, ở đây là toàn bộ màn hình
        gradient.frame = self.view.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        
        self.view.layer.insertSublayer(gradient, at: 0)
        
        animateGradient()
    }
    
    @objc func handleTap() {
        print("Tapped")
        
        countdownProgressBar.startCoundown(duration: 10, showPulse: true)
    }
    
    func animateGradient() {
        // Chạy các bộ màu tạo gradient
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        // Animated mỗi 3 giây
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = 3.0
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.delegate = self
        gradient.add(gradientChangeAnimation, forKey: "gradientChangeAnimation")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        // Nếu animated của gradient kết thúc thì khởi động lại để chạy tiếp
        if flag {
            gradient.colors = gradientSet[currentGradient]
            animateGradient()
        }
    }
}
