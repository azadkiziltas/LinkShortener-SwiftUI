//
//  ShortenedLink+CoreDataProperties.swift
//  LinkShortener
//
//  Created by Azad KIZILTAŞ on 2.10.2024.
//
//

import Foundation
import CoreData


extension ShortenedLink {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShortenedLink> {
        return NSFetchRequest<ShortenedLink>(entityName: "ShortenedLink")
    }

    @NSManaged public var url: String?

}

extension ShortenedLink : Identifiable {

}
