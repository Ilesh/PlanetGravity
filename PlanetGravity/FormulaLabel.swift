//
//  FormulaLabel.swift
//  PlanetGravity
//
//  Created by Nicholas Grana on 5/25/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation
import iosMath

enum FormulaVariable: String {
    case m = "mm"
    case M = "MM"
    case R = "RR"
    case r = "rr"
    case G = "GGG"
}

enum Formula: String {
    
    case vEscape = "\\bf{ v_{esc} = \\sqrt{ \\frac{2 G M_p} {r} } = \\sqrt{ \\frac{2 G (mm)} {rr} } = ? \\text m/s}"
    case g = "\\bf { g_p = \\frac{ G M_p }{r^2} = \\frac{ G (mm) }{(rr)^2} = ? \\text m/s^2 }"
    case fg = "\\bf{ F_g = \\frac{ G M_s M_p }{R^2} = \\frac{ G (MM) (mm) }{(RR)^2} = ? \\text N }"
    case revolutionPeriod = "\\bf { T_{rev} = 2 \\pi \\sqrt{ \\frac{ R^2 }{ G M_p } } = 2 \\pi \\sqrt{ \\frac{ (RR)^2 }{(mm) G}} = ? \\text days } "

}

class FormulaLabel: MTMathUILabel {
    
    var planetNode: PlanetNode?
    var targetPlanetNode: PlanetNode? {
        return orbitingPlanet?.target
    }
    var orbitingPlanet: OrbitingPlanet? {
        return planetNode?.planet as? OrbitingPlanet
    }
    
    var finialAnswer: String {
        if let formula = formula, let planet = planetNode {
            switch formula {
            case .vEscape:
                return format(value: planet.planet.vEscape)
            case .fg:
                if let orb = orbitingPlanet {
                    return format(value: orb.forceOfGravity)
                }
                return ""
            case .g:
                return format(value: planet.planet.g)
            case .revolutionPeriod:
                if let orb = orbitingPlanet {
                    return format(value: orb.actualRevolutionPeriod)
                }
                return ""
            }
        }
        return ""
    }
    
    var formula: Formula? = nil {
        didSet {
            if let _ = formula {
                reloadEquation()
            }
        }
    }
    
    func reloadEquation() {
        guard let formula = formula else {
            return
        }
        
        var runningNumber = formula.rawValue
        
        runningNumber = fill(runningNumber, variable: .G, with: 6.67e-11)
        
        if let targetMass = targetPlanetNode?.planet.actualMass {
            runningNumber = fill(runningNumber, variable: .M, with: targetMass)
        }
        if let mass = planetNode?.planet.actualMass {
            runningNumber = fill(runningNumber, variable: .m, with: mass)
        }
        if let radiusDistance = orbitingPlanet?.actualDistance {
            runningNumber = fill(runningNumber, variable: .R, with: radiusDistance)
        }
        if let actualRadius = planetNode?.planet.actualRadius {
            runningNumber = fill(runningNumber, variable: .r, with: actualRadius)
        }
        
        latex = "\(runningNumber.replacingOccurrences(of: "?", with: finialAnswer))"
    }

    func fill(_ prev: String, variable: FormulaVariable, with value: CGFloat) -> String {
        let numberFormatter = NumberFormatter()
        
        let numberString: String
        if value >= 1000 || value <= -1000 {
            numberFormatter.numberStyle = .scientific
            numberFormatter.positiveFormat = "0.##E+0"
            numberFormatter.exponentSymbol = "\\times10^{"
            numberString = "\(numberFormatter.string(from: NSNumber(value: Float(value)))!.replacingOccurrences(of: "+", with: ""))}"
        } else {
            if value > 100 || value < 100 {
                numberFormatter.minimumFractionDigits = 0
                numberFormatter.maximumFractionDigits = 2
                numberString = "\(numberFormatter.string(from: NSNumber(value: Float(value)))!)"
            } else {
                numberFormatter.minimumFractionDigits = 0
                numberFormatter.maximumFractionDigits = 0
                numberString = "\(numberFormatter.string(from: NSNumber(value: Float(value)))!)"
            }
        }
        
        return prev.replacingOccurrences(of: variable.rawValue, with: numberString)
    }
    
    func format(value: CGFloat) -> String {
        let numberFormatter = NumberFormatter()
        
        if value > 1000 || value < -1000 {
            numberFormatter.numberStyle = .scientific
            numberFormatter.positiveFormat = "0.##E0"
            numberFormatter.exponentSymbol = "\\times10^{"
            
            return "\(numberFormatter.string(from: NSNumber(value: Float(value)))!.replacingOccurrences(of: "+", with: ""))}"
        } else {
            if value > 100 || value < 100 {
                numberFormatter.minimumFractionDigits = 0
                numberFormatter.maximumFractionDigits = 2
                return "\(numberFormatter.string(from: NSNumber(value: Float(value)))!)"
            }
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 0
            return "\(numberFormatter.string(from: NSNumber(value: Float(value)))!)"
        }
    }
    
}
