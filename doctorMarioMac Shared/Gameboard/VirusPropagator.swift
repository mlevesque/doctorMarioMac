//
//  VirusPropagator.swift
//  doctorMarioMac
//
//  Logic for populating a gameboard with viruses.
//
//  Created by Michael Levesque on 12/26/21.
//

// Algorithm for Virus Propagation
// (Adapted from https://tetris.wiki/Dr._Mario)

import GameplayKit

// MARK: Interfaces

/// Virus propagation object.
public protocol IVirusPropagtor {
    
    /// Attempts to generate one virus into the given gameboard.
    ///
    /// The given remaining number of viruses plays into the algorithm for choosing what color
    /// the virus will be.
    ///
    /// Returns the new remaining number of viruses to populate. If the return value is the same
    /// as the given viruses remaining, then the algorithm failed to place a new virus.
    /// - Parameters:
    ///   - virusCount: number of viruses to populate
    ///   - gameboard: gameboard to populate
    /// - Returns: new number of viruses remaining
    func generate(virusesRemaining virusCount: Int, gameboard: IGameboard) -> Int
}


// MARK: Factory Method

/// Factory method for creating a virus propagator.
/// - Parameters:
///   - gameboardWidth: width of the gameboard; used to set up RNG
///   - gameboardHeight: height of the gameboard; used to set up RNG
///   - ceilingLimit: how many cells down from the top of the gameboard is the max height
///   for all viruses. No viruses can be generated above this ceiling.
/// - Returns: virus propagator object
public func buildVirusPropagator(gameboardWidth: Int, gameboardHeight: Int, ceilingLimit: Int) -> IVirusPropagtor {
    return VirusPropagtor(gameboardWidth: gameboardWidth, gameboardHeight: gameboardHeight, ceilingLimit: ceilingLimit)
}


// MARK: Implementation

fileprivate class VirusPropagtor : IVirusPropagtor {
    
    private let m_virusRNGTable: [Color]
    private let m_rngWidth, m_rngHeight, m_rngColor: GKRandomDistribution
    
    init(gameboardWidth: Int, gameboardHeight: Int, ceilingLimit: Int) {
        // generate virus RNG color table
        m_virusRNGTable = [.Yellow, .Red, .Blue, .Blue, .Red, .Yellow, .Red, .Blue, .Blue, .Red, .Yellow, .Yellow, .Red, .Blue, .Red]
        
        // init random number generators
        m_rngWidth = GKRandomDistribution(lowestValue: 0, highestValue: gameboardWidth - 1)
        m_rngHeight = GKRandomDistribution(lowestValue: ceilingLimit, highestValue: gameboardHeight - 1)
        m_rngColor = GKRandomDistribution(lowestValue: 0, highestValue: m_virusRNGTable.count - 1)
    }
    
    private func pickColor(virusesRemaining: Int) -> Color {
        let value = virusesRemaining % 4
        switch value {
        case 0:
            return .Yellow
        case 1:
            return .Red
        case 2:
            return .Blue
        default:
            return m_virusRNGTable[m_rngColor.nextInt()]
        }
    }
    
    private func shiftColor(color: Color, secondNeighborColors: [Color : Int]) -> Color {
        var c = color
        repeat {
            switch c {
            case .Red:
                c = .Yellow
            case .Yellow:
                c = .Blue
            default:
                c = .Red
            }
        } while secondNeighborColors[c, default: 0] > 0
        return c
    }
    
    private func findOpenSlot(gameboard: IGameboard, x: inout Int, y: inout Int) -> Bool {
        while !gameboard.isEmpty(x: x, y: y) && y < gameboard.gridHeight {
            x += 1
            if x >= gameboard.gridWidth {
                y += 1
                x = 0
            }
        }
        return y < gameboard.gridHeight
    }
    
    private func getColorFromGameboard(gameboard: IGameboard, x: Int, y: Int) -> Color {
        guard gameboard.isInBounds(x: x, y: y) else {
            return .None
        }
        return gameboard.getCellInfo(x: x, y: y).color
    }
    
    private func get2ndNeighborColors(gameboard: IGameboard, x: Int, y: Int) -> [Color : Int] {
        var result: [Color : Int] = [:]
        result[getColorFromGameboard(gameboard: gameboard, x: x - 2, y: y), default: 0] += 1
        result[getColorFromGameboard(gameboard: gameboard, x: x + 2, y: y), default: 0] += 1
        result[getColorFromGameboard(gameboard: gameboard, x: x, y: y - 2), default: 0] += 1
        result[getColorFromGameboard(gameboard: gameboard, x: x, y: y + 2), default: 0] += 1
        return result
    }
    
    /// Algorithm for generating a virus. This is based on the NES Dr. Mario virus generation algorithm described at:
    /// https://tetris.wiki/Dr._Mario#Virus_Generation
    /// - Parameters:
    ///   - virusCount: number of remaining viruses. Used in color picking.
    ///   - gameboard: gameboard to populate
    /// - Returns: new number of remaining viruses
    public func generate(virusesRemaining virusCount: Int, gameboard: IGameboard) -> Int {
        // select random position and color
        var y = m_rngHeight.nextInt()
        var x = m_rngWidth.nextInt()
        var color = pickColor(virusesRemaining: virusCount)
        
        // adjust x, y, and color until we find an available slot
        var slotFound = false
        repeat {
            guard findOpenSlot(gameboard: gameboard, x: &x, y: &y) else {
                // if we didn't find an available slot, then return the same remaining count
                return virusCount
            }
        
            // if none of the second neighbors have the selected color, then we are done
            let neighborColors = get2ndNeighborColors(gameboard: gameboard, x: x, y: y)
            if neighborColors[color, default: 0] == 0 {
                slotFound = true
            }
            
            // otherwise, if neighors cover all colors, then try the next position
            else if neighborColors[.Red, default: 0] > 0 && neighborColors[.Yellow, default: 0] > 0 && neighborColors[.Blue, default: 0] > 0 {
                x += 1
            }
            
            // otherwise, shift the color
            else {
                color = shiftColor(color: color, secondNeighborColors: neighborColors)
                slotFound = true
            }
        } while !slotFound
        
        // we found a spot
        gameboard.setVirus(x: x, y: y, color: color)
        return virusCount - 1
    }
}
