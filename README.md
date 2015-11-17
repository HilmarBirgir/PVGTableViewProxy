# PVGTableViewProxy

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/plain-vanilla-games/PVGTableViewProxy/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/plain-vanilla-games/PVGTableViewProxy.svg)](https://travis-ci.org/plain-vanilla-games/PVGTableViewProxy)
[![pod](https://img.shields.io/cocoapods/v/PVGTableViewProxy.svg)](https://img.shields.io/cocoapods/v/PVGTableViewProxy.svg)

## Overview

`PVGTableViewProxy` is a helper class to set up an `UITableView` where you can declare your data as a simple array of view-model objects and `PVGTableViewProxy` makes sure it gets rendered.

When developing [QuizUp](https://www.quizup.com) we quickly realized that most of the app (and most of all iOS apps) was just a collection of lists. This made us reach for `UITableView` but we immediately felt that it was no fun to use. Its verbose, delegate based API forced a lot of boiler-plate on us every time we needed to use it and being huge fans of [React](https://facebook.github.io/react/) and its declarative, state-less approach to UI we wanted something similar for `UITableView`. Thus `PVGTableViewProxy` was born!

At the moment `PVGTableViewProxy` depends heavily on [Reactive Cocoa](https://github.com/ReactiveCocoa/ReactiveCocoa).

## Installation

`PVGTableViewProxy` is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "PVGTableViewProxy"
```

## Usage

To run the example project, clone the repo and open `PVGTableViewProxy.xcworkspace` and then run the `PVGTableViewProxyExample` target.

## Getting Started

First thing you need to do is create a view controller that has a `UITableView`. Then you create a `PVGTableViewProxy` and pass your table view and data to it:

```objective-c

self.items = @[[DemoCellViewModel new],
               [DemoCellViewModel new]
               [DemoCellViewModel new]];

PVGTableViewProxy *dataSource = [PVGTableViewProxy proxyWithTableView:self.tableView
                                                           dataSource:RACObserve(self, items)
                                                              builder:^(id<PVGTableViewProxyConfig> builder) {
                                                                UINib *nib = [UINib nibWithNibName:@"ExampleNib" bundle:nil];
                                                                [builder registerNib:nib forCellReuseIdentifier:@"exampleNibReuseIdentifier"];
}];
```

In the builder block you register your cell reuse identifiers. `DemoCell` has to fulfill the `PVGTableViewCell` protocol and `DemoCellViewModel` has to fulfill the protocol `PVGTableViewCellViewModel`. Having set this up you can modify `self.items`and your table view will update. To get a better grasp of `PVGTableViewProxy` taking a look at the example project is a good idea.

## Architecture

### PVGTableViewProxy

The class that does the heavy lifting, takes ownership of your table view and your data source as a `RACSignal`. `PVGTableViewProxy` is smart about when it needs to insert, delete and re-render cells.

### PVGTableViewCell

The protocol your table view cells need to fulfill. The `height` method needs to return your cell height as a `NSNumber` and the `setup` method is called in `cellForRowAtIndexPath`.

### PVGTableViewCellViewModel

The protocol your table view cell view models need to fulfill. They have the reuseIdentifier of the cell, the uniqueID which is a unique ID for your model objects (i.e. the data the cell represents) and cacheID which lets `PVGTableViewProxy` know whether the corresponding cell needs to be re-rendered or not.

### PVGTableViewSimpleDataSource

The wrapper around your signal of data.

## Unit Tests

`PVGTableViewProxy` includes a suite of unit tests within the Tests subdirectory. In order to run the unit tests, you must install the testing dependencies via [CocoaPods](http://cocoapods.org/):

    $ cd Tests
    $ pod install

Once testing dependencies are installed you can run the tests on the Tests target. The unit tests run on Travis CI and you can see the build status on the top of this page.

## Authors

Jóhann Þ. Bergþórsson, johann@plainvanillagames.com

Hilmar Birgir Ólafsson, hilmar@plainvanillagames.com

Alexander Annas Helgason, alliannas@plainvanillagames.com

## License

`PVGTableViewProxy` is available under the MIT license. See the LICENSE file for more info.

## More Info

Feel free to open an issue if you find a bug and if you want to contribute please submit a pull request!
