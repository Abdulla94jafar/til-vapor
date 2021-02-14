//
//  File.swift
//  
//
//  Created by Abdulla Jafar on 1/22/21.
//

import Vapor
import Leaf

struct IndexContext : Encodable {
    let title : String
    let acronyms : [Acronym]?
}


struct AcronymContext : Encodable {
    let title : String
    let acronym : Acronym
    let user : User
}

struct UserContext : Encodable  {
    let title : String
    let user : User
    let acronyms : [Acronym]
}
struct AllUsersContext : Encodable {
    let title : String
    let users : [User]
}

struct AllCategoriesContext : Encodable {
    let title : String
    let categories : [Category]
}
struct CategoriesContext : Encodable {
    let title : String
    let category : Category
    let acronyms : [Acronym]
}


struct CreateAcronymContext : Encodable {
    let title = "Create New Acronym"
    let users : [User]
}

struct WebsiteController : RouteCollection {
    
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("index", use:indexHandler  )
        routes.get("acronyms",":acronymID", use:acronymHandler  )
        routes.get("users",":userID", use:userHandler  )
        routes.get("users", use:allUsersHandler  )
        routes.get("categories", use:allCategoriesHandler  )
        routes.get("category",":categoryID", use:categoryHandler  )
        routes.get("category",":categoryID", use:categoryHandler  )
        routes.get("acronyms", "create", use: createAcronymHandler )
    }

    func indexHandler ( _ req : Request) throws -> EventLoopFuture<View> {
        return Acronym
            .query(on: req.db)
            .all()
            .flatMap { acronyms in
                let acronymsData = acronyms.isEmpty ? nil : acronyms
                let context =  IndexContext(title: "Home Page", acronyms: acronymsData)
                return req.view.render("index", context)
            }
    }
        
    func acronymHandler(_ req : Request) throws -> EventLoopFuture<View> {
        return Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                return acronym.$user.get(on: req.db)
                    .flatMap { user in
                        let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
                        return req.view.render("acronym", context)
                    }
            }
    }
        
    func userHandler (_ req : Request) throws -> EventLoopFuture<View> {
        
        return User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                return user
                    .$acronyms
                    .get(on: req.db)
                    .flatMap { acronyms in
                        let context = UserContext(title: user.name, user: user, acronyms: acronyms)
                        return req.view.render("users",context)
                    }
            }
    }

    func allUsersHandler (_ req : Request) throws -> EventLoopFuture<View> {
        return User
            .query(on: req.db)
            .all()
            .flatMap { users in
                let context = AllUsersContext(title: "All Users", users: users)
                return req.view.render("allUsers", context)
            }
    }

    func allCategoriesHandler (_ req : Request) throws -> EventLoopFuture<View> {
        return Category
            .query(on: req.db)
            .all()
            .flatMap { categories in
                let context = AllCategoriesContext(title: "All Categories", categories: categories)
                return req.view.render("allCategories", context)
            }
    }
    
    
    func categoryHandler (_ req : Request ) throws -> EventLoopFuture<View> {
        return Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                return category.$acronyms.get(on: req.db)
                    .flatMap { acronyms in
                        let context = CategoriesContext(title: category.name, category: category, acronyms: acronyms)
                        return req.view.render("category.leaf", context)
                    }
                
            }
    }
    
    
    func createAcronymHandler (_ req : Request ) throws -> EventLoopFuture<View> {
        return User
            .query(on: req.db )
            .all()
            .flatMap { users in
                let context = CreateAcronymContext(users: users)
                return req.view.render("createAcronym", context)
            }
    }
    
    
}
