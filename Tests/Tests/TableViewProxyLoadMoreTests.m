//
//  TableViewProxyLoadMoreTests.m
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 08/10/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import "TestDependencies.h"

#import "PVGTableViewCell.h"
#import "PVGTableViewCellViewModel.h"
#import "PVGTableViewProxy.h"


@interface TableViewProxyLoadMoreTests : XCTestCase

@property (readwrite, atomic) id mockTableView;

@property (readwrite, atomic) id mockDataSource;
@property (readwrite, atomic) id mockSection;

@end

@implementation TableViewProxyLoadMoreTests

- (void)setUp
{
    [super setUp];
    
    self.mockTableView = OCMClassMock([UITableView class]);
    self.mockDataSource = OCMProtocolMock(@protocol(PVGTableViewDataSource));
    
    self.mockSection = OCMClassMock([PVGTableViewSection class]);
    OCMStub([self.mockSection dataSource]).andReturn(self.mockDataSource);
}

- (void)test_doesnt_call_load_more_data_when_not_scrolled_to_end
{
    NSMutableArray *data = [NSMutableArray array];
    for (NSInteger i = 0; i != 30; ++i)
    {
        id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
        [data addObject:mockViewModel];
    }
    
    OCMStub([self.mockSection loadedData]).andReturn(data);
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:self.mockTableView
                                                       builder:^(id<PVGTableViewProxyConfig> builder) {
                                                           [builder addSection:self.mockSection atIndex:0];
                                                       }];
    
    id mockCell = OCMClassMock([UITableViewCell class]);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];

    [[self.mockSection reject] loadMoreData];

    [proxy tableView:self.mockTableView willDisplayCell:mockCell forRowAtIndexPath:indexPath];
    
    [self.mockSection verify];
}

- (void)test_calls_load_more_data_when_almost_scrolled_to_end
{
    NSMutableArray *data = [NSMutableArray array];
    for (NSInteger i = 0; i != 10; ++i)
    {
        id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
        [data addObject:mockViewModel];
    }
    
    OCMStub([self.mockSection loadedData]).andReturn(data);
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:self.mockTableView
                                                       builder:^(id<PVGTableViewProxyConfig> builder) {
                                                           [builder addSection:self.mockSection atIndex:0];
                                                       }];
    
    id mockCell = OCMClassMock([UITableViewCell class]);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
    
    [proxy tableView:self.mockTableView willDisplayCell:mockCell forRowAtIndexPath:indexPath];
    
    OCMVerify([self.mockSection loadMoreData]);
}

@end
