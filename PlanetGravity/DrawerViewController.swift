//
//  DrawerViewController.swift
//  PlanetGravity
//
//  Created by Nicholas Grana on 5/22/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import SceneKit
import UIKit
import iosMath

class DrawerViewController: UIViewController, PulleyDrawerViewControllerDelegate {
    
    // todo: bounce on select planet
    @IBOutlet var scaleSlider: UISlider!
    @IBOutlet var speedSlider: UISlider!
    @IBOutlet var scaleTextLabel: UILabel!
    @IBOutlet var formulaLabel: FormulaLabel!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var speedTextLabel: UILabel!
    @IBOutlet var sliderSelector: UISegmentedControl!
    @IBOutlet var formulaViewBackground: UIView!
    @IBOutlet var pageController: UIPageControl!
    
    var planetNode: PlanetNode? {
        didSet {
            setShowPlanet(show: planetNode != nil )
        }
    }
    
    func setShowPlanet(show: Bool) {
        if show {
            deleteButton.setTitle("Delete Planet", for: .normal)
            formulaLabel.isHidden = false
            sliderSelector.isHidden = false
            formulaViewBackground.isHidden = false
            scaleSlider.isHidden = true
            formulaLabel.planetNode = planetNode
            formulaLabel.formula = .g
            pageController.isHidden = false
            
            scaleTextLabel.isHidden = true
            speedTextLabel.text = sliderSelector.selectedSegmentIndex == 0 ? "Mass" : sliderSelector.selectedSegmentIndex == 1 ? "Distance" : "Radius"
        } else {
            deleteButton.setTitle("Delete System", for: .normal)
            formulaLabel.isHidden = true
            formulaViewBackground.isHidden = true
            pageController.isHidden = true
            
            sliderSelector.isHidden = true
            scaleTextLabel.isHidden = false
            scaleSlider.isHidden = false
            speedTextLabel.text = "Speed"
        }
    }
    
    override func viewDidLoad() {
        formulaLabel.formula = .g
        formulaLabel.textColor = UIColor.white
        formulaLabel.fontSize = 12
        formulaLabel.textAlignment = .center
        setShowPlanet(show: false)
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        if UIViewController.vc == nil || UIViewController.vc.planetView.planetNode == nil{
            return 69
        }
        
        return 300.0
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.partiallyRevealed, .collapsed]
    }
    
    @IBAction func changeSliderType(_ sender: UISegmentedControl) {
        speedTextLabel.text = sliderSelector.selectedSegmentIndex == 0 ? "Mass" : sliderSelector.selectedSegmentIndex == 1 ? "Distance" : "Radius"
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
    
    @IBAction func pageSwitch(_ sender: UIPageControl) {
        formulaLabel.formula = sender.currentPage == 0 ? .g : sender.currentPage == 1 ? .revolutionPeriod : .vEscape
        
    }
    
    @IBAction func speedSlider(_ sender: UISlider) {
        // TODO: read off text and change value
        
        switch scaleTextLabel.text! {
            
        case "Mass":
            fallthrough
        case "Distance":
            fallthrough
        case "Radius":
            fallthrough
        case "Scale":
            let scene = UIViewController.vc.planetView.planetScene!
            let speed = sender.value
            scene.speed = CGFloat(sender.maximumValue + sender.minimumValue) - CGFloat(speed)
            
            scene.sceneView.planetNode?.applyActions()
            
            scene.planetSystem?.planets.forEach({ (planet) in
                planet.applyActions()
            })
        default:
            return
        }
        
        
    }
    
    func deleteSystem() {
        UIViewController.vc.reset()
        
        scaleTextLabel.isHidden = true
        scaleSlider.value = 1
        speedSlider.value = 1
    }
    
    @IBAction func deleteSystem(_ sender: UIButton) {
        if sender.currentTitle == "Delete Planet" {
            UIViewController.vc.planetView.planetScene.removePlanet(planet: planetNode)
            planetNode = nil
            pulleyViewController?.setDrawerPosition(position: .collapsed, animated: true)
        } else {
            deleteSystem()
        }
    }
    
    
}

