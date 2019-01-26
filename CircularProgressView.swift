//
//  CircularProgressView.swift
//
//
//  Created by Abhay Shankar 
//  Copyright © 2019 Abhay Shankar. All rights reserved.
//
protocol CircularProgressDelegate : class {
    func didCancelProgressOfView(progressView : CircularProgressView)
}
import UIKit

@IBDesignable
class CircularProgressView: UIView{
    
    var delegate : CircularProgressDelegate?
    
    @IBInspectable
    var progressTintColor: UIColor = UIColor.init(red: CGFloat(52)/255.0, green: CGFloat(152)/255.0, blue: CGFloat(219)/255.0, alpha: 1.0)
    
    @IBInspectable
    var trackTintColor: UIColor = UIColor.init(red: CGFloat(52)/255.0, green: CGFloat(152)/255.0, blue: CGFloat(219)/255.0, alpha: 0.2)
    
    @IBInspectable
    var trackWidth: CGFloat = 10
    
    @IBInspectable
    var progress: CGFloat = 0 {
        willSet(newValue)
        {
            progressLayer.strokeEnd = CGFloat(newValue)
        }
    }
    
    private var shapeLayer: CAShapeLayer = CAShapeLayer()
    private var progressLayer: CAShapeLayer = CAShapeLayer()
    private var squareWithRoundedCornersLayer: CAShapeLayer = CAShapeLayer()
    private var cancelSelector : Selector?
    private var tapGesture : UITapGestureRecognizer?
    
    //MARK: - Interface builder
    
    override var frame: CGRect{
        didSet{
            updateProgressView()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        installCircularView()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        installCircularView()
        updateProgressView()
    }
    
    // MARK: - Initialisers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        installCircularView()
        addTapGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        installCircularView()
        updateProgressView()
        addTapGesture()
    }
    
    // MARK: - Create Paths

    fileprivate func getCirclePath()-> UIBezierPath{
        let x = self.frame.width/2
        let y = self.frame.height/2
        let center = CGPoint(x: x, y: y)
        let path = UIBezierPath.init(arcCenter: center, radius: x - (trackWidth/2.0), startAngle: 0 - (CGFloat.pi/2.0), endAngle: (2 * CGFloat.pi) - (CGFloat.pi/2.0), clockwise: true)
        path.close()
        return path
    }
    
    fileprivate func getCancelLayerPath()-> UIBezierPath{
        let path = UIBezierPath.init(roundedRect: getCancelLayerFrame(), cornerRadius: ((self.frame.width - trackWidth) / 2.0) * 0.2)
        return path
    }
    fileprivate func getCancelLayerFrame()->CGRect{
        
        let width =  (self.frame.width - trackWidth) / 2.0
        let padding : CGFloat = width/2.0

        let frame = CGRect.init(origin: CGPoint.init(x: padding+(trackWidth/2.0), y: padding+(trackWidth/2.0)), size: CGSize.init(width:width, height: width))
        
        return frame
    }
    
    // MARK: - Setup circular view

    fileprivate func installCircularView() {
        shapeLayer.path = getCirclePath().cgPath
        shapeLayer.lineWidth = trackWidth
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = trackTintColor.cgColor
        
        squareWithRoundedCornersLayer.path = getCancelLayerPath().cgPath
        squareWithRoundedCornersLayer.fillColor = progressTintColor.cgColor

        progressLayer.path = getCirclePath().cgPath
        progressLayer.lineWidth = trackWidth
        progressLayer.lineCap = CAShapeLayerLineCap.round
        progressLayer.fillColor = nil
        progressLayer.strokeColor = progressTintColor.cgColor
        progressLayer.strokeEnd = progress
        
        self.layer.addSublayer(squareWithRoundedCornersLayer)
        self.layer.addSublayer(shapeLayer)
        self.layer.addSublayer(progressLayer)
    }
    
    
    fileprivate func updateProgressView(){
        progressLayer.strokeEnd = progress
        shapeLayer.path = getCirclePath().cgPath
        progressLayer.path = getCirclePath().cgPath

        shapeLayer.lineWidth = trackWidth
        shapeLayer.strokeColor = trackTintColor.cgColor
        progressLayer.strokeColor = progressTintColor.cgColor

    }
    
    // MARK: - Setup Tap Gesture

    fileprivate func addTapGesture(){
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(cancelAction))
        addGestureRecognizer(tapGesture!)
    }
    // MARK: - Add cancel action
    
    @objc
    fileprivate func cancelAction(){
        delegate?.didCancelProgressOfView(progressView: self)
    }

    
    //MARK: - Update Progress
    
    func setProgressTo(_ progress : CGFloat, animated : Bool = true){
        if animated{
            UIView.animate(withDuration: 0.2) {
                self.progressLayer.strokeEnd = progress
            }
        }else{
            self.progressLayer.strokeEnd = progress
        }
    }
}
