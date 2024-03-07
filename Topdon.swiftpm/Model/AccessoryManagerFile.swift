//
//  AccessoryManagerFile.swift
//
//
//  Created by Alsey Coleman Miller  on 3/6/24.
//

import Foundation
import Topdon

public extension AccessoryManager {
    
    /// Accessory information database.
    var accessoryInfo: TopdonAccessoryInfo.Database? {
        get {
            // return cache
            if let cache = fileManagerCache.accessoryInfo {
                return cache
            } else {
                // attempt to read cache in background.
                Task(priority: .userInitiated) {
                    do { try readAccessoryInfoFile() }
                    catch CocoaError.fileReadNoSuchFile {
                        // download if no file.
                        do { try await downloadAccessoryInfo() }
                        catch URLError.notConnectedToInternet {
                            // cannot download
                        }
                        catch {
                            log("Unable to download accessory info. \(error)")
                        }
                    }
                    catch {
                        log("Unable to read accessory info. \(error)")
                    }
                }
                return nil
            }
        }
    }
}

internal extension AccessoryManager {
    
    func loadDocumentDirectory() -> URL {
        guard let url = fileManager.documentDirectory else {
            fatalError()
        }
        return url
    }
    
    func loadCachesDirectory() -> URL {
        guard let url = fileManager.cachesDirectory else {
            fatalError()
        }
        return url
    }
    
    var accessoryInfoFileURL: URL {
        documentDirectory.appendingPathComponent(FileName.accessoryInfo.rawValue)
    }
    
    func saveAccessoryInfoFile(_ value: TopdonAccessoryInfo.Database) throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(value)
        try data.write(to: accessoryInfoFileURL, options: [.atomic])
        // cache value
        if fileManagerCache.accessoryInfo != value {
            fileManagerCache.accessoryInfo = value
        }
    }
    
    @discardableResult
    func readAccessoryInfoFile() throws -> TopdonAccessoryInfo.Database {
        let data = try Data(contentsOf: accessoryInfoFileURL, options: [.mappedIfSafe])
        let decoder = PropertyListDecoder()
        let value = try decoder.decode(TopdonAccessoryInfo.Database.self, from: data)
        // cache value
        if fileManagerCache.accessoryInfo != value {
            fileManagerCache.accessoryInfo = value
        }
        return value
    }
}

internal extension AccessoryManager {
    
    struct FileManagerCache {
        
        var accessoryInfo: TopdonAccessoryInfo.Database?
    }
    
    enum FileName: String {
        
        case accessoryInfo = "Topdon.plist"
        
        
    }
}