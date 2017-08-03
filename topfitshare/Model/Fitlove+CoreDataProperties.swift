//
//  Fitlove+CoreDataProperties.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/8/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import Foundation
import CoreData


extension Fitlove {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Fitlove> {
        return NSFetchRequest<Fitlove>(entityName: "Fitlove")
    }

    @NSManaged public var isFitLove: Bool
    @NSManaged public var userId: String?
    @NSManaged public var username: String?
    @NSManaged public var workoutsName: String?

}
