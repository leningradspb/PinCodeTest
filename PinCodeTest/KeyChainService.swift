//
//  KeyChainService.swift
//  PinCodeTest
//
//  Created by Eduard Sinyakov on 4/23/20.
//  Copyright © 2020 Eduard Siniakov. All rights reserved.
//

import UIKit

final class KeyChainService {

	enum Keys {
		static let pinCode = "pinCode"
	}

    func set(key: String, value: String) {
        let query: [String : Any] = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key]

        let valueData = value.data(using: String.Encoding.utf8)!

        let attributes: [String : Any] = [
            kSecValueData as String: valueData]

        let state = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if state == errSecItemNotFound {
            let queryToCreate = query.merging(attributes) { (current, _) in current }
            SecItemAdd(queryToCreate as CFDictionary, nil)
        }
    }

    func get(key: String) -> String? {
        let query: [String : Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == noErr,
            let existingItem = item as? [String : Any],
            let valueData = existingItem[kSecValueData as String] as? Data,
            let value = String(data: valueData, encoding: String.Encoding.utf8) else {
                return nil
        }

        return value
    }

    func delete(key: String) {
        let query: [String : Any] = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key]

        SecItemDelete(query as CFDictionary)
    }
}
