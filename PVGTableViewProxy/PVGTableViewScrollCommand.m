//
//  PVGTableViewScrollCommand.h.m
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 17/02/15.
//  Copyright (c) 2015 Plain Vanilla Games. All rights reserved.
//

#import "PVGTableViewScrollCommand.h"

@interface PVGTableViewScrollCommand ()

@property (readwrite, nonatomic) ScrollCommandType type;
@property (readwrite, nonatomic, copy) NSString *uniqueID;
@property (readwrite, nonatomic) BOOL animated;

@end

@implementation PVGTableViewScrollCommand

+ (instancetype)commandWithType:(ScrollCommandType)type animated:(BOOL)animated uniqueID:(NSString *)uniqueID
{
    PVGTableViewScrollCommand *command = [[self class] new];
    command.type = type;
    command.animated = animated;
    command.uniqueID = uniqueID;
    return command;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[PVGTableViewScrollCommand class]])
    {
        PVGTableViewScrollCommand *otherCommand = (PVGTableViewScrollCommand *)object;
        BOOL sameCore = otherCommand.type == self.type && otherCommand.animated == self.animated;
        if (otherCommand.uniqueID == nil && self.uniqueID == nil)
        {
            return sameCore;
        }
        else if (otherCommand.uniqueID != nil && self.uniqueID != nil)
        {
            return sameCore && [otherCommand.uniqueID isEqualToString:self.uniqueID];
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)hash
{
    NSUInteger shiftedType = 2 * self.type;
    return self.animated ^ shiftedType ^ [self.uniqueID hash];
}

@end
