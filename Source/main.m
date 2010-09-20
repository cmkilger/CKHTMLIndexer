//
//  main.m
//  Indexer
//
//  Created by Cory Kilger on 9/18/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <objc/objc-auto.h>
#import "CKHTMLIndexerDataModel.h"
#import "CKHTMLIndexerFile.h"
#import "CKHTMLIndexerWord.h"

@interface CKFileObject : NSObject {
	NSString * title;
	NSString * path;
}

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * path;

@end

@implementation CKFileObject

@synthesize title, path;

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ <%@>", title, path];
}

- (void) dealloc {
	[title release];
	[path release];
	[super dealloc];
}

@end


#pragma mark -

void parse(NSString * directory, NSArray * blacklist, NSMutableDictionary * dictionary);
NSManagedObjectModel * managedObjectModel(NSString * path);
NSManagedObjectContext * managedObjectContext(NSString * path);

#pragma mark -

int main (int argc, const char * argv[]) {

	objc_startCollectorThread();
	
	if (argc < 3 || argc > 4) {
		printf("Usage: indexer <path/to/directory> <path/to/output/index> [blacklist.txt]\n");
		return -1;
	}
	
	// Create the managed object context
	NSString * outputPath = [[[NSProcessInfo processInfo] arguments] objectAtIndex:2];
	NSManagedObjectContext *context = managedObjectContext(outputPath);
	
	// Create the blacklist
	NSString * blacklistStr = nil;
	if (argc == 4)
		blacklistStr = [NSString stringWithContentsOfFile:[[[NSProcessInfo processInfo] arguments] objectAtIndex:3] encoding:NSUTF8StringEncoding error:nil];
	NSMutableArray * blacklist = [NSMutableArray array];
	[blacklistStr enumerateSubstringsInRange:NSMakeRange(0, [blacklistStr length]) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		[blacklist addObject:[substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}];
	
	// Index the files
	NSString * directory = [[[NSProcessInfo processInfo] arguments] objectAtIndex:1];
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	parse(directory, blacklist, dictionary);
	
	// Put data in context
	NSMutableDictionary * filePathCache = [NSMutableDictionary dictionary];
	for (NSString * key in [dictionary allKeys]) {
		CKHTMLIndexerWord * word = [NSEntityDescription insertNewObjectForEntityForName:@"CKHTMLIndexerWord" inManagedObjectContext:context];
		word.word = key;
		NSSet * files = [dictionary objectForKey:key];
		for (CKFileObject * fileObject in files) {
			CKHTMLIndexerFile * file = [filePathCache objectForKey:fileObject.path];
			if (!file) {
				file = [NSEntityDescription insertNewObjectForEntityForName:@"CKHTMLIndexerFile" inManagedObjectContext:context];
				file.path = fileObject.path;
				file.name = fileObject.title;
				[filePathCache setObject:file forKey:fileObject.path];
			}
			[word addFilesObject:file];
		}
	}
	
	// Save the managed object context
	NSError *error = nil;    
	if (![context save:&error]) {
		NSLog(@"Error while saving\n%@",
			  ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
		exit(1);
	}
	
    return 0;
}

void parse(NSString * path, NSArray * blacklist, NSMutableDictionary * dictionary) {	
	BOOL isDirectory = NO;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
		printf("File %s does not exist.\n", [path cStringUsingEncoding:NSUTF8StringEncoding]);
		return;
	}
	
	// If it's a directory, parse each of it's contents
	if (isDirectory) {
		NSError * error = nil;
		NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
		if (error) {
			printf("Unable to read contents of directory %s", [path cStringUsingEncoding:NSUTF8StringEncoding]);
			return;
		}
		for (NSString * file in files) {
			file = [path stringByAppendingPathComponent:file];
			parse(file, blacklist, dictionary);
		}
	}
	
	// Parse the file, word by word
	else if ([[path pathExtension] isEqualToString:@"html"] || [[path pathExtension] isEqualToString:@"htm"]) {
		NSData * data = [NSData dataWithContentsOfFile:path];
		NSDictionary * attributes = nil;
		NSAttributedString * attributedString = [[NSAttributedString alloc] initWithHTML:data documentAttributes:&attributes];
		NSString * string = [attributedString string];
		
		CKFileObject * file = [[CKFileObject alloc] init];
		file.title = [attributes objectForKey:NSTitleDocumentAttribute];
		file.path = path;
		
		[string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			substring = [substring lowercaseString];
			NSMutableSet * files = [dictionary objectForKey:substring];
			if (!files && ![blacklist containsObject:substring]) {
				files = [NSMutableSet set];
				[dictionary setObject:files forKey:substring];
			}
			[files addObject:file];
		}];
		
		[file release];
	}
}

NSManagedObjectModel *managedObjectModel(NSString * path) {
    
    static NSManagedObjectModel * model = nil;
    
    if (model)
        return model;
    
	[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
	path = [path stringByAppendingPathComponent:@"HTMLIndexer.mom"];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSData * data = CKHTMLIndexerDataModelData();
		BOOL success = [data writeToFile:path atomically:YES];
		if (!success)
			NSLog(@"ERROR: Unable to write file: %@", data);
	}
	
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    
    return model;
}

NSManagedObjectContext *managedObjectContext(NSString * path) {
	
    static NSManagedObjectContext *context = nil;
    if (context)
        return context;
    
    context = [[NSManagedObjectContext alloc] init];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel([path stringByDeletingLastPathComponent])];
    [context setPersistentStoreCoordinator: coordinator];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        
	NSError * error = nil;
    NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
															configuration:nil
																	  URL:[NSURL fileURLWithPath:path]
																  options:nil
																	error:&error];
    
    if (newStore == nil) {
        NSLog(@"Store Configuration Failure\n%@",
              ([error localizedDescription] != nil) ?
              [error localizedDescription] : @"Unknown Error");
    }
    
    return context;
}

