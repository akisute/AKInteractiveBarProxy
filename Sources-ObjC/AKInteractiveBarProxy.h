//
//  AKInteractiveBarProxy.h
//  AKInteractiveBarProxy
//
//  Created by Ono Masashi on 2014/09/25.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AKInteractiveBarProxy;

@protocol AKInteractiveBarProxyDelegate <UIScrollViewDelegate>
@optional
- (void)proxy:(AKInteractiveBarProxy *)proxy receivedInteractiveGestureWithProgress:(CGFloat)progress;
- (void)proxy:(AKInteractiveBarProxy *)proxy receivedNonInteractiveActionWithBarHidden:(BOOL)hidden;
@end

@interface AKInteractiveBarProxy : NSProxy
- (instancetype)initWithScrollView:(UIScrollView *)scrollView delegate:(id<AKInteractiveBarProxyDelegate>)delegate;
@property (nonatomic) CGFloat interactionTranslation;
@end
