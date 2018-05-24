//
//  PlanetGravityTests.swift
//  PlanetGravityTests
//
//  Created by Nicholas Grana on 5/15/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import XCTest
@testable import PlanetGravity

class PlanetGravityTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let sun = PlanetNode(mass: 1.9891e30, radius: 695500000)
        let earth = OrbitingPlanet(target: sun, mass: 5.97219e24, radius: 6378100, distance: 149600000000
, rotationPeriod: 24)
        
        print(earth.vEscape)
        print(earth.g)
        print(earth.revolutionPeriod)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
