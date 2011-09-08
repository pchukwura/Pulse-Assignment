//
//  RootViewController.h
//  TCReader
//
//  Created by Patrick Chukwura on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleViewController.h"

@interface RootViewController : UITableViewController
{
    NSArray *articles;
    NSMutableArray *articleThumbs;
    
    ArticleViewController *articleViewController;
    NSDate *lastRefresh;
}

@property (nonatomic, retain) NSArray *articles;
@property (nonatomic, retain) NSMutableArray *articleThumbs;
@property (nonatomic, retain) NSDate *lastRefresh;

-(void)refreshPage:(id)sender;
-(void)loadFeed;

@end
