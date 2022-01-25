//
//  Paikka+CoreDataProperties.swift
//  Path-in-map
//
//  Created by Toni Itkonen on 24.1.2022.
//
//

import Foundation
import CoreData


extension Paikka {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Paikka> {
        return NSFetchRequest<Paikka>(entityName: "Paikka")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var path: Path?

}

extension Paikka : Identifiable {

}
