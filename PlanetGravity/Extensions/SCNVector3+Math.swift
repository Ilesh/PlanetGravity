//
//  SCNVector3+Math.swift
//  PlanetGravity
//
//  Created by Nicholas Grana on 5/18/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import SceneKit

extension SCNVector3 {
    
    func dis(_ vector: SCNVector3) -> CGFloat {
        return CGFloat(sqrt(pow(vector.x - x, 2) + pow(vector.z - z, 2)))
    }
    
}
