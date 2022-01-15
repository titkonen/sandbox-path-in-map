//
//  Path+CoreDataProperties.swift
//  Path-in-map
//
//  Created by Toni Itkonen on 15.1.2022.
//
//

import Foundation
import CoreData


extension Path {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Path> {
        return NSFetchRequest<Path>(entityName: "Path")
    }

    @NSManaged public var distance: Double
    @NSManaged public var duration: Int16
    @NSManaged public var timestamp: Date?
    @NSManaged public var paikat: NSOrderedSet?

}

// MARK: Generated accessors for paikat
extension Path {

    @objc(insertObject:inPaikatAtIndex:)
    @NSManaged public func insertIntoPaikat(_ value: Paikka, at idx: Int)

    @objc(removeObjectFromPaikatAtIndex:)
    @NSManaged public func removeFromPaikat(at idx: Int)

    @objc(insertPaikat:atIndexes:)
    @NSManaged public func insertIntoPaikat(_ values: [Paikka], at indexes: NSIndexSet)

    @objc(removePaikatAtIndexes:)
    @NSManaged public func removeFromPaikat(at indexes: NSIndexSet)

    @objc(replaceObjectInPaikatAtIndex:withObject:)
    @NSManaged public func replacePaikat(at idx: Int, with value: Paikka)

    @objc(replacePaikatAtIndexes:withPaikat:)
    @NSManaged public func replacePaikat(at indexes: NSIndexSet, with values: [Paikka])

    @objc(addPaikatObject:)
    @NSManaged public func addToPaikat(_ value: Paikka)

    @objc(removePaikatObject:)
    @NSManaged public func removeFromPaikat(_ value: Paikka)

    @objc(addPaikat:)
    @NSManaged public func addToPaikat(_ values: NSOrderedSet)

    @objc(removePaikat:)
    @NSManaged public func removeFromPaikat(_ values: NSOrderedSet)

}

extension Path : Identifiable {

}
