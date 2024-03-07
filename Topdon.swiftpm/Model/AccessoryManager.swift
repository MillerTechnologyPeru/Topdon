//
//  Store.swift
//
//
//  Created by Alsey Coleman Miller on 4/12/23.
//

import Foundation
import SwiftUI
import CoreBluetooth
import Bluetooth
import GATT
import DarwinGATT
import Topdon

@MainActor
public final class AccessoryManager: ObservableObject {
    
    // MARK: - Properties
    
    @Published
    public internal(set) var state: DarwinBluetoothState = .unknown
    
    public var isScanning: Bool {
        scanStream != nil
    }
    
    @Published
    public internal(set) var peripherals = [NativeCentral.Peripheral: TopdonAccessory.Advertisement]()
    
    internal lazy var central = NativeCentral()
    
    @Published
    internal var scanStream: AsyncCentralScan<NativeCentral>?
    
    internal lazy var urlSession = loadURLSession()
    
    internal lazy var fileManager = FileManager()
    
    internal lazy var documentDirectory = loadDocumentDirectory()
    
    internal lazy var cachesDirectory = loadDocumentDirectory()
    
    @Published
    internal var fileManagerCache = FileManagerCache()
    
    // MARK: - Initialization
    
    public static let shared = AccessoryManager()
    
    private init() {
        central.log = { [unowned self] in self.log("📲 Central: " + $0) }
        observeBluetoothState()
    }
}