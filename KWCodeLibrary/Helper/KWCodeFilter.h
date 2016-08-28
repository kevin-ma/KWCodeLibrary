//
//  KWCodeFilter.h
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/25.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWCodeFilter : NSObject

- (void)configProperties:(NSArray *)properties;

- (NSArray *)filterResultWithExpress:(NSString *)express withSource:(NSArray *)source;
@end
