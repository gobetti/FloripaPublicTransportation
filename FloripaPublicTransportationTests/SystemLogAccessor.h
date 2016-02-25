//
//  SystemLogAccessor.h
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/24/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

#ifndef SystemLogAccessor_h
#define SystemLogAccessor_h

#import <Foundation/Foundation.h>

@interface SystemLogAccessor : NSObject

/// Returns an array of `NSDictionary`s containing logs generated via `NSLog` by FloripaPublicTransportation
+ (NSMutableArray *)NSLogArray;

@end

#endif /* SystemLogAccessor_h */
