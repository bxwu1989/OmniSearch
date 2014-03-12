//
//  SearchProviderTableViewController.h
//  OrderedTableViewDemo
//
//  Created by James Wu on 3/9/14.
//  Copyright (c) 2014 James Wu. All rights reserved.
//

#import "Preferences/PSViewController.h"

@interface SearchProviderTableViewController : PSViewController <UITableViewDataSource, UITableViewDelegate>

- (UITableView *)tableView;

@end
