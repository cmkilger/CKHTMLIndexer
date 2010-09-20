//
//  File.h
//  Indexer
//
//  Created by Cory Kilger on 9/19/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CKHTMLIndexerWord;

@interface CKHTMLIndexerFile :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSSet* words;

@end


@interface CKHTMLIndexerFile (CoreDataGeneratedAccessors)
- (void)addWordsObject:(CKHTMLIndexerWord *)value;
- (void)removeWordsObject:(CKHTMLIndexerWord *)value;
- (void)addWords:(NSSet *)value;
- (void)removeWords:(NSSet *)value;

@end

