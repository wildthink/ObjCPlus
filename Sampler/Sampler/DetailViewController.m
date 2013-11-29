//
//  DetailViewController.m
//  Sampler
//
//  Created by Jobe,Jason on 11/29/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "DetailViewController.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

/*
 Coroutine context
 self
 _cmd
 _goto_label
 _goto_label_string
 _return_value
 */


//#define BEGIN_COROUTINE() if (_coroutine_resume_point != NULL) goto *_coroutine_resume_point;
//#define END_COROUTINE() (_coroutine_resume_point = NULL)
//#define RETURN_VALUE _coroutine_return_value

#define BEGIN_COROUTINE() \
Coroutine *__crx = [self coroutineForMethod:_cmd]; \
void *__goto_tag = __crx.goto_address; \
if (__goto_tag != NULL) goto *(__goto_tag);

#define END_COROUTINE() (_coroutine = nil)
#define RETURN_VALUE __crx.return_value

#define RESUME(_method, ...) [[self coroutineForMethod:@selector(_method)] setReturn_val=ue:__VA_ARGS__]; [self _method]
#define FOO(...)

#define TOKENPASTE(x, y) x ## y
#define TOKENPASTE2(x, y) TOKENPASTE(x, y)

#define YIELD(...) \
__goto_tag = && TOKENPASTE2(L_, __LINE__); __crx.goto_address = __goto_tag; \
return __VA_ARGS__; \
TOKENPASTE2(L_, __LINE__):

//    __goto_tag = && TOKENPASTE2(L_, __LINE__); __crx.goto_address = __goto_tag; return; TOKENPASTE2(L_, __LINE__): ;

#define YIELD_RETURNING(_return_value) YIELD(); _return_value = RETURN_VALUE




@interface Coroutine : NSObject
@property (nonatomic) char *goto_name;
@property (nonatomic) void *goto_address;

@property (nonatomic)id target;
@property (nonatomic)  SEL method;
@property (nonatomic) id return_value;

@end

@implementation Coroutine

+ (instancetype)coroutineForTarget:target method:(SEL)method;
{
    Coroutine *cr = [[Coroutine alloc] init];
    cr.target = target;
    cr.method = method;
    return cr;
}

- (void)resume {
    SuppressPerformSelectorLeakWarning (
                                        [_target performSelector:_method];
                                        );
}

@end


@interface DetailViewController ()

@property Coroutine *coroutine;
@property void *_coroutine_resume_point;
//    int _coroutine_return_value;

- (void)resume:(SEL)method;
- (IBAction)showAlert:(id)sender;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

- (IBAction)showAlert:(id)sender
{
    [self alert];
}

- (Coroutine*)coroutineForMethod:(SEL)method
{
    if (!self.coroutine) {
        self.coroutine = [Coroutine coroutineForTarget:self method:method];
    }
    return self.coroutine;
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
    [self resumeCoroutineForMethod:@selector(alert) returnValue:@(buttonIndex)];
}

- (void)resume:(SEL)method;
{
    
}

- (void)resumeCoroutineForMethod:(SEL)methodSelector returnValue:value
{
    Coroutine *cr = [self coroutineForMethod:methodSelector];
    cr.return_value = value;
    [cr resume];
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
