//
//  RootViewController.m
//  TCReader
//
//  Created by Patrick Chukwura on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#import "HeadlineCell.h"

#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@implementation RootViewController

@synthesize articles, articleThumbs, lastRefresh;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.articles = [NSArray array];
    self.articleThumbs = [NSMutableArray arrayWithCapacity:0];
    
    articleViewController = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Only refresh if last refresh was > 2 minutes ago
    if([self lastRefresh] == nil || [[NSDate date] timeIntervalSinceDate:[self lastRefresh]] > 120){
        [self loadFeed];
        [self setLastRefresh:[NSDate date]];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSArray *visibleCellsIndexPath = [self.tableView indexPathsForVisibleRows];
	
	for(NSIndexPath *indexPath in visibleCellsIndexPath){
		HeadlineCell *cell = (HeadlineCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		cell.headlineLabel.textColor = [UIColor blackColor];
		cell.subtextLabel.textColor = [UIColor grayColor];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.articles count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    HeadlineCell *cell = (HeadlineCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HeadlineCell" owner:nil options:nil];
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass:[HeadlineCell class]])
			{
				cell = (HeadlineCell *)currentObject;
				break;
			}
		}
    }

    NSDictionary *articleDict = [self.articles objectAtIndex:[indexPath indexAtPosition:1]];
    
    cell.headlineLabel.text = [articleDict valueForKey:@"title"];
    cell.thumbnail.image = [articleThumbs objectAtIndex:[indexPath indexAtPosition:1]];
    cell.subtextLabel.text = [NSString stringWithFormat:@"by: %@", [articleDict valueForKey:@"author"]];
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    HeadlineCell *cell = (HeadlineCell *)[tableView cellForRowAtIndexPath:indexPath];
	cell.headlineLabel.textColor = [UIColor whiteColor];
	cell.subtextLabel.textColor = [UIColor whiteColor];
    
    if(articleViewController == nil){
        articleViewController = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:nil];
    }
    
    NSDictionary *articleDict = [self.articles objectAtIndex:[indexPath indexAtPosition:1]];
    articleViewController.title = [articleDict valueForKey:@"title"];
    
    [self.navigationController pushViewController:articleViewController animated:YES];
    [articleViewController.webview loadHTMLString:[articleDict valueForKey:@"content"] baseURL:[NSURL URLWithString:@"http://www.techcrunch.com"]];
    
    /*
     Another option would be to load the URL of the article itself so it displays in a non-feedy way.
     */
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HeadlineCell *cell = (HeadlineCell *)[tableView cellForRowAtIndexPath:indexPath];
	cell.headlineLabel.textColor = [UIColor blackColor];
	cell.subtextLabel.textColor = [UIColor grayColor];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark -
#pragma mark Load Feed
-(void)loadFeed
{
    NSURL *url = [NSURL URLWithString:@"https://ajax.googleapis.com/ajax/services/feed/load?q=http://feeds.feedburner.com/TechCrunch&v=1.0&output=json"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
}


//User manually refreshed
-(void)refreshPage:(id)sender
{
    [self setLastRefresh:[NSDate date]];
    [self loadFeed];
}

#pragma mark - 
#pragma mark ASIHTTPRequest delegate methods
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    JSONDecoder *jsonDecoder = [JSONDecoder decoder];
    NSDictionary *dict = (NSDictionary *)[jsonDecoder objectWithUTF8String:(const unsigned char *)[responseString UTF8String] length:[responseString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    
    self.articles = [[[dict valueForKey:@"responseData"] valueForKey:@"feed"] valueForKey:@"entries"];
    
    //Stash the images for faster scrolling
    for(NSDictionary *articleDict in self.articles){
        
        NSString *imgURL = [[[[[articleDict valueForKey:@"mediaGroups"] objectAtIndex:0] valueForKey:@"contents"] objectAtIndex:0] valueForKey:@"url"];
        UIImage *thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]]];
        [self.articleThumbs addObject:thumbnail];
    }
    
    [self.tableView reloadData];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    
    NSLog(@"Error: %@", error.description);
}

- (void)dealloc
{
    [articleViewController release];
    [articleThumbs release];
    [articles release];
    [super dealloc];
}

@end
