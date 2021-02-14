//
//  File.swift
//  
//
//  Created by Abdulla Jafar on 1/17/21.
//

import Vapor
import Fluent




struct CreateCategory : Migration {
    
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("categories")
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("categories").delete()
    }
    
    
}



