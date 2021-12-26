//
//  Misc.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 12/25/21.
//

public typealias IntPoint = (x: Int, y: Int)

public enum Color : CustomStringConvertible {
    case None
    case Red
    case Yellow
    case Blue
    
    public var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .None: return "none"
        case .Red: return "red"
        case .Yellow: return "yellow"
        case .Blue: return "blue"
        }
      }
}
