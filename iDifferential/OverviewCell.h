//
//  OverviewCell.h
//  iDifferential
//
//  Created by Daniel Fritsch on 22/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverviewCell: UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *upDownLabel;
@property (nonatomic, strong) IBOutlet UILabel *downloadedLabel;
@property (nonatomic, strong) IBOutlet UILabel *peersLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *progressLabel;



@end
