//
//  File.swift
//  
//
//  Created by Abdulla Jafar on 1/17/21.
//

import Vapor
import Fluent



struct CategoryController : RouteCollection  {
    
    func boot(routes: RoutesBuilder) throws {
        let categoryGroup = routes.grouped("api","categories")
        
        categoryGroup.post(use: createHandler)
        categoryGroup.get(use: getAllHandler)
        categoryGroup.get(":categoryID",use: getAllHandler)
        categoryGroup.get(":categoryID","acronyms",use: getAllHandler)
    }
    
    
    
    func createHandler (_ req : Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
        return category
            .save(on: req.db)
            .map { category}
    }
    
    
    func getAllHandler (_ req : Request ) throws -> EventLoopFuture<[Category]> {
        let data =  Category
            .query(on: req.db)
            .all()
        
        print(data)
    
        return data
    }
    
    func getHandler (_ req : Request) throws -> EventLoopFuture<Category> {
        return Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getAcronyms(_ req : Request) throws -> EventLoopFuture<[Acronym]> {
        return Category.find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                return category.$acronyms.get(on: req.db)
            }
    }
    
    

}
