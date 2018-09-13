//
//  CircleColorSelector.swift
//  CircleColorSelector
//
//  Created by Dima on 10/09/2018.
//  Copyright © 2018 Dima. All rights reserved.
//

import UIKit

public protocol OnColorSelectListener {
    func onColorSelect(color: UIColor);
}

extension UIColor {
    
    public static func getFromInt(hex:Int)  -> UIColor{
        return UIColor(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
}

private class CircleView: UIView {
    
    var color: UIColor = UIColor.red;
    private let shapeLayer =  CAShapeLayer();
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        draw();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func draw(){
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.width / CGFloat(2),y: frame.height / CGFloat(2)), radius: frame.width / CGFloat(2) -  CGFloat(2), startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true);
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = color.cgColor;
        shapeLayer.strokeColor = UIColor.white.cgColor;
        shapeLayer.lineWidth = CGFloat(1);
        self.layer.addSublayer(shapeLayer);
        
        
    }
    
    func setColor(color: UIColor){
        self.color = color;
        shapeLayer.fillColor = color.cgColor;
    }
    
    
    
}

private class Color {
    let r: Int
    let g: Int
    let b: Int
    
    init(hex: Int) {
        r = (hex & 0xFF0000) >> 16;
        g = (hex & 0x00FF00) >> 8;
        b = hex & 0x0000FF;
    }
    
    init(r: Int, g: Int, b: Int) {
        self.r = r;
        self.b = b;
        self.g = g;
    }
    
    func getColor() -> UIColor {
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(1))
    }
    
    static func getGradientColor(from: Color, to: Color, percentage: CGFloat) -> Color {
        precondition(percentage >= 0 && percentage <= 1)
        return Color(r: from.r + Int(CGFloat(to.r - from.r) * percentage),
                     g: from.g + Int(CGFloat(to.g - from.g) * percentage),
                     b: from.b + Int(CGFloat(to.b - from.b) * percentage))
    }
}


@IBDesignable
public class UICircleColorSelector: UIView{
    
    @IBInspectable public var size: CGFloat = CGFloat(15) {
        didSet{
            calcCircleRect();
            createCircleRect();
            setCircleRect();
            setSelector();
        }
    };
    
    
    
    public var colorSelectListener: OnColorSelectListener!;
    
    @IBInspectable public var colors: [Int] = [0xff0000, 0xffff00, 0x00ff00, 0x00ffff, 0x0000ff, 0xff00ff,0xffffff,0xff0000] {
        didSet{
            calcCircleRect();
            createCircleRect();
            setCircleRect();
            setSelector();
        }
    };
    
    
    private var colorCount: Int = 0;
    
    private var width = CGFloat(0);
    private var height = CGFloat(0);
    
    private var x = CGFloat(0);
    private var y = CGFloat(0);
    
    private var circleView: UIView!;
    private var selecotr: CircleView!;
    
    private var cl  = UIColor.red;
    
    private let shapeLayer = CAShapeLayer()
    
    private var touchBegin = false;
    
    override init(frame: CGRect) {
        size = CGFloat(15)
        super.init(frame: frame);
        backgroundColor = UIColor.clear;
        calcCircleRect();
        createCircleRect();
        setCircleRect();
        setSelector();
    }
    
    init(frame: CGRect, size: CGFloat) {
        self.size = size;
        super.init(frame: frame);
        backgroundColor = UIColor.clear;
        calcCircleRect();
        createCircleRect();
        setCircleRect();
        setSelector();
    }
    
    override public var frame: CGRect {
        didSet {
            calcCircleRect();
            createCircleRect();
            setCircleRect();
            setSelector();
        }
    }
    
    
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        backgroundColor = UIColor.clear;
        calcCircleRect();
        createCircleRect();
        setCircleRect();
        setSelector();
    }
    
    
    
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first?.location(in: self);
        let center = CGPoint(x: circleView.frame.origin.x + circleView.frame.width / CGFloat(2),y: circleView.frame.origin.y + circleView.frame.height / CGFloat(2) );
        let r1 = circleView.frame.height / CGFloat(2) + size * 0.5;
        let r2 = circleView.frame.height / CGFloat(2) - size * 3;
        let b = teshHit(center: center, r1: r1, r2: r2, touch: touch!);
        if b {
            touchBegin = true;
            let center1 = CGPoint(x: circleView.frame.origin.x + circleView.frame.width / CGFloat(2),y: circleView.frame.origin.y + circleView.frame.height / CGFloat(2) );
            let r11 = circleView.frame.height / CGFloat(2);
            let m1 = calcNearPoint(center: center1, point: touch!, r1: r11 - size * 0.5);
            movie(position: m1 );
        }
    }
    
    func teshHit(center: CGPoint,  r1: CGFloat, r2: CGFloat, touch: CGPoint) -> Bool{
        if ((touch.x - center.x) * ((touch.x - center.x)) + (touch.y - center.y) * (touch.y - center.y) ).squareRoot().isLess(than: r1) {
            if !((touch.x - center.x) * ((touch.x - center.x)) + (touch.y - center.y) * (touch.y - center.y) ).squareRoot().isLess(than: r2) {
                return true;
            }
        }
        return false;
    }
    
    
    func getPixelColorAtPoint(point: CGPoint, sourceView: UIView) -> UIColor {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        
        sourceView.layer.render(in: context!)
        let color: UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                     green: CGFloat(pixel[1])/255.0,
                                     blue: CGFloat(pixel[2])/255.0,
                                     alpha: CGFloat(1))
        pixel.deallocate()
        return color
    }
    
    func calcNearPoint(center: CGPoint, point: CGPoint, r1: CGFloat) -> CGPoint{
        let touch = CGPoint(x: point.x - center.x, y: center.y - point.y);
        let tR = ((touch.x * touch.x)+(touch.y * touch.y)).squareRoot();
        let sinA = touch.y / tR;
        let cosA = touch.x / tR;
        let delta = r1 - tR;
        let deltaPoint = CGPoint(x: touch.x + delta * cosA, y: touch.y + delta * sinA);
        return CGPoint(x: deltaPoint.x + center.x, y: -(deltaPoint.y - center.y) );
    }
    
    
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(touchBegin){
            let touch = touches.first?.location(in: self);
            let center = CGPoint(x: circleView.frame.origin.x + circleView.frame.width / CGFloat(2),y: circleView.frame.origin.y + circleView.frame.height / CGFloat(2) );
            let r1 = circleView.frame.height / CGFloat(2);
            let m = calcNearPoint(center: center, point: touch!, r1: r1 - size * 0.5);
            movie(position: m);
        }
    }
    
    func movie(position: CGPoint){
        selecotr.frame.origin.x = position.x - selecotr.frame.size.width / 2;
        selecotr.frame.origin.y = position.y - selecotr.frame.size.height / 2;
        let pp = CGPoint(x: position.x - circleView.frame.origin.x, y:  position.y  - circleView.frame.origin.y  );
        let color = getPixelColorAtPoint(point: pp, sourceView: circleView);
        cl = color;
        selecotr.setColor(color: color);
    }
    
    override public  func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchBegin = false;
        if colorSelectListener != nil {
            colorSelectListener.onColorSelect(color: selecotr.color);
        }
    }
    
    
    private func setSelector(){
        if circleView != nil {
            if selecotr != nil {
                selecotr.removeFromSuperview();
            }
            selecotr = CircleView(frame: CGRect(x: x , y: y + height * CGFloat(0.5) - size, width: size * CGFloat(2), height: size * CGFloat(2)));
            addSubview(selecotr)
            setColor(color: cl);
        }
    }
    
    private func createCircleRect(){
        circleView = UIView(frame: CGRect(x: x, y: y, width: width, height: height));
        addSubview(circleView);
        circleView.backgroundColor = UIColor.clear;
    }
    
    private func calcCircleRect(){
        if frame.width > frame.height {
            width = frame.height;
            height = frame.height;
            y = CGFloat(0);
            x = (frame.width - frame.height) / CGFloat(2);
        }else{
            width = frame.width;
            height = frame.width;
            x = CGFloat(0);
            y = (frame.height - frame.width) / CGFloat(2);
        }
    }
    
    private func setColorPos(pos: CGFloat){
        let sinA = sin(pos  );
        let cosA = cos(pos  );
        
        let xx =  (circleView.frame.origin.x + circleView.frame.width / 2 ) + circleView.frame.width * cosA;
        let yy = (circleView.frame.origin.y + circleView.frame.height / 2) + circleView.frame.width * sinA;
        let center = CGPoint(x: circleView.frame.origin.x + circleView.frame.width / CGFloat(2),y: circleView.frame.origin.y + circleView.frame.height / CGFloat(2) );
        let touch = CGPoint(x:  xx, y:  yy);
        
        let r1 = circleView.frame.height / CGFloat(2);
        let m = calcNearPoint(center: center, point: touch, r1: r1 - size * 0.5  );
        movie(position: m);
    }
    
    
    public func setColor(color: UIColor){
        let count = 1000;
        var i = 0;
        let cStep = CGFloat(Double.pi * 2) / CGFloat(count);
        let colorStep = 3;
        
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let red = Int(r * 255);
        let green = Int(g * 255);
        let blue = Int(b * 255);
        
        
        while( i < count){
            let stepColor = getColorInPrc(count: count, cur: i, colors: colors);
            
            var r1:CGFloat = 0
            var g1:CGFloat = 0
            var b1:CGFloat = 0
            var a1:CGFloat = 0
            
            stepColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            
            let red1 = Int(r1 * 255);
            let green1 = Int(g1 * 255);
            let blue1 = Int(b1 * 255);
            
            if(red == green && red == blue){
                if(red == red1 && red == green1 && red == blue1){
                    setColorPos(pos:  cStep * CGFloat(i) + cStep * 0.5);
                    break;
                }
            }else{
                if(red < green && red < blue){
                    if(green >= green1 - colorStep && green <= green1 + colorStep) && (blue >= blue1 - colorStep && blue <= blue1 + colorStep){
                        setColorPos(pos:  cStep * CGFloat(i) + cStep * 0.5);
                        break;
                    }
                }else if (green < red && green < blue){
                    if(red >= red1 - colorStep && red <= red1 + colorStep) && (blue >= blue1 - colorStep && blue <= blue1 + colorStep){
                        setColorPos(pos:  cStep * CGFloat(i) + cStep * 0.5);
                        break;
                    }
                }else{
                    if(red >= red1 - colorStep && red <= red1 + colorStep) && (green >= green1 - colorStep && green <= green1 + colorStep){
                        setColorPos(pos:  cStep * CGFloat(i) + cStep * 0.5);
                        break;
                    }
                }
            }
            
            
            i += 1;
        }
    }
    
    
    private func setCircleRect(){
        if circleView != nil {
            circleView.frame.size.width = width - size ;
            circleView.frame.size.height = height - size;
            circleView.frame.origin.x = x + size * CGFloat(0.5);
            circleView.frame.origin.y = y + size * CGFloat(0.5);
            drawRing();
        }
    }
    
    private func getColorInPrc(count: Int, cur: Int, colors: [Int]) -> UIColor{
        let stepCount = count / (colors.count - 1);
        let step = cur / stepCount;
        let color1 = colors[step]
        let color2 = colors[(step + 1) < colors.count ? step + 1 : colors.count - 1];
        let position = cur - stepCount * step;
        let p = Float(position) / (Float(stepCount) / 100.0)
        return Color.getGradientColor(from: Color(hex: color1), to: Color(hex: color2), percentage: CGFloat(p / 100.0)).getColor();
    }
    
    private func drawRing(){
        if circleView != nil {
            if circleView.layer.sublayers != nil {
                for l in circleView.layer.sublayers! {
                    l.removeFromSuperlayer();
                }
            }
            colorCount = Int((width*height).squareRoot()) + 50;
            var i = 0;
            let cStep = CGFloat(Double.pi * 2) / CGFloat(colorCount);
            while( i < colorCount){
                let start = cStep * CGFloat(i);
                let end  = start + cStep;
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: circleView.frame.width / CGFloat(2),y: circleView.frame.height / CGFloat(2)), radius: circleView.frame.height / CGFloat(2) - size * CGFloat(0.5), startAngle: start, endAngle: end, clockwise: true)
                let shapeLayer = CAShapeLayer()
                shapeLayer.opacity = 1.0;
                shapeLayer.path = circlePath.cgPath
                shapeLayer.fillColor = UIColor.clear.cgColor
                let color = getColorInPrc(count: colorCount, cur: i, colors: colors);
                shapeLayer.strokeColor = color.cgColor;
                shapeLayer.lineWidth = size
                circleView.layer.addSublayer(shapeLayer)
                i += 1;
            }
        }
    }
    
}
