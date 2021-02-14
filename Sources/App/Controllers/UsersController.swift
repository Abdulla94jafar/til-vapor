//
//  File.swift
//  
//
//  Created by Abdulla Jafar on 1/14/21.
//

import Vapor
import Fluent



struct UsersController : RouteCollection {
    
    // MAKR: - BOOT
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("api", "users")
        usersRoute.post(use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(":userID",use: getUserHandler)
        usersRoute.get(":userID","acronyms",use: getAllAcronymsHandler)
    }
    
    // CREATE
    func createHandler (_ req : Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user
            .save(on: req.db)
            .map {user}
    }
    
    // GET ALL
    func getAllHandler  (_ req : Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: req.db)
            .all()
    }
    
    // FIND
    func getUserHandler (_ req : Request) throws -> EventLoopFuture<User> {
        return User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    
    func getAllAcronymsHandler (_ req : Request) throws -> EventLoopFuture<[Acronym]> {
        return User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap{ foundUser in
                return foundUser.$acronyms.get(on: req.db)
            }
    }
    
    
}
