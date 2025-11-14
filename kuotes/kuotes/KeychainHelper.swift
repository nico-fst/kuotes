//
//  KeychainHelper.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import Foundation
import Security

struct KeychainHelper {
    static func save(_ value: String, for key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // alten Wert löschen
        let deleteOldQuery = [ // identifiziert eindeutig
            kSecClass: kSecClassGenericPassword, // Item-Art: könnte auch Zertifikat, Schlüssel, ...
            kSecAttrAccount: key // eindeutiger Name
        ] as CFDictionary
        SecItemDelete(deleteOldQuery)
        
        let addNewQuery = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data, // neuer Wert
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock // wann Item zugänglich: könnte auch nur wenn entsperrt, immer, ...
        ] as CFDictionary
        
        let status = SecItemAdd(addNewQuery, nil)
        return status == errSecSuccess
    }
    
    static func read(_ key: String) -> String? {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
                kSecReturnData: true,
                kSecMatchLimit: kSecMatchLimitOne
            ] as CFDictionary
            
            var dataTypeRef: AnyObject?
            let status = SecItemCopyMatching(query, &dataTypeRef)
            
            if status == errSecSuccess, let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
            return nil
        }
        
        static func delete(_ key: String) {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key
            ] as CFDictionary
            
            SecItemDelete(query)
        }
}
