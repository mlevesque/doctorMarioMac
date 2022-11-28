//
//  Misc.swift
//  doctorMarioMac
//
//  Created by Michael Levesque on 12/25/21.
//

import CoreGraphics

public typealias IntPoint = (x: Int, y: Int)

// MARK: COLOR

#if os(iOS) || os(tvOS)
import UIKit
public typealias OSColor = UIColor
#endif

#if os(OSX)
import AppKit
public typealias OSColor = NSColor
#endif

public func getColorSet(_ name: String) -> OSColor {
    #if os(iOS) || os(tvOS)
    return UIColor(named: name) ?? .magenta
    #endif
    #if os(OSX)
    return NSColor(named: name) ?? .magenta
    #endif
}

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

public func convertStringToColor(_ str: String) -> Color {
    switch str {
    case "red":
        return .Red
    case "yellow":
        return .Yellow
    case "blue":
        return .Blue
    default:
        return .None
    }
}
