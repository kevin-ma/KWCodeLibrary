//
//  KWCodeFilter.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/25.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWCodeFilter.h"

@interface KWCodeFilter ()

@property (nonatomic, strong) NSArray *properties;

@end

@implementation KWCodeFilter

- (void)configProperties:(NSArray *)properties
{
    self.properties = properties;
}

- (NSArray *)filterResultWithExpress:(NSString *)express withSource:(NSArray *)source
{
    if (!self.properties || !express || express.length == 0) return source;
    
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSString *property in _properties) {
        NSString *like = [NSString stringWithFormat:@"*%@*",express];
        NSPredicate *p = [NSPredicate predicateWithFormat:@"%K LIKE %@",property,like];
        [temp addObject:p];
    }
    if (temp.count == 0) {
        return source;
    }
    NSCompoundPredicate *cp = [NSCompoundPredicate orPredicateWithSubpredicates:temp];
    NSArray *result = [source filteredArrayUsingPredicate:cp];
    return result;
}


@end
