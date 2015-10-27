//
//  TableViewProxyTests.m
//  QuizUp
//
//  Created by Jóhann Þorvaldur Bergþórsson on 25/07/14.
//  Copyright (c) 2014 Plain Vanilla Games. All rights reserved.
//

#import "TestDependencies.h"

#import "PVGTableViewCell.h"
#import "PVGTableViewCellViewModel.h"
#import "PVGTableViewProxy.h"
#import "PVGTableViewSectionHeader.h"


@interface PVGTableViewProxy (Testing)

@property (readwrite, atomic) NSMutableDictionary *templateCells;
@property (readwrite, atomic) NSMutableDictionary *cachedHeights;
@property (readwrite, atomic) UITableView *tableView;
@property (readwrite, atomic) id<UITableViewDelegate> existingDelegate;
@property (readwrite, atomic) NSInteger ongoingScrollAnimations;

- (void)cacheCellHeightsFromData:(NSArray *)data;

- (BOOL)scrollInSection:(NSInteger)sectionIndex
           usingCommand:(PVGTableViewScrollCommand *)command;

@end

@interface TableViewProxyTests : XCTestCase

@property (readwrite, atomic) UITableView *tableView;
@property (readwrite, atomic) id mockTableView;
@property (readwrite, atomic) PVGTableViewProxy *proxy;
@property (readwrite, atomic) id mockProxy;

@end

@implementation TableViewProxyTests

- (void)setUp
{
    [super setUp];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.mockTableView = OCMClassMock([UITableView class]);
    
    self.proxy = [[PVGTableViewProxy alloc] initWithTableView:self.mockTableView];
}


#pragma mark - Builder

- (void)test_sets_self_as_table_view_data_source_when_using_builder
{
    id mockTableView = OCMClassMock([UITableView class]);
    
    OCMExpect([mockTableView setDataSource:[OCMArg isKindOfClass:[PVGTableViewProxy class]]]);
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:mockTableView dataSource:nil builder:^(id<PVGTableViewProxyConfig> newProxy) {}];
    
    XCTAssertNotNil(proxy);
    
    OCMVerifyAll(mockTableView);
}

- (void)test_sets_self_as_table_view_delegate_when_using_builder
{
    id mockTableView = OCMClassMock([UITableView class]);
    
    OCMExpect([mockTableView setDelegate:[OCMArg isKindOfClass:[PVGTableViewProxy class]]]);
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:mockTableView dataSource:nil builder:^(id<PVGTableViewProxyConfig> newProxy) {}];
    
    XCTAssertNotNil(proxy);
    
    OCMVerifyAll(mockTableView);
}

- (void)test_subscribes_to_signal_when_using_builder_and_delivers_on_main_thread
{
    id mockSignal = OCMClassMock([RACSignal class]);
    OCMExpect([mockSignal ignore:nil]).andReturn(mockSignal);
    OCMExpect([mockSignal deliverOn:OCMOCK_ANY]).andReturn(mockSignal);
    OCMExpect([mockSignal subscribeNext:OCMOCK_ANY]);
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:nil
                                                          dataSource:mockSignal
                                                             builder:^(id<PVGTableViewProxyConfig> newProxy) {}];
    
    XCTAssertNotNil(proxy);
    
    OCMVerifyAll(mockSignal);
}

#pragma mark - Registering Nibs

- (void)test_register_nib_register_nibs_on_table_view
{
    id mockNib = OCMClassMock([UINib class]);
    
    OCMExpect([self.mockTableView registerNib:mockNib forCellReuseIdentifier:@"id"]);
    
    [self.proxy registerNib:mockNib forCellReuseIdentifier:@"id"];
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_instantiates_nib_and_stores_as_template_cell
{
    id mockNib = OCMClassMock([UINib class]);
    
    OCMExpect([self.mockTableView dequeueReusableCellWithIdentifier:@"id"]);
    
    [self.proxy registerNib:mockNib forCellReuseIdentifier:@"id"];
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_did_select_for_at_index_path_calls_did_select_on_view_model
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"didSelect"];
    id mockViewModel = OCMClassMock([MockPVGTableViewCellViewModelDidSelect class]);
    OCMStub([mockViewModel uniqueID]).andReturn(@"id");
    
    RACSubject *dataSource = [RACSubject subject];
    
    id mockTableView = OCMClassMock([UITableView class]);
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:self.mockTableView
                                                          dataSource:dataSource
                                                             builder:^(id<PVGTableViewProxyConfig> newProxy) {}];
    
    proxy.tableView = mockTableView;
    
    @weakify(self)
    [proxy.didReload subscribeNext:^(id x) {
        @strongify(self)
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0] ;
        [proxy tableView:mockTableView didSelectRowAtIndexPath:indexPath];
        
        OCMVerify([mockViewModel didSelect]);
        
        [expectation fulfill];
    }];
    
    [dataSource sendNext:@[mockViewModel]];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)test_did_select_for_at_index_path_calls_did_select_with_source_view_on_view_model
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"didSelectWithView"];
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    RACSubject *dataSource = [RACSubject subject];
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:self.mockTableView
                                                          dataSource:dataSource
                                                             builder:^(id<PVGTableViewProxyConfig> newProxy) {}];
    
    OCMExpect([mockViewModel didSelectWithView:OCMOCK_ANY]);
    
    @weakify(self)
    [proxy.didReload subscribeNext:^(id x) {
        @strongify(self)
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0] ;
        [proxy tableView:self.mockTableView didSelectRowAtIndexPath:indexPath];
        
        OCMVerifyAll(mockViewModel);
        
        [expectation fulfill];
    }];
    
    [dataSource sendNext:@[mockViewModel]];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

#pragma mark - UITableViewDataSource

- (void)test_returns_correct_number_of_rows_when_no_data_item
{
    XCTAssertEqual([self.proxy tableView:self.mockTableView numberOfRowsInSection:0], 0);
}

- (void)test_returns_correct_number_of_rows_when_1_section_with_data_item
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    section.loadedData = @[mockViewModel];
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:self.mockTableView
                                                          dataSource:nil
                                                             builder:^(id<PVGTableViewProxyConfig> newProxy) {}];
    [proxy addSection:section atIndex:0];
    
    XCTAssertEqual([proxy tableView:self.mockTableView numberOfRowsInSection:0], 1);
}

- (void)test_cell_setups_when_cell_for_row_at_index_path_is_invoked
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"cellSetup"];
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel reuseIdentifier]).andReturn(@"reuseIdentifer");
    OCMStub([mockViewModel uniqueID]).andReturn(@"id");
    
    id mockCell = OCMClassMock([MockPVGTableViewCell class]);
    OCMStub([self.mockTableView dequeueReusableCellWithIdentifier:@"reuseIdentifer"]).andReturn(mockCell);
    
    RACSubject *dataSource = [RACSubject subject];
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:self.mockTableView
                                                          dataSource:dataSource
                                                             builder:^(id<PVGTableViewProxyConfig> newProxy) {}];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    @weakify(self)
    [proxy.didReload subscribeNext:^(id x) {
        @strongify(self)
        [proxy tableView:self.mockTableView cellForRowAtIndexPath:indexPath];
        
        OCMVerify([mockCell setup]);
        
        [expectation fulfill];
    }];
    
    [dataSource sendNext:@[mockViewModel]];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

#pragma mark - Sections

- (void)test_proxy_returns_zero_when_no_sections
{
    XCTAssertEqual([self.proxy numberOfSectionsInTableView:self.mockTableView], 0);
}

- (void)test_proxy_returns_correct_number_of_sections
{
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:self.mockTableView
                                                             builder:^(id<PVGTableViewProxyConfig> newProxy) {
                                                                 [newProxy addSection:[PVGTableViewSection sectionWithDataSource:nil] atIndex:0];
                                                             }];
    
    XCTAssertEqual([proxy numberOfSectionsInTableView:self.mockTableView], 1);
}

- (void)test_proxy_returns_correct_title_for_section_if_applicable
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:self.mockTableView
                                                             builder:^(id<PVGTableViewProxyConfig> newProxy) {
                                                                 [newProxy addSection:section atIndex:0];
                                                             }];
    
    XCTAssertEqualObjects([proxy tableView:self.mockTableView titleForHeaderInSection:0], @"HEADER");
}

- (void)test_proxy_sets_view_model_on_view_when_returning_header_view
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1" title:@"HEADER" dataSource:nil];
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:self.mockTableView
                                                             builder:^(id<PVGTableViewProxyConfig> newProxy) {
                                                                 [newProxy addSection:section atIndex:0];
                                                             }];
    
    id mockHeaderView = OCMProtocolMock(@protocol(PVGTableViewSectionHeader));
    
    OCMStub([self.mockTableView dequeueReusableHeaderFooterViewWithIdentifier:@"1"]).andReturn(mockHeaderView);
    
    OCMExpect([(id<PVGTableViewSectionHeader>)mockHeaderView setViewModel:section.sectionHeaderViewModel]);
    
    UIView *view = [proxy tableView:self.mockTableView viewForHeaderInSection:0];
    XCTAssertEqualObjects(view, mockHeaderView);
    
    OCMVerifyAll(mockHeaderView);
}

#pragma mark - Headers

- (void)test_register_nib_for_header_register_nibs_on_table_view
{
    id mockNib = OCMClassMock([UINib class]);
    
    OCMExpect([self.mockTableView registerNib:mockNib forHeaderFooterViewReuseIdentifier:@"id"]);
    
    [self.proxy registerNib:mockNib forHeaderReuseIdentifier:@"id"];
    
    OCMVerifyAll(mockNib);
}

#pragma mark - Scrolling

- (void)test_scroll_in_section_scrolls_to_top
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    section.loadedData = @[mockViewModel];
    
    [self.proxy addSection:section atIndex:0];
    
    PVGTableViewScrollCommand *command = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeTop
                                                                           animated:NO
                                                                           uniqueID:[mockViewModel uniqueID]];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                inSection:0];
    
    OCMExpect([self.mockTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:command.animated]);
    
    XCTAssertEqual([self.proxy scrollInSection:0 usingCommand:command], YES);
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_scroll_in_section_scrolls_to_bottom
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    section.loadedData = @[mockViewModel];
    
    [self.proxy addSection:section atIndex:0];
    
    PVGTableViewScrollCommand *command = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeBottom
                                                                           animated:NO
                                                                           uniqueID:nil];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:section.loadedData.count - 1
                                                inSection:0];
    
    OCMExpect([self.mockTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:command.animated]);
    
    XCTAssertEqual([self.proxy scrollInSection:0 usingCommand:command], YES);
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_scroll_in_section_scrolls_to_item
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    id mockViewModel2 = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel2 uniqueID]).andReturn(@"uuid2");
    
    section.loadedData = @[mockViewModel, mockViewModel2];
    
    [self.proxy addSection:section atIndex:0];
    
    PVGTableViewScrollCommand *command = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeItem
                                                                           animated:NO
                                                                           uniqueID:[mockViewModel uniqueID]];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                inSection:0];
    
    OCMExpect([self.mockTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:command.animated]);
    
    XCTAssertEqual([self.proxy scrollInSection:0 usingCommand:command], YES);
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_scroll_in_section_succeeds_if_passed_nil_command
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    id mockViewModel2 = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel2 uniqueID]).andReturn(@"uuid2");
    
    section.loadedData = @[mockViewModel, mockViewModel2];
    
    [self.proxy addSection:section atIndex:0];
    
    [[[self.mockTableView reject] ignoringNonObjectArgs] scrollToRowAtIndexPath:OCMOCK_ANY atScrollPosition:0 animated:NO];
    
    XCTAssertEqual([self.proxy scrollInSection:0 usingCommand:nil], YES);
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_scroll_to_top_handles_empty_array
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    section.loadedData = @[];
    
    [self.proxy addSection:section atIndex:0];
    
    PVGTableViewScrollCommand *command = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeTop
                                                                           animated:NO
                                                                           uniqueID:nil];
    
    self.proxy.tableView = self.tableView;
    
    [self.proxy scrollInSection:0 usingCommand:command];
}

- (void)test_scroll_to_bottom_handles_empty_array
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    section.loadedData = @[];
    
    [self.proxy addSection:section atIndex:0];
    
    PVGTableViewScrollCommand *command = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeBottom
                                                                           animated:NO
                                                                           uniqueID:nil];
    
    self.proxy.tableView = self.tableView;
    
    [self.proxy scrollInSection:0 usingCommand:command];
}

- (void)test_scroll_in_section_handles_empty_array
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    section.loadedData = @[];
    
    [self.proxy addSection:section atIndex:0];
    
    PVGTableViewScrollCommand *command = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeItem
                                                                           animated:NO
                                                                           uniqueID:@"1"];
    
    
    [[self.mockTableView reject] scrollToRowAtIndexPath:OCMOCK_ANY atScrollPosition:UITableViewScrollPositionMiddle animated:command.animated];
    
    XCTAssertEqual([self.proxy scrollInSection:0 usingCommand:command], NO);
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_scroll_in_section_handles_too_big_of_an_section_index_boundary_check
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    id mockViewModel2 = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel2 uniqueID]).andReturn(@"uuid2");
    
    section.loadedData = @[mockViewModel, mockViewModel2];
    
    PVGTableViewScrollCommand *command = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeItem
                                                                           animated:NO
                                                                           uniqueID:[mockViewModel uniqueID]];
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1
                                                inSection:7];
    
    [[self.mockTableView reject] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:command.animated];
    
    XCTAssertEqual([self.proxy scrollInSection:1 usingCommand:command], NO);
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_scroll_in_section_handles_too_big_of_an_section_index
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    id mockViewModel2 = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel2 uniqueID]).andReturn(@"uuid2");
    
    section.loadedData = @[mockViewModel, mockViewModel2];
    [self.proxy addSection:section atIndex:0];
    
    PVGTableViewScrollCommand *command = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeItem
                                                                           animated:NO
                                                                           uniqueID:[mockViewModel uniqueID]];
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:666
                                                inSection:7];
    
    [[self.mockTableView reject] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:command.animated];
    
    XCTAssertEqual([self.proxy scrollInSection:666 usingCommand:command], NO);
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_scroll_in_section_handles_a_negative_index
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    id mockViewModel2 = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel2 uniqueID]).andReturn(@"uuid2");
    
    section.loadedData = @[mockViewModel, mockViewModel2];
    [self.proxy addSection:section atIndex:0];
    
    PVGTableViewScrollCommand *command = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeItem
                                                                           animated:NO
                                                                           uniqueID:[mockViewModel uniqueID]];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:-1
                                                inSection:7];
    
    [[self.mockTableView reject] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:command.animated];
    
    XCTAssertEqual([self.proxy scrollInSection:-1 usingCommand:command], NO);
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_scrolling_to_another_animation_while_there_is_an_animation_ongoing_queues_the_latter_animation
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    id mockViewModel2 = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel2 uniqueID]).andReturn(@"uuid2");
    
    section.loadedData = @[mockViewModel, mockViewModel2];
    
    [self.proxy addSection:section atIndex:0];
    
    PVGTableViewScrollCommand *firstCommand = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeBottom
                                                                                animated:YES
                                                                                uniqueID:nil];
    
    OCMExpect([self.mockTableView contentOffset]);
    
    XCTAssertTrue([self.proxy scrollInSection:0 usingCommand:firstCommand]);
    
    
    PVGTableViewScrollCommand *secondCommand = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeTop
                                                                                 animated:YES
                                                                                 uniqueID:nil];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                inSection:0];
    
    [[self.mockTableView reject] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    XCTAssertTrue([self.proxy scrollInSection:0 usingCommand:secondCommand]);
    
    OCMVerifyAll(self.mockTableView);
}

- (void)test_queued_scroll_animation_is_executed_when_the_first_one_completes
{
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    id mockViewModel2 = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel2 uniqueID]).andReturn(@"uuid2");
    
    section.loadedData = @[mockViewModel, mockViewModel2];
    
    
    [self.proxy addSection:section atIndex:0];
    
    PVGTableViewScrollCommand *firstCommand = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeBottom
                                                                                animated:YES
                                                                                uniqueID:nil];
    
    [[[self.mockTableView expect] andReturnValue:[NSValue valueWithCGPoint:CGPointMake(0, 0)]] contentOffset];
    [[[self.mockTableView expect] andReturnValue:[NSValue valueWithCGPoint:CGPointMake(0, 30)]] contentOffset];
    
    XCTAssertTrue([self.proxy scrollInSection:0 usingCommand:firstCommand]);
    
    
    PVGTableViewScrollCommand *secondCommand = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeTop
                                                                                 animated:YES
                                                                                 uniqueID:nil];
    
    XCTAssertTrue([self.proxy scrollInSection:0 usingCommand:secondCommand]);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                inSection:0];
    
    [[self.mockTableView expect] scrollToRowAtIndexPath:indexPath
                                       atScrollPosition:UITableViewScrollPositionTop
                                               animated:YES];
    
    [[[self.mockTableView expect] andReturnValue:[NSValue valueWithCGPoint:CGPointMake(0, 30)]] contentOffset];
    [[[self.mockTableView expect] andReturnValue:[NSValue valueWithCGPoint:CGPointMake(0, 0)]] contentOffset];
    
    [self.proxy scrollViewDidEndScrollingAnimation:self.proxy.tableView];
    
    [self.mockTableView verify];
}

- (void)test_queues_render_commands_if_there_is_an_ongoing_scroll_command
{
    RACSubject *dataSource = [RACSubject subject];
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:self.mockTableView
                                                          dataSource:dataSource
                                                             builder:^(id<PVGTableViewProxyConfig> newProxy) {}];
    
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    id mockViewModel2 = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel2 uniqueID]).andReturn(@"uuid2");
    
    section.loadedData = @[mockViewModel, mockViewModel2];;
    
    [proxy addSection:section atIndex:0];
    
    PVGTableViewScrollCommand *firstCommand = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeBottom
                                                                                animated:YES
                                                                                uniqueID:nil];
    
    XCTAssertTrue([proxy scrollInSection:0 usingCommand:firstCommand]);
    
    @weakify(self)
    [proxy.didReload subscribeNext:^(id x) {
        @strongify(self)
        XCTFail(@"Shouldnt call subscribeNext for proxy");
    }];
    
    [dataSource sendNext:@[OCMProtocolMock(@protocol(PVGTableViewCellViewModel))]];
}

- (void)test_queues_render_commands_and_executes_as_soon_as_scroll_command_completes
{
    XCTestExpectation *expectations = [self expectationWithDescription:@"renderCommandsAndExecutes"];
    RACSubject *dataSource = [RACSubject subject];
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:self.mockTableView
                                                          dataSource:dataSource
                                                             builder:^(id<PVGTableViewProxyConfig> newProxy) {}];
    
    PVGTableViewSection *section = [PVGTableViewSection sectionWithReuseIdentifier:@"1"
                                                                             title:@"HEADER"
                                                                        dataSource:nil];
    
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    id mockViewModel2 = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel2 uniqueID]).andReturn(@"uuid2");
    
    section.loadedData = @[mockViewModel, mockViewModel2];;
    
    [proxy addSection:section atIndex:0];
    
    PVGTableViewScrollCommand *firstCommand = [PVGTableViewScrollCommand commandWithType:ScrollCommandTypeBottom
                                                                                animated:YES
                                                                                uniqueID:nil];
    
    XCTAssertTrue([proxy scrollInSection:0 usingCommand:firstCommand]);
    
    [dataSource sendNext:@[mockViewModel]];
    
    @weakify(self)
    [proxy.didReload subscribeNext:^(id x) {
        @strongify(self)
        XCTAssertEqual([proxy tableView:self.mockTableView numberOfRowsInSection:0], 1);
        
        [expectations fulfill];
    }];
    
    [proxy scrollViewDidEndScrollingAnimation:proxy.tableView];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

#pragma mark - Forwarding Delegate methods

- (void)test_responds_to_selector_invokes_existing_delegate_if_proxy_does_not_implement_the_selector
{
    id mockExistingDelegate = OCMProtocolMock(@protocol(UITableViewDelegate));
    
    self.proxy.existingDelegate = mockExistingDelegate;
    
    OCMExpect([mockExistingDelegate scrollViewDidScroll:self.mockTableView]);
    
    [self.proxy scrollViewDidScroll:self.mockTableView];
    
    OCMVerifyAll(mockExistingDelegate);
}

- (void)test_responds_to_selector_invokes_existing_delegate_and_proxy_if_proxy_does_implement_the_selector
{
    self.proxy.ongoingScrollAnimations = 10; // We assert that our implementation of the selector by asserting that this number gets decremented.
    
    id mockExistingDelegate = OCMProtocolMock(@protocol(UITableViewDelegate));
    
    self.proxy.existingDelegate = mockExistingDelegate;
    
    OCMExpect([mockExistingDelegate scrollViewDidEndScrollingAnimation:self.mockTableView]);
    
    [self.proxy scrollViewDidEndScrollingAnimation:self.mockTableView];
    
    OCMVerifyAll(mockExistingDelegate);
    XCTAssertEqual(self.proxy.ongoingScrollAnimations, 9);
}

@end
