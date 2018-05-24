//
//  UIBezierPath+Animate.swift
//  PlanetGravity
//
//  Created by Nicholas Grana on 5/20/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import SceneKit

// https://stackoverflow.com/questions/30064816/scenekit-animate-node-along-path/40596990

let animationDuration = 0.1

public extension UIBezierPath {
    
    var elements: [PathElement] {
        var pathElements = [PathElement]()
        withUnsafeMutablePointer(to: &pathElements) { elementsPointer in
            cgPath.apply(info: elementsPointer) { (userInfo, nextElementPointer) in
                let nextElement = PathElement(element: nextElementPointer.pointee)
                let elementsPointer = userInfo!.assumingMemoryBound(to: [PathElement].self)
                elementsPointer.pointee.append(nextElement)
            }
        }
        return pathElements
    }
}

public enum PathElement {
    
    case moveToPoint(CGPoint)
    case addLineToPoint(CGPoint)
    case addQuadCurveToPoint(CGPoint, CGPoint)
    case addCurveToPoint(CGPoint, CGPoint, CGPoint)
    case closeSubpath
    
    init(element: CGPathElement) {
        switch element.type {
        case .moveToPoint: self = .moveToPoint(element.points[0])
        case .addLineToPoint: self = .addLineToPoint(element.points[0])
        case .addQuadCurveToPoint: self = .addQuadCurveToPoint(element.points[0], element.points[1])
        case .addCurveToPoint: self = .addCurveToPoint(element.points[0], element.points[1], element.points[2])
        case .closeSubpath: self = .closeSubpath
        }
    }
}

public extension SCNAction {
    
    class func moveAlong(path: UIBezierPath) -> SCNAction {
        
        let points = path.elements
        var actions = [SCNAction]()
        
        for point in points {
            
            switch point {
            case .moveToPoint(let a):
                let moveAction = SCNAction.move(to: SCNVector3(a.x, 0, a.y), duration: animationDuration)
                actions.append(moveAction)
                break
                
            case .addCurveToPoint(let a, let b, let c):
                let moveAction1 = SCNAction.move(to: SCNVector3(a.x, 0, a.y), duration: animationDuration)
                let moveAction2 = SCNAction.move(to: SCNVector3(b.x, 0, b.y), duration: animationDuration)
                let moveAction3 = SCNAction.move(to: SCNVector3(c.x, 0, c.y), duration: animationDuration)
                actions.append(moveAction1)
                actions.append(moveAction2)
                actions.append(moveAction3)
                break
                
            case .addLineToPoint(let a):
                let moveAction = SCNAction.move(to: SCNVector3(a.x, 0, a.y), duration: animationDuration)
                actions.append(moveAction)
                break
                
            case .addQuadCurveToPoint(let a, let b):
                let moveAction1 = SCNAction.move(to: SCNVector3(a.x, 0, a.y), duration: animationDuration)
                let moveAction2 = SCNAction.move(to: SCNVector3(b.x, 0, b.y), duration: animationDuration)
                actions.append(moveAction1)
                actions.append(moveAction2)
                break
                
            default:
                //let moveAction = SCNAction.move(to: SCNVector3(0, 0, 0), duration: animationDuration)
                //actions.append(moveAction)
                break
            }
        }
        actions.removeLast()
        return SCNAction.sequence(actions)
    }
    
    class func vectors(path: UIBezierPath) -> [SCNVector3] {
        
        let points = path.elements
        var vectors = [SCNVector3]()
        
        for point in points {
            
            switch point {
            case .moveToPoint(let a):
                vectors.append(SCNVector3(a.x, 0, a.y))
                
            case .addCurveToPoint(let a, let b, let c):
                vectors.append(SCNVector3(a.x, 0, a.y))
                vectors.append(SCNVector3(b.x, 0, b.y))
                vectors.append(SCNVector3(c.x, 0, c.y))
                
            case .addLineToPoint(let a):
                vectors.append(SCNVector3(a.x, 0, a.y))
                
            case .addQuadCurveToPoint(let a, let b):
                vectors.append(SCNVector3(a.x, 0, a.y))
                vectors.append(SCNVector3(b.x, 0, b.y))
                
            default:
                break
            }
        }
        vectors.removeLast()
        
        return vectors
    }
}
