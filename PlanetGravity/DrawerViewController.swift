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
            if planetNode == UIViewController.vc.planetView.planetNode {
                if sliderSelector.numberOfSegments != 2 {
                    sliderSelector.removeSegment(at: 1, animated: false)
                }
            } else {
                if sliderSelector.numberOfSegments != 3 {
                    sliderSelector.insertSegment(withTitle: "Distance", at: 1, animated: false)
                }
            }
            
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
            formulaLabel.reloadEquation()
            sliderSelector.selectedSegmentIndex = 0
            pageController.currentPage = 0
            updatePageCount(title: speedTextLabel.text!)
            updateCurrentPageFormula(currentPage: pageController.currentPage)
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
        if UIViewController.vc.planetView.planetNode == planetNode {
            speedTextLabel.text = sliderSelector.selectedSegmentIndex == 0 ? "Mass" : "Radius"
        } else {
            speedTextLabel.text = sliderSelector.selectedSegmentIndex == 0 ? "Mass" : sliderSelector.selectedSegmentIndex == 1 ? "Distance" : "Radius"
        }
        
        updatePageCount(title: speedTextLabel.text!)
        pageController.currentPage = 0 
        updateCurrentPageFormula(currentPage: 0)
    }
    
    func updatePageCount(title: String) {
        let isSun = planetNode == UIViewController.vc.planetView.planetNode
        
        if isSun {
            pageController.numberOfPages = 2
            return
        }
        
        switch title {
        case "Mass":
            pageController.numberOfPages = 4
        case "Radius":
            pageController.numberOfPages = 2
        case "Distance":
            pageController.numberOfPages = 2
        default:
            return
        }
        
        pageController.currentPage = 0

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
        updateCurrentPageFormula(currentPage: pageController.currentPage)
    }
    
    func updateCurrentPageFormula(currentPage: Int) {
        let isSun = planetNode == UIViewController.vc.planetView.planetNode
        
        if isSun {
            formulaLabel.formula = currentPage == 0 ? .g : .vEscape
            return
        }
        
        switch speedTextLabel.text! {
        case "Mass":
            switch currentPage {
            case 0:
                formulaLabel.formula = .g
            case 1:
                formulaLabel.formula = .vEscape
            case 2:
                formulaLabel.formula = .revolutionPeriod
            case 3:
                formulaLabel.formula = .fg
            default:
                formulaLabel.formula = .fg
            }
        case "Radius":
            formulaLabel.formula = currentPage == 0 ? .g : .vEscape
        case "Distance":
            formulaLabel.formula = currentPage == 0 ? .revolutionPeriod : .fg
        default:
            return
        }
    }
    
    @IBAction func speedSlider(_ sender: UISlider) {
        let value = sender.value
        
        if Int(100000 * value) % 2 != 0 {
            return 
        }
        
        let isSun = planetNode == UIViewController.vc.planetView.planetNode
        
        // TODO: go off sun values for this instead of other values
        
        switch speedTextLabel.text! {
            
        case "Mass":
            if isSun {
                if let system = UIViewController.vc.planetView.planetScene.planetSystem {
                    for node in system.planets {
                        node.applyActions()
                    }
                }
            } else {
                planetNode?.applyActions()
            }
            
            planetNode?.planet.mass = (isSun ? 1.989e30 : 5e24) * CGFloat(value)
            formulaLabel.reloadEquation()
        case "Distance":
            if let _ = (planetNode?.orbitNode?.geometry as? SCNTorus)?.ringRadius {
                var orb = (planetNode?.planet as! OrbitingPlanet)
                let newSphere = SCNTorus(ringRadius: orb.eccentricity * CGFloat(value), pipeRadius: 0.0005)
                orb.distance = orb.eccentricity * CGFloat(value)
                planetNode?.planet = orb
                newSphere.materials = (planetNode?.orbitNode?.geometry?.materials)!
                planetNode?.orbitNode?.geometry = newSphere
                
                let x = Float(orb.distance) * -cos(planetNode!.rotation.y)
                let z = Float(orb.distance) * -sin(planetNode!.rotation.y)
                
                planetNode?.position = SCNVector3(x: x, y: 0, z: z)
            }
            
            planetNode?.applyActions()
            formulaLabel.reloadEquation()
        case "Radius":
            if let _ = (planetNode?.geometry as? SCNSphere)?.radius {
                let newSphere = SCNSphere(radius: (isSun ? 0.15 : 0.05) * CGFloat(value))
                planetNode?.planet.radius = newSphere.radius
                newSphere.materials = (planetNode?.geometry?.materials)!
                planetNode?.geometry = newSphere
            }
            
            formulaLabel.reloadEquation()
        case "Speed":
            let scene = UIViewController.vc.planetView.planetScene!
            scene.speed = CGFloat(sender.maximumValue + sender.minimumValue) - CGFloat(value)
            
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
        pageController.currentPage = 0
        sliderSelector.selectedSegmentIndex = 0
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

