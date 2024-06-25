//
//  KeychainManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import Foundation

enum KeychainError: Error {
    case badData
    case servicesError(String)
    case itemNotFound
    case unableToConvertToString
}

enum KeychainService: String {
    case login = "User login"
    case tocken = "User tocken"
}

protocol KeychainManagerProtocol {
    func storeGenericPasswordFor(account: String, service: String, password: String) throws
    func getGenericPasswordFor(account: String, service: String) throws -> String
    func updateGenericPasswordFor(account: String, service: String, password: String) throws
    func deleteGenericPasswordFor(account: String, service: String) throws
}

final class KeychainManager {}

//MARK: - KeychainWrapperProtocol
extension KeychainManager: KeychainManagerProtocol {
    
    //Adding a Password to the Keychain
    func storeGenericPasswordFor(account: String,
                                 service: String,
                                 password: String) throws {
        guard let passwordData = password.data(using: .utf8) else {
            throw KeychainError.badData
        }
        let query: [ String : Any ] = [kSecClass as  String : kSecClassGenericPassword,///общай пароль
                                       kSecAttrAccount as  String : account,///имя пользователя
                                       kSecAttrService as  String : service,///сервис для пароля. Это произвольная строка, которая должна отражать назначение пароля, например, «логин пользователя».
                                       kSecValueData as  String : passwordData]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
        case errSecDuplicateItem:
            try updateGenericPasswordFor(account: account,
                                         service: service,
                                         password: password)
        case errSecSuccess:
            return
        default:
            if let errorMessage = SecCopyErrorMessageString(status, nil) {
                throw KeychainError.servicesError(String(errorMessage))
            } else {
                throw KeychainError.servicesError("Status Code: \(status)")
            }
        }
    }
    
    //Searching for Keychain Items
    func getGenericPasswordFor(account: String, service: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitOne,///чтобы сообщить Keychain Services, что вы ожидаете один элемент в качестве результата поиска.
            
            ///Последние два параметра в словаре указывают Keychain Services вернуть все данные и атрибуты для найденного значения:
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        guard status == errSecSuccess else {
            if let errorMessage = SecCopyErrorMessageString(status, nil) {
                throw KeychainError.servicesError(String(errorMessage))
            } else {
                throw KeychainError.servicesError("Status Code: \(status)")
            }
        }
        guard let existingItem = item as? [String: Any],
              let valueData = existingItem[kSecValueData as String] as? Data,
              let value = String(data: valueData, encoding: .utf8)
        else {
            throw KeychainError.unableToConvertToString
        }
        return value
    }
    
    //Updating a Password in the Keychain
    func updateGenericPasswordFor(account: String,
                                  service: String,
                                  password: String) throws {
        guard let passwordData = password.data(using: .utf8) else {
            print("Error converting value to data.")
            return
        }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: passwordData
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        guard status == errSecSuccess else {
            if let errorMessage = SecCopyErrorMessageString(status, nil) {
                throw KeychainError.servicesError(String(errorMessage))
            } else {
                throw KeychainError.servicesError("Status Code: \(status)")
            }
        }
    }
    
    //Deleting a Password From the Keychain
    func deleteGenericPasswordFor(account: String, service: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            if let errorMessage = SecCopyErrorMessageString(status, nil) {
                throw KeychainError.servicesError(String(errorMessage))
            } else {
                throw KeychainError.servicesError("Status Code: \(status)")
            }
        }
    }
}
