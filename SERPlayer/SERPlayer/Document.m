//
//  Document.m
//  SERPlayer2
//
//  Created by Chris Warren on 21/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Document.h"

@implementation Document

@synthesize video = _video;

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, return nil.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    self.windowForSheet.contentView = _video.view;
    [self.windowForSheet makeKeyAndOrderFront:_video.view];

}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    /*
     Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    */
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)isEntireFileLoaded {
    return NO;
}
- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    self.video = [[VideoViewController alloc] initWithNibName:@"VideoViewController" bundle:nil];
    return [self.video loadVideo:[self fileName]];
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

@end
