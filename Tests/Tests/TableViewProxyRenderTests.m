//
//  TableViewProxyRenderTests.m
//  PVGTableViewProxyTests
//
//  Created by Alexander Annas Helgason on 28/10/15.
//
//

#import "TestDependencies.h"

#import "PVGTableViewProxy.h"
#import "PVGTableViewRenderCommand.h"

@interface PVGTableViewProxy (Testing)

@property (readwrite, atomic) NSInteger ongoingScrollAnimations;
@property (readwrite, atomic) PVGTableViewRenderCommand *pendingRenderCommand;

- (void)executeRenderCommand:(PVGTableViewRenderCommand *)renderCommand;

@end

@interface TableViewProxyRenderTests : XCTestCase

@end

@implementation TableViewProxyRenderTests

- (void)test_when_there_are_no_ongoing_scroll_animations_execute_render_will_update_the_table_view
{
    id mockViewModel = OCMProtocolMock(@protocol(PVGTableViewCellViewModel));
    OCMStub([mockViewModel uniqueID]).andReturn(@"uuid");
    
    NSArray *viewModels = @[mockViewModel];
    PVGTableViewSimpleDataSource *dataSource = [PVGTableViewSimpleDataSource dataSourceWithViewModels:[RACSignal return:viewModels]];
    PVGTableViewSection *section = [PVGTableViewSection sectionWithDataSource:dataSource];
    
    id mockTableView = OCMClassMock([UITableView class]);
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:mockTableView
                                                             builder:^(id<PVGTableViewProxyConfig> newProxy) {
                                                                 [newProxy addSection:section atIndex:0];
                                                             }];
    
    id mockAnimator = OCMProtocolMock(@protocol(PVGTableViewProxyAnimator));
    proxy.animator = mockAnimator;
    
    
    PVGTableViewRenderCommand *renderCommand = [PVGTableViewRenderCommand renderCommandForSection:0
                                                                                       viewModels:viewModels];
    
    OCMExpect([mockAnimator animateWithTableView:mockTableView sectionIndex:0 lastData:OCMOCK_ANY newData:OCMOCK_ANY]);

    [proxy executeRenderCommand:renderCommand];
    
    OCMVerifyAll(mockAnimator);
}

- (void)test_when_there_are_ongoing_scroll_animations_then_excecute_render_command_will_store_the_render_command
{
    id mockTableView = OCMClassMock([UITableView class]);
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:mockTableView
                                                             builder:^(id<PVGTableViewProxyConfig> newProxy) {
                                                                 id mockSection = OCMClassMock([PVGTableViewSection class]);
                                                                 [newProxy addSection:mockSection atIndex:0];
                                                             }];
    
    PVGTableViewRenderCommand *renderCommand = [PVGTableViewRenderCommand renderCommandForSection:0
                                                                                       viewModels:@[]];
    
    
    proxy.ongoingScrollAnimations = 1;
    [proxy executeRenderCommand:renderCommand];
    
    XCTAssertEqual(renderCommand, proxy.pendingRenderCommand);
}

- (void)test_when_there_are_ongoing_scroll_animations_then_excecute_render_command_will_not_update_the_table_view
{
    id mockTableView = OCMClassMock([UITableView class]);
    
    PVGTableViewProxy *proxy = [PVGTableViewProxy proxyWithTableView:mockTableView
                                                             builder:^(id<PVGTableViewProxyConfig> newProxy) {
                                                                 id mockSection = OCMClassMock([PVGTableViewSection class]);
                                                                 [newProxy addSection:mockSection atIndex:0];
                                                             }];
    id mockAnimator = OCMProtocolMock(@protocol(PVGTableViewProxyAnimator));
    proxy.animator = mockAnimator;
    
    [[mockAnimator reject] animateWithTableView:mockTableView sectionIndex:0 lastData:OCMOCK_ANY newData:OCMOCK_ANY];

    PVGTableViewRenderCommand *renderCommand = [PVGTableViewRenderCommand renderCommandForSection:0
                                                                                       viewModels:@[]];
    
    
    proxy.ongoingScrollAnimations = 1;
    [proxy executeRenderCommand:renderCommand];
    
    OCMVerifyAll(mockAnimator);
}

@end
