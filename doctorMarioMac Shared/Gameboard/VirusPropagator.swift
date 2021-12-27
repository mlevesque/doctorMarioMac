//
//  VirusPropagator.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 12/26/21.
//

public typealias VirusPosition = (color: Color, position: IntPoint)
public typealias VirusPropagationResult = (missingRed: Int, missingYellow: Int, missingBlue: Int, results: [VirusPosition])

fileprivate func isValidPosition(pos: IntPoint, visit: VisitTable) -> Bool {
    guard !visit.isVisited(x: pos.x, y: pos.y) else {
        return false
    }
    
    // test horizontal
    var count = 1
    var x = pos.x + 1
    while count < 3 && x < visit.width && visit.isVisited(x: x, y: pos.y) {
        count += 1
        x += 1
    }
    x = pos.x - 1
    while count < 3 && x >= 0 && visit.isVisited(x: x, y: pos.y) {
        count += 1
        x -= 1
    }
    if count >= 3 {
        return false
    }
    
    // test vertical
    count = 1
    var y = pos.y + 1
    while count < 3 && y < visit.height && visit.isVisited(x: pos.x, y: y) {
        count += 1
        y += 1
    }
    y = pos.y - 1
    while count < 3 && y >= 0 && visit.isVisited(x: pos.x, y: y) {
        count += 1
        y -= 1
    }
    if count >= 3 {
        return false
    }
    
    return true
}

fileprivate var num = 0

fileprivate func pickPosition(width: Int, height: Int, visit: VisitTable) -> IntPoint? {
    let pos = (Int.random(in: 0..<width), Int.random(in: 0..<height))
    return pickPositionRecursion(pos: pos, visit: visit, offset: 0)
}

fileprivate func pickPositionRecursion(pos: IntPoint, visit: VisitTable, offset: Int) -> IntPoint? {
    var potentialPositions: [IntPoint] = []
    
    if offset == 0 {
        potentialPositions.append(pos)
    }
    else {
        let start: IntPoint = (pos.x - offset, pos.y - offset)
        let end: IntPoint = (pos.x + offset, pos.y + offset)
        for x in start.x...end.x {
            if !visit.isVisited(x: x, y: start.y) {
                potentialPositions.append((x, start.y))
            }
            if !visit.isVisited(x: x, y: end.y) {
                potentialPositions.append((x, end.y))
            }
        }
        for y in (start.y + 1)..<end.y {
            if !visit.isVisited(x: start.x, y: y) {
                potentialPositions.append((start.x, y))
            }
            if !visit.isVisited(x: end.x, y: y) {
                potentialPositions.append((end.x, y))
            }
        }
    }
    
    guard !potentialPositions.isEmpty else {
        return nil
    }
    
    while !potentialPositions.isEmpty {
        let index = Int.random(in: 0..<potentialPositions.count)
        let newPos = potentialPositions.remove(at: index)
        if isValidPosition(pos: newPos, visit: visit) {
            return newPos
        }
    }
    return pickPositionRecursion(pos: pos, visit: visit, offset: offset + 1)
}

public func generateVirusPositions(gridWidth: Int, gridHeight: Int, redCount: Int, yellowCount: Int, blueCount: Int) -> VirusPropagationResult {
    // build data structures
    var results: [VirusPosition] = []
    var virusCounts: [(Color, Int)] = []
    var visits: Dictionary<Color, VisitTable> = Dictionary()
    if redCount > 0 {
        virusCounts.append((.Red, redCount))
        visits[.Red] = VisitTable(width: gridWidth, height: gridHeight)
    }
    if yellowCount > 0 {
        virusCounts.append((.Yellow, yellowCount))
        visits[.Yellow] = VisitTable(width: gridWidth, height: gridHeight)
    }
    if blueCount > 0 {
        virusCounts.append((.Blue, blueCount))
        visits[.Blue] = VisitTable(width: gridWidth, height: gridHeight)
    }
    
    var failureCounts: [Color:Int] = [.Red: 0, .Yellow: 0, .Blue: 0]
    while !virusCounts.isEmpty {
        // pick a color
        let index = Int.random(in: 0..<virusCounts.count)
        let color = virusCounts[index].0
        
        // pick a position
        if let v = visits[color], let pos = pickPosition(width: gridWidth, height: gridHeight, visit: v) {
            v.setVisited(x: pos.x, y: pos.y)
            results.append((color: color, position: pos))
        }
        else {
            failureCounts[color]! += 1
        }
        
        // decrement count
        virusCounts[index].1 -= 1
        if virusCounts[index].1 <= 0 {
            virusCounts.remove(at: index)
        }
    }
    
    return VirusPropagationResult(
        missingRed: failureCounts[.Red]!,
        missingYellow: failureCounts[.Yellow]!,
        missingBlue: failureCounts[.Blue]!,
        results: results
    )
}
