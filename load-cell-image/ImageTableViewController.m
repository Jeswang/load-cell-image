//
//  ImageTableViewController.m
//  load-cell-image
//
//  Created by jeswang on 14/12/30.
//  Copyright (c) 2014年 rainy. All rights reserved.
//

#import "ImageTableViewController.h"
#import "DTAttributedTextCell.h"
#import "NSAttributedString+HTML.h"
#import "DTImageTextAttachment.h"
#import "UIImageView+WebCache.h"

@interface ImageTableViewController () {
    NSCache *_cellCache;
    NSCache *_imageSizeCache;
}

@property (nonatomic, strong) NSMutableArray *models;

@end

@implementation ImageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.models = [NSMutableArray new];
    for (int i=0; i<100; i++) {
        NSString *string = [NSString stringWithFormat:@"<h1>Hello %d</h1><h1>Hello</h1><img  src=\"http://cdn.computerhope.com/computer-hope.jpg\">", i];
        [self.models addObject:string];
    }
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    _cellCache = [[NSCache alloc] init];
    _imageSizeCache = [[NSCache alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DTAttributedTextCell *cell = [self tableView:tableView preparedCellForIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    DTAttributedTextCell *cell = [self tableView:tableView preparedCellForIndexPath:indexPath];
    return [cell requiredRowHeightInTableView:tableView];
}

- (DTAttributedTextCell *)tableView:(UITableView *)tableView preparedCellForIndexPath:(NSIndexPath *)indexPath {
    NSString *cacheKey = [NSString stringWithFormat:@"attributed_text_cell_pid_%ld", (long)indexPath.row];
    DTAttributedTextCell *cell = [_cellCache objectForKey:cacheKey];
    
    if (!cell) {
        cell = [[DTAttributedTextCell alloc] initWithReuseIdentifier:@"CoreTextCell"];
        [cell setTextDelegate: self];
        cell.attributedTextContextView.shouldDrawImages = YES;
        [_cellCache setObject:cell forKey:cacheKey];
    }
    
    [cell setHTMLString:[self.models objectAtIndex:indexPath.row]];
    

    for (DTTextAttachment *oneAttachment in cell.attributedTextContextView.layoutFrame.textAttachments) {
        NSValue *sizeValue = [_imageSizeCache objectForKey:oneAttachment.contentURL];
        if (sizeValue) {
            cell.attributedTextContextView.layouter=nil;
            oneAttachment.displaySize = [sizeValue CGSizeValue];
        }
    }
    
    [cell.attributedTextContextView relayoutText];

    return cell;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame {
    if ([attachment isKindOfClass:[DTImageTextAttachment class]]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        [imageView sd_setImageWithURL:attachment.contentURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [_imageSizeCache setObject:[NSValue valueWithCGSize:[image size]] forKey:imageURL];
            [self.tableView reloadData];
        }];
        return imageView;
    }
    return nil;
}

@end
