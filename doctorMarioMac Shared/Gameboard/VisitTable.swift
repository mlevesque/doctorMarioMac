//
//  VisitTable.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 12/25/21.
//

public class VisitTable {
    private var m_grid: [[Bool]]
    private let m_width: Int
    private let m_height: Int
    
    var width: Int {get{return m_width}}
    var height: Int {get{return m_height}}
    
    init(width: Int, height: Int) {
        m_width = width
        m_height = height
        m_grid = Array.init(repeating: Array.init(repeating: false, count: width), count: height)
    }
    
    private func isInBounds(x: Int, y: Int) -> Bool {
        return x >= 0 && y >= 0 && x < m_width && y < m_height
    }
    
    func isVisited(x: Int, y: Int) -> Bool {
        guard isInBounds(x: x, y: y) else {
            return true
        }
        return m_grid[y][x]
    }
    
    func setVisited(x: Int, y: Int) {
        guard isInBounds(x: x, y: y) else {
            return
        }
        m_grid[y][x] = true
    }
}
