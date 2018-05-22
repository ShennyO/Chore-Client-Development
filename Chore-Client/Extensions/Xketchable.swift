//
//  ShadowClass.swift
//  xketch sample
//
//  Created by Yveslym on 5/21/18.
//  Copyright © 2018 yveslym. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
internal class Shadow: Border {
    
    @IBInspectable var opacity: Float = 1 {
        didSet{
            layer.shadowOpacity = opacity
        }
    }
    
    @IBInspectable var offSetWidght: CGFloat =  0.0{
        didSet{
            layer.shadowOffset.width = offSetWidght
        }
    }
    
    @IBInspectable var offSetheight: CGFloat =  0.0{
        didSet{
            layer.shadowOffset.height = offSetheight
        }
    }
    
    @IBInspectable var color: UIColor = UIColor.black {
        didSet{
            layer.shadowColor = color.cgColor
            
        }
    }
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        //triangleShape()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //triangleShape()
    }
}

@IBDesignable
internal class Border: Corner{
    
    @IBInspectable var Widgth: CGFloat = 0.0 {
        didSet{
            layer.borderWidth = Widgth
            
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.black {
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        //triangleShape()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //triangleShape()
    }
}

@IBDesignable
internal class Corner: AnchorPoint{
    
    @IBInspectable var masktoBounds: Bool = true{
        didSet{
            layer.masksToBounds = masktoBounds
            
        }
    }
    
    @IBInspectable var Radius: CGFloat = 0.0{
        didSet{
            layer.cornerRadius = Radius
            
        }
    }
    
    @IBInspectable var shadow: CGFloat = 0.0 {
        didSet{
            layer.shadowRadius = shadow
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        //triangleShape()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //triangleShape()
    }
}



@IBDesignable
internal class Transform: UIImageView{
    @IBInspectable var rotate: CGFloat = 0.0{
        didSet{
            self.layer.transform = CATransform3DMakeRotation(rotate.degreesToRadians, 0, 0, 1)
        }
    }
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        //triangleShape()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //triangleShape()
    }
}

@IBDesignable
internal class AnchorPoint: Transform{
    
    @IBInspectable var xPosition: CGFloat = 0.0{
        didSet{
            layer.anchorPoint.x = xPosition
        }
    }
    @IBInspectable var yPosition: CGFloat = 0.0{
        didSet{
            layer.anchorPoint.x = yPosition
        }
    }
    @IBInspectable var zPosition: CGFloat = 0.0{
        didSet{
            layer.anchorPointZ = zPosition
            
        }
    }
    @IBInspectable var zPos: CGFloat = 0.0{
        didSet{
            layer.zPosition = zPos
        }
    }
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        //triangleShape()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //triangleShape()
    }
}


extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

@IBDesignable
class Xketchable: Shadow{
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}

















