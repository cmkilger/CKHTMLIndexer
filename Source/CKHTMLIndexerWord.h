//
//  Word.h
//  Indexer
//
//  Created by Cory Kilger on 9/19/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CKHTMLIndexerFile;

@interface CKHTMLIndexerWord :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSSet* files;

@end


@interface CKHTMLIndexerWord (CoreDataGeneratedAccessors)
- (void)addFilesObject:(CKHTMLIndexerFile *)value;
- (void)removeFilesObject:(CKHTMLIndexerFile *)value;
- (void)addFiles:(NSSet *)value;
- (void)removeFiles:(NSSet *)value;

@end

