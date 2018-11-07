//
//  RemoteRecord.swift
//  Harmony
//
//  Created by Riley Testut on 6/10/17.
//  Copyright © 2017 Riley Testut. All rights reserved.
//

import CoreData

@objc(RemoteRecord)
public class RemoteRecord: RecordRepresentation
{
    /* Properties */
    @NSManaged public var identifier: String
    @NSManaged public var isLocked: Bool
    
    @NSManaged var previousUnlockedVersion: ManagedVersion?
    
    /* Relationships */
    @NSManaged var version: ManagedVersion
    
    init(identifier: String, versionIdentifier: String, versionDate: Date, recordedObjectType: String, recordedObjectIdentifier: String, status: RecordRepresentation.Status, context: NSManagedObjectContext)
    {
        super.init(entity: RemoteRecord.entity(), insertInto: context)
        
        self.identifier = identifier
        
        self.recordedObjectType = recordedObjectType
        self.recordedObjectIdentifier = recordedObjectIdentifier
        
        self.status = status
        
        self.version = ManagedVersion(identifier: versionIdentifier, date: versionDate, context: context)
    }
    
    public convenience init(identifier: String, versionIdentifier: String, versionDate: Date, metadata: [HarmonyMetadataKey: String], status: RecordRepresentation.Status, context: NSManagedObjectContext) throws
    {
        guard let recordedObjectType = metadata[.recordedObjectType], let recordedObjectIdentifier = metadata[.recordedObjectIdentifier] else { throw RemoteRecordError(code: .invalidMetadata) }
        
        self.init(identifier: identifier, versionIdentifier: versionIdentifier, versionDate: versionDate, recordedObjectType: recordedObjectType, recordedObjectIdentifier: recordedObjectIdentifier, status: status, context: context)
        
        if let isLocked = metadata[.isLocked], isLocked == "true"
        {
            self.isLocked = true            
        }
        
        if let identifier = metadata[.previousVersionIdentifier], let dateString = metadata[.previousVersionDate], let timeInterval = TimeInterval(dateString)
        {
            let date = Date(timeIntervalSinceReferenceDate: timeInterval)
            self.previousUnlockedVersion = ManagedVersion(identifier: identifier, date: date, context: context)
        }
    }
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?)
    {
        super.init(entity: entity, insertInto: context)
    }
}

extension RemoteRecord
{
    @nonobjc class func fetchRequest() -> NSFetchRequest<RemoteRecord>
    {
        return NSFetchRequest<RemoteRecord>(entityName: "RemoteRecord")
    }
}