//
//  ViewController.m
//  AKInteractiveBarProxy
//
//  Created by Ono Masashi on 2014/09/25.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

#import "AKInteractiveBarProxy.h"
#import "ViewController.h"

@interface ViewController () <UIWebViewDelegate, AKInteractiveBarProxyDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeight;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeight;

@property (nonatomic) AKInteractiveBarProxy *interactiveBarProxy;
@property (nonatomic) CGFloat headerViewHeightExtendedValue;
@property (nonatomic) CGFloat headerViewHeightRetractedValue;
@property (nonatomic) CGFloat toolbarHeightExtendedValue;
@property (nonatomic) CGFloat toolbarHeightRetractedValue;
@property (nonatomic) BOOL interactiveHeaderAnimationDisabled;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headerViewHeightExtendedValue = self.headerViewHeight.constant;
    self.headerViewHeightRetractedValue = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.toolbarHeightExtendedValue = self.toolbarHeight.constant;
    self.toolbarHeightRetractedValue = 0;
    
    self.webView.delegate = self;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(self.headerViewHeightExtendedValue, 0, 0, 0);
    self.interactiveBarProxy = [[AKInteractiveBarProxy alloc] initWithScrollView:self.webView.scrollView delegate:self];
    self.interactiveBarProxy.interactionTranslation = self.headerViewHeightExtendedValue - self.headerViewHeightRetractedValue;
    
    self.headerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.headerView.layer.shadowRadius = 2.0;
    self.headerView.layer.shadowOffset = CGSizeMake(0, 1.0);
    self.headerView.layer.shadowOpacity = 0.5;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://akisute.com"]];
    [self.webView loadRequest:request];
}

- (IBAction)onRefreshButton:(id)sender
{
    [self.webView reload];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.headerTitleLabel.text = self.webView.request.URL.absoluteString;
}

#pragma mark - AKInteractiveBarProxyDelegate

- (void)proxy:(AKInteractiveBarProxy *)proxy receivedInteractiveGestureWithProgress:(CGFloat)progress
{
    [self interactivelyAnimateBar:progress];
}

- (void)proxy:(AKInteractiveBarProxy *)proxy receivedNonInteractiveActionWithBarHidden:(BOOL)hidden
{
    [self setBarHidden:hidden animated:YES];
}

#pragma mark - Private

- (void)interactivelyAnimateBar:(CGFloat)progress
{
    if (self.interactiveHeaderAnimationDisabled) {
        return;
    }
    
    // progress 0.0 = hidden
    // progress 1.0 = visible
    self.headerTitleLabel.alpha = progress;
    self.headerViewHeight.constant = progress * (self.headerViewHeightExtendedValue - self.headerViewHeightRetractedValue) + self.headerViewHeightRetractedValue;
    self.toolbar.alpha = progress;
    self.toolbarHeight.constant = progress * (self.toolbarHeightExtendedValue - self.toolbarHeightRetractedValue) + self.toolbarHeightRetractedValue;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)setBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (hidden) {
        
        void (^block)() = ^{
            self.headerTitleLabel.alpha = 0;
            self.headerViewHeight.constant = self.headerViewHeightRetractedValue;
            self.toolbar.alpha = 0;
            self.toolbarHeight.constant = self.toolbarHeightRetractedValue;
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
        };
        if (animated) {
            self.interactiveHeaderAnimationDisabled = YES;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:block completion:^(BOOL finished) {
                self.interactiveHeaderAnimationDisabled = NO;
            }];
        } else {
            block();
            self.interactiveHeaderAnimationDisabled = NO;
        }
    } else {
        
        void (^block)() = ^{
            self.headerTitleLabel.alpha = 1;
            self.headerViewHeight.constant = self.headerViewHeightExtendedValue;
            self.toolbar.alpha = 1;
            self.toolbarHeight.constant = self.toolbarHeightExtendedValue;
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
        };
        if (animated) {
            self.interactiveHeaderAnimationDisabled = YES;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:block completion:^(BOOL finished) {
                self.interactiveHeaderAnimationDisabled = NO;
            }];
        } else {
            block();
            self.interactiveHeaderAnimationDisabled = NO;
        }
    }
}

@end
