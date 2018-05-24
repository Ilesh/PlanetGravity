//
//  PlanetTexture.swift
//  PlanetGravity
//
//  Created by Nicholas Grana on 5/15/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import SceneKit
import UIKit

class PlanetMaterial {
    
    static var planets = [SCNMaterial]()
    static var moons = [SCNMaterial]()
    static var floor: SCNMaterial!
    static var centerPlanet: SCNMaterial!
    static var planetIndex = 0
    static var moonIndex = 0
    
    static func loadTextures() {
        func materialForName(_ name: String) -> SCNMaterial {
            let material = SCNMaterial()
            
            material.lightingModel = .physicallyBased
            material.diffuse.contents = UIImage(named: name)
            material.isDoubleSided = true
            
            return material
        }
        
        planets = (1...6).map {
            return materialForName("planet\($0).jpg")
        }
        
        moons = (1...4).map {
            return materialForName("moon\($0).jpg")
        }
        floor = materialForName("floor.jpg")
        centerPlanet = materialForName("center.jpg")
    }
        
    static func nextPlanetTexture() -> SCNMaterial {
        let material = PlanetMaterial.planets[planetIndex]
        
        planetIndex += 1
        if planetIndex > PlanetMaterial.planets.count - 1 {
            planetIndex = 0
        }
        
        return material
    }
    
    static func nextMoonTexture() -> SCNMaterial {
        let material = PlanetMaterial.moons[moonIndex]
        
        moonIndex += 1
        if moonIndex > PlanetMaterial.moons.count - 1 {
            moonIndex = 0
        }
        
        return material
    }
    
}
