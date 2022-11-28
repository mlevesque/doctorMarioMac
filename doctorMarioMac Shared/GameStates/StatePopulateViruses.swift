//
//  StatePopulateViruses.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 1/8/22.
//

import GameplayKit

public class StatePopulateViruses : GKState {
    private let m_model: GameModel
    private var m_virusPropagator: IVirusPropagtor!
    private var m_remaining: Int
    
    public init(model: GameModel) {
        m_model = model
        m_virusPropagator = nil
        m_remaining = 0
    }
    
    public override func didEnter(from previousState: GKState?) {
        // @TODO get these from some other place
        let ceiling = 4
        let virusCount = 90
        
        m_virusPropagator = buildVirusPropagator(gameboardWidth: m_model.gameboard!.gridWidth, gameboardHeight: m_model.gameboard!.gridHeight, ceilingLimit: ceiling)
        m_remaining = virusCount
        m_model.gameboard?.clear()
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        if m_remaining <= 0 {
            return
        }
        m_remaining = m_virusPropagator.generate(virusesRemaining: m_remaining, gameboard: m_model.gameboard!)
    }
    
    public override func willExit(to nextState: GKState) {
        
    }
}
