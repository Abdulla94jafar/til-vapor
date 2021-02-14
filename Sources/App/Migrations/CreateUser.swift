//
//  File.swift
//  
//
//  Created by Abdulla Jafar on 1/14/21.
//

import Fluent
import Vapor



struct CreateUser : Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("name",.string,.required)
            .field("username",.string,.required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
    
    
}
