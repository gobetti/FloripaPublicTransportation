//
//  SystemLogAccessor.m
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/24/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

#import "SystemLogAccessor.h"
#import <asl.h>

@implementation SystemLogAccessor

/// Adapted from https://www.cocoanetics.com/2011/03/accessing-the-ios-system-log/
/// Consider using https://github.com/emaloney/CleanroomASL in the future
/// Not optimized (at all)!
+ (NSMutableArray *)NSLogArray {
    NSMutableArray *arrayOfDicts = [[NSMutableArray alloc] init];
    
    aslmsg q, m;
    int i;
    const char *key, *val;
    
    q = asl_new(ASL_TYPE_QUERY);
    asl_set_query(q, ASL_KEY_SENDER, "FloripaPublicTransportation", ASL_QUERY_OP_EQUAL);
    
    aslresponse r = asl_search(NULL, q);
    while (NULL != (m = asl_next(r)))
    {
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
        
        for (i = 0; (key = asl_key(m, i)) != NULL; i++)
        {
            NSString *keyString = [NSString stringWithUTF8String:(char *)key];
            
            val = asl_get(m, key);
            
            NSString *string = val?[NSString stringWithUTF8String:val]:@"";
            [tmpDict setObject:string forKey:keyString];
        }
        
        [arrayOfDicts addObject:tmpDict];
    }
    asl_release(r);
    asl_release(q);
    asl_release(m);
    
    return arrayOfDicts;
}

@end