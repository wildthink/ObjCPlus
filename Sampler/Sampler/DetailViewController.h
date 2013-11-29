//
//  DetailViewController.h
//  Sampler
//
//  Created by Jobe,Jason on 11/29/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
