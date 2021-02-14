//
//  File.swift
//  
//
//  Created by Abdulla Jafar on 1/14/21.
//

import Fluent
import Vapor




final class User : Model , Content {
    
    
    static var schema: String = "users"
    
    
    @ID
    var id : UUID?
    
    @Field(key: "name")
    var name : String
    
    @Field(key: "username")
    var username : String
    
    @Children(for: \Acronym.$user)
    var acronyms : [Acronym]
    
    init() { }
    
    init(id : UUID? = nil, name : String, username : String, acronyms : [Acronym]) {
        self.id = id
        self.name = name
        self.username =  username
        self.acronyms = acronyms
    }
}
