//
//  File.swift
//  
//
//  Created by Abdulla Jafar on 1/8/21.
//

import Foundation
import Fluent
import Vapor




struct CreateAcronym : Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms")
            .id()
            .field("short",.string, .required)
            .field("long",.string, .required)
            .field("userID", .uuid, .required, .references("users", "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms").delete()
    }
    
    
}
