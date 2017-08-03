//
//  Workouts+CoreDataProperties.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/8/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import Foundation
import CoreData


extension Workouts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workouts> {
        return NSFetchRequest<Workouts>(entityName: "Workouts")
    }

    @NSManaged public var data: String?
    @NSManaged public var title: String?
    @NSManaged public var typeWorkouts: Bool
    @NSManaged public var userId: String?

}
