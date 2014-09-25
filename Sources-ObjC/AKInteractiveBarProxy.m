//
//  AKInteractiveBarProxy.m
//  AKInteractiveBarProxy
//
//  Created by Ono Masashi on 2014/09/25.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

#import "AKInteractiveBarProxy.h"

@class AKInteractiveBarProxyImpl;

typedef NS_ENUM(NSInteger, InteractiveBarState) {
    InteractiveBarStateVisible,
    InteractiveBarStateHidden,
    InteractiveBarStateInteracting
};

@interface AKInteractiveBarProxy () <UIScrollViewDelegate>
@property (nonatomic, weak) id<AKInteractiveBarProxyDelegate> delegate;
@property (nonatomic) AKInteractiveBarProxyImpl *impl;
@property (nonatomic) UIScrollView *scrollView;
@end

@interface AKInteractiveBarProxyImpl : NSObject
@property (nonatomic, weak) AKInteractiveBarProxy *proxy;
@property (nonatomic) CGFloat interactionTranslation;
@property (nonatomic) InteractiveBarState interactiveBarState;
@property (nonatomic) InteractiveBarState interactiveBarStateAtBeginning;
@property (nonatomic) CGPoint contentOffsetAtBeginning;
@end

@implementation AKInteractiveBarProxyImpl

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat dy = [scrollView.panGestureRecognizer translationInView:scrollView].y;
        CGFloat initialContentOffsetY = self.contentOffsetAtBeginning.y;
        
        if (dy > 0) {
            // User scrolling up = dragging down = progress increases
            // - Interactively show when we're at the top of content (CURRENTLY A BIT BROKEN)
            // - Otherwise do nothing
            if (initialContentOffsetY < 0) {
                CGFloat progress = ABS(dy/self.proxy.interactionTranslation);
                if (self.interactiveBarStateAtBeginning == InteractiveBarStateVisible) {
                    progress = 1.0;
                    [self delegateInteractiveActionWithProgress:progress];
                } else if (self.interactiveBarStateAtBeginning == InteractiveBarStateHidden) {
                    progress = MAX(0.0, MIN(progress, 1.0));
                    [self delegateInteractiveActionWithProgress:progress];
                }
            }
        } else if (dy < 0) {
            // User scrolling down = dragging up = progress decreases
            // - Non-interactively show when we begin drags at the end of content
            // - Otherwise interactively hide
            if (initialContentOffsetY >= (scrollView.contentSize.height - scrollView.bounds.size.height - 1.0)) {
                [self delegateNonInteractiveActionWithBarHidden:NO];
            } else {
                CGFloat progress = ABS(dy/self.proxy.interactionTranslation);
                if (self.interactiveBarStateAtBeginning == InteractiveBarStateVisible) {
                    progress = 1.0 - MAX(0.0, MIN(progress, 1.0));
                    [self delegateInteractiveActionWithProgress:progress];
                } else if (self.interactiveBarStateAtBeginning == InteractiveBarStateHidden) {
                    progress = 0.0;
                    [self delegateInteractiveActionWithProgress:progress];
                }
            }
        }
    }
    
    if ([self.proxy.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.proxy.delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.interactiveBarStateAtBeginning = self.interactiveBarState;
    self.contentOffsetAtBeginning = scrollView.contentOffset;
    
    if ([self.proxy.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.proxy.delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
        if ([scrollView.panGestureRecognizer translationInView:scrollView].y > 0) {
            // Flick down
            // Non-interactively show
            [self delegateNonInteractiveActionWithBarHidden:NO];
        } else if ([scrollView.panGestureRecognizer translationInView:scrollView].y < 0) {
            // Flick up
            // - Non-interactively hide unless we're at the bottom of content
            if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height - 1.0)) {
                // do nothing
            } else {
                [self delegateNonInteractiveActionWithBarHidden:YES];
            }
        }
    } else {
        if ([scrollView.panGestureRecognizer translationInView:scrollView].y > 0) {
            // Drag down and hold, then stop
            // Kill interactive animation with non-interactive one, depending on its current direction
            if (self.interactiveBarState == InteractiveBarStateInteracting) {
                if (self.interactiveBarStateAtBeginning == InteractiveBarStateVisible) {
                    [self delegateNonInteractiveActionWithBarHidden:YES];
                } else if (self.interactiveBarStateAtBeginning == InteractiveBarStateHidden) {
                    [self delegateNonInteractiveActionWithBarHidden:NO];
                }
            }
        } else {
            // Drag up and hold (or just hold), then stop
            // - Non-interactively hide unless we're at the bottom of content
            if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height - 0.5)) {
                // do nothing
            } else {
                [self delegateNonInteractiveActionWithBarHidden:YES];
            }
        }
    }
    
    if ([self.proxy.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.proxy.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

#pragma mark - Private

- (void)delegateInteractiveActionWithProgress:(CGFloat)progress
{
    if ([self.proxy.delegate respondsToSelector:@selector(proxy:receivedInteractiveGestureWithProgress:)]) {
        [self.proxy.delegate proxy:self.proxy receivedInteractiveGestureWithProgress:progress];
    }
    
    self.interactiveBarState = InteractiveBarStateInteracting;
}

- (void)delegateNonInteractiveActionWithBarHidden:(BOOL)hidden
{
    if ([self.proxy.delegate respondsToSelector:@selector(proxy:receivedNonInteractiveActionWithBarHidden:)]) {
        [self.proxy.delegate proxy:self.proxy receivedNonInteractiveActionWithBarHidden:hidden];
    }
    
    if (hidden) {
        self.interactiveBarState = InteractiveBarStateHidden;
    } else {
        self.interactiveBarState = InteractiveBarStateVisible;
    }
}

@end

#pragma mark -

@implementation AKInteractiveBarProxy

+ (BOOL)respondsToSelector:(SEL)aSelector
{
    return YES;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView delegate:(id<AKInteractiveBarProxyDelegate>)delegate;
{
    if (delegate == nil) {
        [[NSException exceptionWithName:NSInvalidArgumentException reason:@"delegate must not be nil" userInfo:nil] raise];
        return nil;
    }
    self.delegate = delegate;
    self.impl = [[AKInteractiveBarProxyImpl alloc] init];
    self.impl.proxy = self;
    
    self.scrollView = scrollView;
    self.scrollView.delegate = self;
    
    return self;
}

#pragma mark - NSProxy

- (void)forwardInvocation:(NSInvocation *)invocation
{
    // Dispatch incoming messages into our implementation if possible, otherwise delegate them
    if ([self.impl respondsToSelector:invocation.selector]) {
        invocation.target = self.impl;
        [invocation invoke];
    } else {
        invocation.target = self.delegate;
        [invocation invoke];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    // Dispatch incoming messages into our implementation if possible, otherwise delegate them
    if ([self.impl respondsToSelector:sel]) {
        return [self.impl methodSignatureForSelector:sel];
    } else {
        NSObject *obj = self.delegate;
        return [obj methodSignatureForSelector:sel];
    }
}

#pragma mark - Public

- (CGFloat)interactionTranslation
{
    return self.impl.interactionTranslation;
}

- (void)setInteractionTranslation:(CGFloat)interactionTranslation
{
    self.impl.interactionTranslation = interactionTranslation;
}

@end

