//
//  TableViewScrollCommandTests.m
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 17/02/15.
//  Copyright (c) 2015 Plain Vanilla Games. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PVGTableViewScrollCommand.h"

@interface TableViewScrollCommandTests : XCTestCase

@end

@implementation TableViewScrollCommandTests

- (void)test_is_equal_if_no_unique_ids
{
    PVGTableViewScrollCommand *command1 = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeTop animated:NO uniqueID:nil];
    PVGTableViewScrollCommand *command2 = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeTop animated:NO uniqueID:nil];
    
    XCTAssertEqualObjects(command1, command2);
    XCTAssertEqual([command1 hash], [command2 hash]);
}

- (void)test_is_equal_if_same_unique_ids
{
    PVGTableViewScrollCommand *command1 = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeItem animated:NO uniqueID:@"1"];
    PVGTableViewScrollCommand *command2 = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeItem animated:NO uniqueID:@"1"];
    
    XCTAssertEqualObjects(command1, command2);
    XCTAssertEqual([command1 hash], [command2 hash]);
}

- (void)test_is_not_equal_if_different_animation_flags
{
    PVGTableViewScrollCommand *command1 = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeItem animated:NO uniqueID:@"1"];
    PVGTableViewScrollCommand *command2 = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeItem animated:YES uniqueID:@"1"];
    
    XCTAssertNotEqualObjects(command1, command2);
    XCTAssertNotEqual([command1 hash], [command2 hash]);
}

- (void)test_is_not_equal_if_different_types
{
    PVGTableViewScrollCommand *command1 = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeBottom animated:NO uniqueID:@"1"];
    PVGTableViewScrollCommand *command2 = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeTop animated:YES uniqueID:@"1"];
    
    XCTAssertNotEqualObjects(command1, command2);
    XCTAssertNotEqual([command1 hash], [command2 hash]);
}

- (void)test_is_not_equal_if_different_unique_ids
{
    PVGTableViewScrollCommand *command1 = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeItem animated:NO uniqueID:@"1"];
    PVGTableViewScrollCommand *command2 = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeTop animated:NO uniqueID:@"2"];
    
    XCTAssertNotEqualObjects(command1, command2);
    XCTAssertNotEqual([command1 hash], [command2 hash]);
}

@end
