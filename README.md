#AKInteractiveBarProxy

AKInteractiveBarProxy library provides a proxy object which helps you to make Safari-like interactive animation bars on UIScrollView. The proxy works as a delegate object for UIScrollView and its subclasses to interact with user inputs. Once user scrolls around on the scroll view, AKInteractiveBarProxy analyse scroll gestures and parse it to its delegate as an interactive animation.

## Install

To install the library, use CocoaPods by `pod 'AKInteractiveBarProxy', '~> 1.0'`

## Usage

Instanticate AKInteractiveBarProxy with your scroll view.

```objc
// Instaciate the target scroll view (or subclasses of scroll view, like table view).
self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
[self.contentView addSubView:scrollView];

// Provide a proxy
// interactionTranslation defines how far users have to pan before interaction is complete.
self.interactiveBarProxy = [[AKInteractiveBarProxy alloc] initWithScrollView:self.scrollView
                                                                    delegate:self];
self.interactiveBarProxy.interactionTranslation = 64.0;
```

Once setup is done, implement delegate methods for the proxy. You can also implement UIScrollViewDelegate as well since AKInteractiveBarProxyDelegate confirms UIScrollViewDelegate.

```objc
// Implement delegate methods
- (void)proxy:(AKInteractiveBarProxy *)proxy receivedInteractiveGestureWithProgress:(CGFloat)progress
{
    // This delegate is called when the proxy detects interactive gestures.
    // Implement your interactive animation here.
    // Note this method is gets called until user stops interactions.
    // progress 0.0 = Your bar should be completely hidden
    // progress 1.0 = Your bar should be completely visible
    self.bar.alpha = progress;
}

- (void)proxy:(AKInteractiveBarProxy *)proxy receivedNonInteractiveActionWithBarHidden:(BOOL)hidden
{
    // This delegate is called when the proxy detects non-interactive onetime actions.
    // You should programmatically show/hide your views here.
    [self.bar setHidden:hidden animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // This will also gets called. Do anything you want!
}
```

## Known Issues

- Interactive animation looks a bit ugly, especiall when scrolling around the top
