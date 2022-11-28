//
//  VisitTable.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 12/25/21.
//

/// Data structure for keeping track of which cells we've touched in a grid.
public class VisitTable {
    private var m_grid: [[Bool]]
    private let m_width: Int
    private let m_height: Int
    
    /// Number of cells across.
    var width: Int {get{return m_width}}
    /// Number of cells down.
    var height: Int {get{return m_height}}
    
    /// Constructor for visit table, initializing all visit flags to false.
    /// - Parameters:
    ///   - width: number of cell across
    ///   - height: number of cells down
    init(width: Int, height: Int) {
        m_width = width
        m_height = height
        m_grid = Array.init(repeating: Array.init(repeating: false, count: width), count: height)
    }
    
    /// Returns true if the given coordinates are within the bounds of the table.
    /// - Parameters:
    ///   - x: x cell position (0 based)
    ///   - y: y cell position (0 based)
    /// - Returns: true if in bounds; false if not
    private func isInBounds(x: Int, y: Int) -> Bool {
        return x >= 0 && y >= 0 && x < m_width && y < m_height
    }
    
    /// Returns true if the cell at the given coordinates has been visited.
    /// - Parameters:
    ///   - x: x cell position (0 based)
    ///   - y: y cell position (0 based)
    /// - Returns: true if visited; false if not visited
    func isVisited(x: Int, y: Int) -> Bool {
        guard isInBounds(x: x, y: y) else {
            return true
        }
        return m_grid[y][x]
    }
    
    /// Sets the visited flag for the cell at the given coordinates.
    /// - Parameters:
    ///   - x: x cell position (0 based)
    ///   - y: y cell position (0 based)
    func setVisited(x: Int, y: Int) {
        guard isInBounds(x: x, y: y) else {
            return
        }
        m_grid[y][x] = true
    }
    
    /// String of entire visit table values.
    var description: String {
        get {
            var arr: [String] = []
            for y in 0..<m_height {
                var row: [String] = []
                for x in 0..<m_width {
                    row.append(m_grid[y][x] ? "X" : "·")
                }
                arr.append(row.joined(separator: " "))
            }
            return arr.joined(separator: "\n")
        }
    }
}
