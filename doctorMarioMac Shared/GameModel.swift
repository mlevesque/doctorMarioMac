//
//  GameModel.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 1/8/22.
//

public class GameModel {
    var remainingRed: Int = 0
    var remainingYellow: Int = 0
    var remainingBlue: Int = 0
    var gameboard: IGameboard? = nil
    var floatingPills: [IPill] = []
}
