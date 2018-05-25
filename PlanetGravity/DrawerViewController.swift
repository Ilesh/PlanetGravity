//
//  DrawerViewController.swift
//  PlanetGravity
//
//  Created by Nicholas Grana on 5/22/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import SceneKit
import UIKit

class DrawerViewController: UIViewController, PulleyDrawerViewControllerDelegate {
    
    // todo: bounce on select planet
    @IBOutlet var scaleSlider: UISlider!
    @IBOutlet var speedSlider: UISlider!
    @IBOutlet var scaleTextLabel: UILabel!
    
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        if UIViewController.vc == nil || UIViewController.vc.planetView.planetNode == nil{
            return 69
        }
        
        return 300.0
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.partiallyRevealed, .collapsed]
    }
    
    @IBAction func scaleSlider(_ sender: UISlider) {
        let scene = UIViewController.vc.planetView.planetScene!
        let scale = sender.value
        scene.scale = scale
        
        for node in scene.rootNode.childNodes.filter({ (node) -> Bool in
            return !(node.geometry is SCNPlane)
        }) {
            node.scale = SCNVector3(x: scale, y: scale, z: scale)
        }
    }
    
    @IBAction func speedSlider(_ sender: UISlider) {
        let scene = UIViewController.vc.planetView.planetScene!
        let speed = sender.value
        scene.speed = CGFloat(sender.maximumValue + sender.minimumValue) - CGFloat(speed)
        
        scene.sceneView.planetNode?.applyActions()
        
        scene.planetSystem?.planets.forEach({ (planet) in
            planet.applyActions()
        })
    }
    
    @IBAction func deleteSystem(_ sender: UIButton) {
        UIViewController.vc.reset()
        
        scaleTextLabel.isHidden = true 
        scaleSlider.value = 1
        speedSlider.value = 1
    }
}

