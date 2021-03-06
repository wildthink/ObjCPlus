//
//  DetailViewController.m
//  Sampler
//
//  Created by Jobe,Jason on 11/29/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "DetailViewController.h"
#import "Coroutine.h"


@interface DetailViewController ()

- (IBAction)showAlert:(id)sender;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;

@end

@implementation DetailViewController

- (IBAction)showAlert:(id)sender
{
    [self alert];
}

-(void)alert
{
    id result;
    BEGIN_COROUTINE();
    
    [[[UIAlertView alloc] initWithTitle:@"Alert One"
                                message:@"This is a message"
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"OK", nil]
     show];
    
    YIELD();
    result = RETURN_VALUE;
    
    NSLog(@"Alert returns %@", result);
    
    [[[UIAlertView alloc] initWithTitle:@"Alert Two"
                                message:@"This is a message"
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"OK", nil]
     show];
    
    YIELD();
    result = RETURN_VALUE;
    
    NSLog(@"Alert returns %@", result);
    
    END_COROUTINE();
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self resumeCoroutineForMethod:@selector(alert) withValue:@(buttonIndex)];
}

#pragma mark - Managing the detail item


- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
