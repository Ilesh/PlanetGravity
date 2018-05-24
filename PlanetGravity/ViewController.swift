//
//  ViewController.swift
//  PlanetGravity
//
//  Created by Nicholas Grana on 5/15/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var resetTimerButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var addButton: UIButton!
    
    var planetView: PlanetView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PlanetMaterial.loadTextures()
        
        load()
    }
    
    func load() {
        planetView = PlanetView(frame: view.frame)
        
        planetView.setup(vc: self)
        view.addSubview(planetView)
        
        view.sendSubview(toBack: planetView)
        
        UIViewController.vc = self
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        planetView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    func enableControls() {
        resetTimerButton.isEnabled = true
        pauseButton.isEnabled = true
        addButton.isEnabled = true
        UIViewController.drawerViewController?.scaleTextLabel.isHidden = false
    }
    
    func reset() {
        for node in planetView.planetScene.rootNode.childNodes {
            if node.geometry is SCNSphere || node.geometry is SCNTorus || node.geometry is SCNPlane {
                node.removeFromParentNode()
            }
        }
        
        resetTimerButton.isEnabled = false
        addButton.isEnabled = false 
        pauseButton.isEnabled = false
        planetView.floorNode = nil
        planetView.highlightedNode = nil
        planetView.planetNode = nil
        planetView.planetScene.scale = 1
        planetView.planetScene.planetSystem = nil
        
        UIViewController.pulleyViewController?.setDrawerPosition(position: .collapsed, animated: true, completion: { (v) in
            UIViewController.pulleyViewController?.setNeedsSupportedDrawerPositionsUpdate()
        })
    }
    
    @IBAction func addPlanet(_ sender: UIButton) {
        switch planetView.state {
        case .planet(let node):
            planetView.planetScene.createMoon(planetNode: node)
        case .sun:
            fallthrough
        case .none:
            planetView.planetScene.createPlanet()
        }
    }
    
    @IBAction func togglePause(_ sender: UIButton) {
        planetView.togglePause()
        
        if sender.currentTitle == "pause" {
            sender.setImage(#imageLiteral(resourceName: "icons8-circled-play-50"), for: .normal)
            sender.setTitle("play", for: .normal)
        } else {
            sender.setImage(#imageLiteral(resourceName: "icons8-pause-button-50"), for: .normal)
            sender.setTitle("pause", for: .normal)
        }
    }
    
    @IBAction func resetTimers(_ sender: UIButton) {
        planetView.resetTimers()
    }
    
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
