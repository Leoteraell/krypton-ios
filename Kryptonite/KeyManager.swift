//
//  KeyManager.swift
//  Kryptonite
//
//  Created by Alex Grinman on 8/31/16.
//  Copyright © 2016 KryptCo, Inc. All rights reserved.
//

import Foundation


enum KeyTag:String {
    case me = "me"
    case peer = "peer"
}

private let KrMeDataKey = "kr_me_email"

enum KeyManagerError:Error {
    case keyDoesNotExist
}


class KeyManager {
    
    var keyPair:KeyPair
    
    init(_ keyPair:KeyPair) {
        self.keyPair = keyPair
    }
    
    class func sharedInstance() throws -> KeyManager {
        do {
            let loadStart = Date().timeIntervalSince1970
            guard let kp = try RSAKeyPair.load(KeyTag.me.rawValue) else {
                throw KeyManagerError.keyDoesNotExist
            }
            let loadEnd = Date().timeIntervalSince1970
            
            log("keypair load took \(loadEnd - loadStart) seconds")
            
            return KeyManager(kp)
        }
        catch let e {
            log("Crypto Load error -> \(e)", LogType.warning)
            throw e
        }
    }
    
    class func generateKeyPair(type:KeyType) throws {
        do {
            switch type {
            case .RSA:
                let _ = try RSAKeyPair.generate(KeyTag.me.rawValue)
            case .Ed25519:
                fatalError("ed25519 unimplemented")
            }
        }
        catch let e {
            log("Crypto Generate error -> \(e)", LogType.warning)
            throw e
        }
    }
    
    class func destroyKeyPair() -> Bool {
        let rsaResult = (try? RSAKeyPair.destroy(KeyTag.me.rawValue)) ?? false
       //let ed25 = try? RSAKeyPair.destroy(KeyTag.me.rawValue) ?? false

        return rsaResult
    }
    
    class func hasKey() -> Bool {
        if let _ = try? RSAKeyPair.load(KeyTag.me.rawValue) {
            log("has rsa key is true")
            return true
        }

        return true
    }
    
    func getMe() throws -> Peer {
        do {
            let email = try KeychainStorage().get(key: KrMeDataKey)
            let publicKey = try keyPair.publicKey.wireFormat()
            let fp = publicKey.fingerprint()
            
            return Peer(email: email, fingerprint: fp, publicKey: publicKey)
            
        } catch (let e) {
            throw e
        }
    }
    
    class func setMe(email:String) {
        let success = KeychainStorage().set(key: KrMeDataKey, value: email)
        if !success {
            log("failed to store `me` email.", LogType.error)
        }
        dispatchAsync { Analytics.sendEmailToTeamsIfNeeded(email: email) }
    }
    
    class func clearMe() {
        let success = KeychainStorage().delete(key: KrMeDataKey)
        if !success {
            log("failed to delete `me` email.", LogType.error)
        }
    }
    
}



