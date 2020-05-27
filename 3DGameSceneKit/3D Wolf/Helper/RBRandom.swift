//
//  RBRandom.swift
//  3DGameSceneKit
//
//  Created by octavianus on 27/05/20.
//  Copyright © 2020 com.octavianus. All rights reserved.
//
import Foundation
import GameKit

extension Int {
    static func random(maxValue: Int) -> Int {
        return Int.random(in: 0...Int.max)
    }
}

class RBRandom {
    private let source = GKMersenneTwisterRandomSource()
    
    // -------------------------------------------------------------------------
    // MARK: - Get random numbers
    
    class func boolean() -> Bool {
        if RBRandom.sharedInstance.integer(0, 1) == 1 {
            return true
        }
        
        return false
    }

    // -------------------------------------------------------------------------
    class func integer(_ from: Int, _ to: Int) -> Int {
        return RBRandom.sharedInstance.integer(from, to)
    }

    // -------------------------------------------------------------------------
    
    class func timeInterval(_ from: Int, _ to: Int) -> TimeInterval {
        return TimeInterval(RBRandom.sharedInstance.integer(from, to))
    }
    
    // -------------------------------------------------------------------------
    
    class func cgFloat(_ from: CGFloat, _ to: CGFloat) -> CGFloat {
        return CGFloat(RBRandom.sharedInstance.integer(Int(from), Int(to)))
    }
    
    // -------------------------------------------------------------------------
    
    private func integer(_ from: Int, _ to: Int) -> Int {
        let rd = GKRandomDistribution(randomSource: self.source, lowestValue: from, highestValue: to)
        let number = rd.nextInt()
        
        return number
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Initialisation
    
    init() {
        source.seed = UInt64(CFAbsoluteTimeGetCurrent())
    }
    
    // -------------------------------------------------------------------------
    
    private static let sharedInstance : RBRandom = {
        let instance = RBRandom()
        return instance
    }()
    
    // -------------------------------------------------------------------------
}
