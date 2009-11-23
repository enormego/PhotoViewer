#import "PVGlobal.h"

@protocol PVScrollViewDelegate;
@protocol PVScrollViewDataSource;

@interface PVScrollView : UIView {
  id<PVScrollViewDelegate> _delegate;
  id<PVScrollViewDataSource> _dataSource;
  NSInteger _centerPageIndex;
  NSInteger _visiblePageIndex;
  BOOL _scrollEnabled;
  BOOL _zoomEnabled;
  BOOL _rotateEnabled;
  CGFloat _pageSpacing;
  UIInterfaceOrientation _orientation;
  NSTimeInterval _holdsAfterTouchingForInterval;
  
  NSMutableArray* _pages;
  NSMutableArray* _pageQueue;
  NSInteger _maxPages;
  NSInteger _pageArrayIndex;
  NSTimer* _tapTimer;
  NSTimer* _holdingTimer;
  NSTimer* _animationTimer;
  NSDate* _animationStartTime;
  NSTimeInterval _animationDuration;
  UIEdgeInsets _animateEdges;
  UIEdgeInsets _pageEdges;
  UIEdgeInsets _pageStartEdges;
  UIEdgeInsets _touchEdges;
  UIEdgeInsets _touchStartEdges;
  NSUInteger _touchCount;
  CGFloat _overshoot;
  UITouch* _touch1;
  UITouch* _touch2;
  BOOL _dragging;
  BOOL _zooming;
  BOOL _holding;
}

/**
 *
 */
@property(nonatomic,assign) id<PVScrollViewDelegate> delegate;

/**
 *
 */
@property(nonatomic,assign) id<PVScrollViewDataSource> dataSource;

/**
 *
 */
@property(nonatomic) NSInteger centerPageIndex;

/**
 *
 */
@property(nonatomic,readonly) BOOL zoomed;

/**
 *
 */
@property(nonatomic,readonly) BOOL holding;

/**
 *
 */
@property(nonatomic) BOOL scrollEnabled;

/**
 *
 */
@property(nonatomic) BOOL zoomEnabled;

/**
 *
 */
@property(nonatomic) BOOL rotateEnabled;

/**
 *
 */
@property(nonatomic) CGFloat pageSpacing;

/**
 *
 */
@property(nonatomic) UIInterfaceOrientation orientation;

/**
 *
 */
@property(nonatomic) NSTimeInterval holdsAfterTouchingForInterval;

/**
 *
 */
@property(nonatomic,readonly) NSInteger numberOfPages;

/**
 *
 */
@property(nonatomic,readonly) UIView* centerPage;

/**
 * A dictionary of visible pages keyed by the index of the page.
 */
@property(nonatomic,readonly) NSDictionary* visiblePages;

- (void)setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

/**
 * Gets a previously created page view that has been moved off screen and recycled.
 */
- (UIView*)dequeueReusablePage;

/**
 *
 */
- (void)reloadData;

/**
 *
 */
- (UIView*)pageAtIndex:(NSInteger)pageIndex;

/**
 *
 */
- (void)zoomToFit;

/**
 *
 */
- (void)zoomToDistance:(CGFloat)distance;

/**
 * Cancels any active touches and resets everything to an untouched state.
 */
- (void)cancelTouches;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol PVScrollViewDelegate <NSObject>

/**
 *
 */
- (void)scrollView:(PVScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex;

@optional

/**
 *
 */
- (void)scrollViewWillRotate:(PVScrollView*)scrollView
        toOrientation:(UIInterfaceOrientation)orientation;

/**
 *
 */
- (void)scrollViewDidRotate:(PVScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewWillBeginDragging:(PVScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewDidEndDragging:(PVScrollView*)scrollView willDecelerate:(BOOL)willDecelerate;

/**
 *
 */
- (void)scrollViewDidEndDecelerating:(PVScrollView*)scrollView;

/**
 *
 */
- (BOOL)scrollViewShouldZoom:(PVScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewDidBeginZooming:(PVScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewDidEndZooming:(PVScrollView*)scrollView;

/**
 *
 */
- (void)scrollView:(PVScrollView*)scrollView touchedDown:(UITouch*)touch;

/**
 *
 */
- (void)scrollView:(PVScrollView*)scrollView touchedUpInside:(UITouch*)touch;

/**
 *
 */
- (void)scrollView:(PVScrollView*)scrollView tapped:(UITouch*)touch;

/**
 *
 */
- (void)scrollViewDidBeginHolding:(PVScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewDidEndHolding:(PVScrollView*)scrollView;

@optional

- (BOOL)scrollView:(PVScrollView*)scrollView 
        shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol PVScrollViewDataSource <NSObject>

/**
 *
 */
- (NSInteger)numberOfPagesInScrollView:(PVScrollView*)scrollView;

/**
 * Gets a view to display for the page at the given index.
 *
 * You do not need to position or size the view as that is done for you later.  You should
 * call dequeueReusablePage first, and only create a new view if it returns nil.
 */
- (UIView*)scrollView:(PVScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex;

/**
 * Gets the natural size of the page. 
 *
 * The actual width and height are not as important as the ratio between width and height.
 * This is used to determine how to 
 */
- (CGSize)scrollView:(PVScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex;

@end
