//
//  SignatureLog.swift
//  Kryptonite
//
//  Created by Alex Grinman on 9/13/16.
//  Copyright © 2016 KryptCo, Inc. All rights reserved.
//

import Foundation

struct SignatureLog {
    var session:String
    var digest:String
    var signature:String
    var date:Date
    var command:String?
    
    init(session:String, digest:String, signature:String, command:String? = nil, date:Date = Date()) {
        self.session = session
        self.digest = digest
        self.signature = signature
        self.date = date
        self.command = command
    }
    

}
