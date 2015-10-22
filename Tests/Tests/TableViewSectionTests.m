//
//  TableViewSectionTests.m
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 08/10/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "PVGTableViewSection.h"

@interface TableViewSectionTests : XCTestCase

@end

@implementation TableViewSectionTests

- (void)test_calls_load_more_data_on_data_source_if_has_loaded_some_data
{
    id mockDataSource = [OCMockObject niceMockForProtocol:@protocol(PVGTableViewDataSource)];
    
    PVGTableViewSection *section = [PVGTableViewSection sectionWithDataSource:mockDataSource];
    section.loadedData = @[];
    
    [[mockDataSource expect] loadMoreDataWithCurrentData:@[]];
    
    [section loadMoreData];
    
    [mockDataSource verify];
}

- (void)test_doesnt_call_load_more_data_on_data_source_if_has_not_loaded_some_data
{
    id mockDataSource = [OCMockObject niceMockForProtocol:@protocol(PVGTableViewDataSource)];
    
    PVGTableViewSection *section = [PVGTableViewSection sectionWithDataSource:mockDataSource];
    section.loadedData = nil;
    
    [[mockDataSource reject] loadMoreDataWithCurrentData:OCMOCK_ANY];
    
    [section loadMoreData];
    
    [mockDataSource verify];
}

@end
