//
//  Message.swift
//
//
//  Created by Alsey Coleman Miller on 3/8/24.
//

import Foundation
import Telink

public protocol TopdonSerialMessage {
    
    static var opcode: TopdonSerialMessageOpcode { get }
}

public struct TopdonCommand <T>: Equatable, Hashable, Encodable, Sendable, Telink.SerialPortProtocolCommand where T: Equatable, T: Hashable, T: Encodable, T: Sendable, T: TopdonSerialMessage {
    
    public static var type: SerialPortProtocolType { .topdon }
    
    public let opcode: TopdonSerialMessageOpcode
    
    public let payload: T
    
    public init(_ command: T) {
        self.opcode = T.opcode
        self.payload = command
    }
}

public struct TopdonEvent: Equatable, Hashable, Decodable, Sendable, Telink.SerialPortProtocolEvent {
    
    public static var type: SerialPortProtocolType { .topdon }
    
    public let opcode: TopdonSerialMessageOpcode
    
    public let payload: Data
    
    public func decode<T>(_ type: T.Type) throws -> T where T: Decodable, T: TopdonSerialMessage {
        guard T.opcode == self.opcode else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid opcode \(type.opcode)"))
        }
        let decoder = TelinkDecoder(isLittleEndian: false)
        return try decoder.decode(type, from: payload)
    }
}

// MARK: - Supporting Types

/// Topdon Serial Message Opcode
public struct TopdonSerialMessageOpcode: Equatable, Hashable, Codable, Sendable {
    
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension TopdonSerialMessageOpcode: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt32) {
        self.init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension TopdonSerialMessageOpcode: CustomStringConvertible {
    
    public var description: String {
        "0x" + rawValue.toHexadecimal()
    }
}

// MARK: - Constants

public extension TopdonSerialMessageOpcode {
    
    static var bt20BatteryVoltageCommand: TopdonSerialMessageOpcode { 0xFFF2DD02 }
    
    static var bt20BatteryVoltageNotification: TopdonSerialMessageOpcode { 0xFFF0DD03 }
    
    static var bt20loggingIntervalCommand: TopdonSerialMessageOpcode { 0xFFF6DD0B }
        
    static var bt20VersionCommand: TopdonSerialMessageOpcode { 0xFFF8DD09 }
    
    static var tb6000ProQuickChargeCommand: TopdonSerialMessageOpcode { 0xFFF8BF11 }
    
    static var tb6000ProBatteryVoltageNotification: TopdonSerialMessageOpcode { 0xFFE5BF12 }
}
