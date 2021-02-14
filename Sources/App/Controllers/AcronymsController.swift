//
//  File.swift
//  
//
//  Created by Abdulla Jafar on 1/13/21.
//

import Vapor
import Fluent


struct CreateAcronymData : Content {
    let short : String
    let long : String
    let userID : UUID
}




struct AcronymsController : RouteCollection {
    
    // MARK: - BOOT
    func boot(routes: RoutesBuilder) throws {
        let acronymRouters = routes.grouped("api","acronyms")
        
        acronymRouters.get(use: getAllHandler)
        acronymRouters.post(use: createHandler)
        acronymRouters.get(":acronymID",use: findHandler)
        acronymRouters.put(":acronymID",use: findHandler)
        acronymRouters.delete(":acronymID",use: deleteHandler)
        acronymRouters.get("search",use: searchHandler)
        acronymRouters.get("get-first",use: getFirstHandler)
        acronymRouters.get("sorted",use: sortHandler)
        acronymRouters.get(":acronymID", "user", use : getUserHandler)
        acronymRouters.post(":acronymID","categories",":categoryID", use: addCategoriesHandler)
        acronymRouters.get(":acronymID","categories", use: getCategoriesHandler)
    }
    
    
    
    /// not a safe way to create a acronym, because the client can send a body with non existing user id
    func createHandler(_ req : Request) throws -> EventLoopFuture<Acronym> {
        let data = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(
            short: data.short,
            long: data.long,
            userID: data.userID
        )
        return acronym
            .save(on: req.db)
            .map { acronym }
    }
    
//    func createSafeHandler(_ req : Request) throws -> EventLoopFuture<Acronym> {
//        let data = try req.content.decode(CreateAcronymData.self)
//        let acronym = Acronym(
//            short: data.short,
//            long: data.long,
//            userID: data.userID
//        )
//        return User
//            .find(data.userID, on: req.db)
//            .unwrap(or: Abort(.notFound))
//            .flatMap { _ in
//                acronym.save(on: req.db)
//                    .map { acronym}
//            }
//
//    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
      Acronym.query(on: req.db).all()
    }
    
    func findHandler(_ req : Request) throws -> EventLoopFuture<Acronym> {
        return Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req : Request) throws -> EventLoopFuture<Acronym> {
        let updateData = try req.content.decode(CreateAcronymData.self)
        return Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { foundAcronym in
                foundAcronym.short = updateData.short
                foundAcronym.long = updateData.long
                foundAcronym.$user.id = updateData.userID
                return foundAcronym
                    .save(on: req.db)
                    .map { foundAcronym }
            }
    }
    
    func deleteHandler (_ req : Request ) throws -> EventLoopFuture<HTTPStatus> {
        return Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { foundAcronym in
                return foundAcronym.delete(on: req.db)
                    .transform(to: HTTPStatus.noContent)
            }
    }
    
    func searchHandler (_ req : Request ) throws -> EventLoopFuture<[Acronym]> {
        guard let searchTerm =  req.query[String.self, at : "term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req.db).group(.or) { or in
            or.filter(\.$short == searchTerm)
            or.filter(\.$long == searchTerm)
        }
        .all()
    }
    
    func getFirstHandler (_ req : Request) throws -> EventLoopFuture<Acronym> {
        Acronym.query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }

    func sortHandler (_ req : Request ) throws -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db)
            .sort(\.$short,.descending)
            .all()
    }
        
    func getUserHandler (_ req : Request) throws -> EventLoopFuture<User> {
        return Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { foundAcronym in
                return foundAcronym.$user.get(on : req.db)
            }
        
    }
    
    
    func addCategoriesHandler (_ req : Request) throws -> EventLoopFuture<HTTPStatus> {
        let acronym = Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        let category = Category.find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        return acronym
            .and(category) // use this method to json two futures
            .flatMap { acronym, category in //  use this method to flat two futures
                return acronym
                    .$categories
                    .attach(category, on: req.db) // this method creates a pivot model and save it in db
                    .transform(to: .created)
            }
    }
    
    
    func getCategoriesHandler (_ req : Request ) throws -> EventLoopFuture<[Category]> {
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                return acronym
                    .$categories
                    .query(on: req.db).all()

            }
    }
    
    
    
    func removeCategoryHandler (_ req : Request ) throws -> EventLoopFuture<HTTPStatus> {
        
        
        let acronym = Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        let category = Category.find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        return acronym
            .and(category)
            .flatMap { acronym , category in
                return acronym
                    .$categories
                    .detach(category, on: req.db)
                    .transform(to: HTTPStatus.noContent)
            }
    }
    
}
