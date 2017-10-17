//
//  NSString+localized.m
//  NavigationControllerDemo
//
//  Created by 朱猛 on 2017/10/16.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "NSString+localized.h"

@implementation NSString(localized)

-(NSString *) localizedString
{
    return NSLocalizedString(self, nil);
}

@end
