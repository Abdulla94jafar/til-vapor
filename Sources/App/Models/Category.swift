//
//  File.swift
//  
//
//  Created by Abdulla Jafar on 1/17/21.
//

import Vapor
import Fluent




final class Category : Model , Content {
    
    
    static var schema: String = "categories"
    
    @ID
    var id : UUID?
    
    @Field(key: "name")
    var name : String
    
    @Siblings(
        through: AcronymCategoryPivot.self,
        from: \.$category,
        to: \.$acronym
    )
    var acronyms : [Acronym]
    
    
    init() {}
    
    init( id : UUID? = nil , name : String) {
        self.id = id
        self.name = name
    }

    
}
