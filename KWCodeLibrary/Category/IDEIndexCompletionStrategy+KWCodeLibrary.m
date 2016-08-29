//
//  IDEIndexCompletionStategy+KWCodeLibrary.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/14.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "IDEIndexCompletionStrategy+KWCodeLibrary.h"
#import "MethodSwizzle.h"
#import "DVTSourceTextView.h"
#import "DVTTextStorage.h"
#import "IDEWorkspace.h"
#import "IDEEditorDocument.h"
#import "DVTFilePath.h"
#import "DVTTextDocumentLocation.h"
#import "KWCodeLibraryIndexCompletionItem.h"
#import "KWCodeManager.h"

@implementation IDEIndexCompletionStrategy (KWCodeLibrary)

+ (void)load
{
    MethodSwizzle(self,
                  @selector(completionItemsForDocumentLocation:context:highlyLikelyCompletionItems:areDefinitive:),
                  @selector(kevin_completionItemsForDocumentLocation:context:highlyLikelyCompletionItems:areDefinitive:));
}

- (id)kevin_completionItemsForDocumentLocation:(id)arg1 context:(id)arg2 highlyLikelyCompletionItems:(id *)arg3 areDefinitive:(char *)arg4
{
//    DVTSourceTextView* sourceTextView = [arg2 objectForKey:@"DVTTextCompletionContextTextView"];
    DVTTextStorage *textStorage= [arg2 objectForKey:@"DVTTextCompletionContextTextStorage"];
    DVTTextDocumentLocation *location = (DVTTextDocumentLocation *)arg1;
//    IDEWorkspace *workspace = [arg2 objectForKey:@"IDETextCompletionContextWorkspaceKey"];
//    IDEEditorDocument *document = [arg2 objectForKey:@"IDETextCompletionContextDocumentKey"];
//
    NSString *text = [textStorage.string substringWithRange:location.characterRange];
    NSLog(@"value = %@",text);
    NSMutableArray *temp = [self kevin_completionItemsForDocumentLocation:arg1 context:arg2 highlyLikelyCompletionItems:arg3 areDefinitive:arg4];
    if ([KWCodeManager defaultManager].codeEnable) {
        NSArray *addList = [KWCodeManager defaultManager].allModel;
        [temp insertObjects:addList atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addList.count)]];
    }
    return temp;
}

- (NSArray *)genCompletionItems:(DVTSourceTextView *)txtView loc:(DVTTextDocumentLocation *)location workSpace:(IDEWorkspace *)wspace strFilePath:(NSString *)filePath
{
    
//    NSDictionary *itemsDict = [wspace.jsIndex completionItemsInProject];
//    NSInteger loc = location.characterRange.location - 1;
//    if (loc >= 0) {
//        NSString *prevChar = [txtView.textStorage.string substringWithRange:NSMakeRange(loc,1)];
//        if ([prevChar isEqualToString:@"."]) {
//            return itemsDict[@"methods"];
//        }
//    }
//    NSArray *keywordItems = [wspace.jsIndex keywordCompletionItemsWithFilePath:filePath];
//    return [itemsDict[@"keywords"] arrayByAddingObjectsFromArray:keywordItems];
    return nil;
}

@end
