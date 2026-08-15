#import <Cocoa/Cocoa.h>

static const CGFloat CellW = 192.0;
static const CGFloat CellH = 208.0;
static const CGFloat PetScale = 1.08;
static const CGFloat WindowW = CellW * PetScale;
static const CGFloat WindowH = CellH * PetScale;
static const NSInteger Columns = 8;
static const NSInteger Rows = 11;
static const NSTimeInterval FrameStep = 0.14;
static const CGFloat GazeMargin = 60.0;
static const CGFloat GazeAnchorY = 0.73;
static const CGFloat GazeHysteresis = 4.0;
static const CGFloat DockGap = -70.0;

typedef NS_ENUM(NSInteger, PetState) {
    PetIdle, PetRap, PetSinging, PetReview, PetWaiting, PetFailed,
    PetGaze, PetRunningRight, PetRunningLeft, PetAngry
};

@class PetController;

@interface PetView : NSView
@property(nonatomic, assign) PetController *controller;
@end

@interface PetWindow : NSWindow
@property(nonatomic, assign) PetController *controller;
@end

@interface PetController : NSObject <NSApplicationDelegate>
@property(nonatomic, strong) NSImage *atlas;
@property(nonatomic, strong) PetWindow *window;
@property(nonatomic, strong) PetView *view;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic) PetState state;
@property(nonatomic) NSInteger frame;
@property(nonatomic) NSInteger actionFramesPlayed;
@property(nonatomic) NSInteger idleLoopsCompleted;
@property(nonatomic) NSInteger idleSequenceIndex;
@property(nonatomic) NSInteger actionLoopsCompleted;
@property(nonatomic) NSInteger hoverRapCount;
@property(nonatomic) NSTimeInterval dragSeconds;
@property(nonatomic) BOOL angerAfterAction;
@property(nonatomic) BOOL dragging;
@property(nonatomic) BOOL hoverActive;
@property(nonatomic) NSTimeInterval dragStarted;
@property(nonatomic) NSPoint dragStart;
@property(nonatomic) NSPoint lastDragPoint;
@property(nonatomic) NSPoint windowStart;
@property(nonatomic) NSTimeInterval stateStarted;
- (void)beginDrag:(NSEvent *)event;
- (void)continueDrag:(NSEvent *)event;
- (void)endDrag;
- (void)quit;
- (void)placeAboveDock:(id)sender;
- (NSInteger)atlasIndex;
@end

@implementation PetView
- (BOOL)isFlipped { return NO; }
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    PetController *c = self.controller;
    if (!c.atlas) return;
    [NSGraphicsContext currentContext].imageInterpolation = NSImageInterpolationNone;
    NSInteger index = [c atlasIndex];
    NSInteger col = index % Columns;
    NSInteger row = index / Columns;
    CGFloat sourceY = (Rows - row - 1) * CellH;
    [c.atlas drawInRect:self.bounds
              fromRect:NSMakeRect(col * CellW, sourceY, CellW, CellH)
             operation:NSCompositingOperationSourceOver
              fraction:1.0];
}
- (void)mouseDown:(NSEvent *)event { [self.controller beginDrag:event]; }
- (void)mouseDragged:(NSEvent *)event { [self.controller continueDrag:event]; }
- (void)mouseUp:(NSEvent *)event { [self.controller endDrag]; }
- (void)rightMouseDown:(NSEvent *)event { [self.controller quit]; }
@end

@implementation PetWindow
- (BOOL)canBecomeKeyWindow { return YES; }
- (BOOL)canBecomeMainWindow { return YES; }
@end

@implementation PetController
- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"spritesheet" withExtension:@"png"];
    self.atlas = [[NSImage alloc] initWithContentsOfURL:url];
    self.window = [[PetWindow alloc] initWithContentRect:NSMakeRect(0, 0, WindowW, WindowH)
                                                 styleMask:NSWindowStyleMaskBorderless
                                                   backing:NSBackingStoreBuffered
                                                     defer:NO];
    self.view = [[PetView alloc] initWithFrame:NSMakeRect(0, 0, WindowW, WindowH)];
    self.view.controller = self;
    self.window.controller = self;
    self.window.contentView = self.view;
    self.window.backgroundColor = [NSColor clearColor];
    self.window.opaque = NO;
    self.window.hasShadow = NO;
    self.window.level = NSDockWindowLevel + 1;
    self.window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces |
                                      NSWindowCollectionBehaviorFullScreenAuxiliary |
                                      NSWindowCollectionBehaviorStationary |
                                      NSWindowCollectionBehaviorIgnoresCycle;
    self.state = PetIdle;
    [self enterIdle];
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)note {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(placeAboveDock:)
                                             name:NSApplicationDidChangeScreenParametersNotification
                                             object:nil];
    [self.window setLevel:NSDockWindowLevel + 1];
    [self.window orderFrontRegardless];
    [self placeAboveDock:nil];
    [self performSelector:@selector(placeAboveDock:) withObject:nil afterDelay:0.1];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 15.0
                                                   target:self
                                                 selector:@selector(tick:)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void)placeAboveDock:(id)sender {
    NSScreen *screen = self.window.screen ?: NSScreen.mainScreen;
    NSRect visible = screen.visibleFrame;
    NSRect screenFrame = screen.frame;
    NSRect frame = self.window.frame;
    CGFloat x = NSMaxX(visible) - NSWidth(frame) - 24.0;
    CGFloat minY = NSMinY(screenFrame);
    CGFloat maxY = NSMaxY(screenFrame) - NSHeight(frame);
    CGFloat y = MIN(MAX(NSMinY(visible) + DockGap, minY), maxY);
    [self.window setFrameOrigin:NSMakePoint(x, y)];
}

- (NSInteger)atlasIndex {
    switch (self.state) {
        case PetIdle: return self.frame;
        case PetRap: case PetSinging: return 4 * Columns + self.frame;
        case PetFailed: return 5 * Columns + self.frame;
        case PetWaiting: return 6 * Columns + self.frame;
        case PetReview: return 8 * Columns + self.frame;
        case PetRunningRight: return 1 * Columns + self.frame;
        case PetRunningLeft: return 2 * Columns + self.frame;
        case PetAngry: return 7 * Columns + self.frame;
        case PetGaze: return self.frame < 8 ? 9 * Columns + self.frame : 10 * Columns + self.frame - 8;
    }
}

- (NSInteger)frameCount {
    switch (self.state) {
        case PetIdle: return 6;
        case PetRap: return 5;
        case PetSinging: return 5;
        case PetWaiting: case PetReview: case PetAngry: return 6;
        case PetFailed: return 8;
        case PetRunningRight: case PetRunningLeft: return 8;
        case PetGaze: return 1;
    }
}

- (NSTimeInterval)now { return NSDate.date.timeIntervalSince1970; }
- (void)enterIdle {
    self.state = PetIdle; self.frame = 0; self.stateStarted = [self now];
    self.idleLoopsCompleted = 0;
    self.idleSequenceIndex = 0;
    self.actionLoopsCompleted = 0;
    [self.view setNeedsDisplay:YES];
}
- (void)startState:(PetState)state {
    self.state = state; self.frame = 0; self.actionFramesPlayed = 0; self.actionLoopsCompleted = 0; self.stateStarted = [self now];
    [self.view setNeedsDisplay:YES];
}
- (BOOL)isIdleSequenceState:(PetState)state {
    return state == PetSinging || state == PetReview || state == PetWaiting || state == PetFailed;
}
- (void)startNextIdleSequenceAction {
    NSArray *sequence = @[@(PetSinging), @(PetWaiting), @(PetFailed)];
    if (self.idleSequenceIndex >= sequence.count) {
        [self enterIdle];
        return;
    }
    PetState next = (PetState)[sequence[self.idleSequenceIndex] integerValue];
    self.idleSequenceIndex++;
    [self startState:next];
}
- (void)finishAction {
    if (self.angerAfterAction) { self.angerAfterAction = NO; [self startState:PetAngry]; }
    else [self enterIdle];
}
- (CGFloat)outsideDistanceForPoint:(NSPoint)point rect:(NSRect)rect {
    CGFloat dx = 0.0;
    if (point.x < NSMinX(rect)) dx = NSMinX(rect) - point.x;
    else if (point.x > NSMaxX(rect)) dx = point.x - NSMaxX(rect);
    CGFloat dy = 0.0;
    if (point.y < NSMinY(rect)) dy = NSMinY(rect) - point.y;
    else if (point.y > NSMaxY(rect)) dy = point.y - NSMaxY(rect);
    return hypot(dx, dy);
}
- (void)tick:(NSTimer *)timer {
    NSTimeInterval now = [self now];
    NSPoint mouse = [NSEvent mouseLocation];
    NSRect rect = self.window.frame;
    BOOL inside = NSPointInRect(mouse, rect);
    CGFloat outsideDistance = [self outsideDistanceForPoint:mouse rect:rect];
    NSPoint center = NSMakePoint(NSMidX(rect), NSMinY(rect) + NSHeight(rect) * GazeAnchorY);

    if (inside && !self.dragging) {
        if (!self.hoverActive) {
            self.hoverActive = YES;
            self.hoverRapCount++;
            if (self.hoverRapCount >= 3) { self.hoverRapCount = 0; self.angerAfterAction = YES; }
        }
        if (self.state != PetRap) [self startState:PetRap];
    } else if (!inside && outsideDistance > 0 && outsideDistance <= GazeMargin && !self.dragging) {
        CGFloat degrees = atan2(mouse.x - center.x, mouse.y - center.y) * 180.0 / M_PI;
        if (degrees < 0) degrees += 360;
        NSInteger direction = ((NSInteger)llround(degrees / 22.5)) % 16;
        if (self.state == PetGaze) {
            CGFloat currentDegrees = self.frame * 22.5;
            CGFloat delta = fabs(degrees - currentDegrees);
            if (delta > 180.0) delta = 360.0 - delta;
            if (delta < 11.25 + GazeHysteresis) direction = self.frame;
        }
        if (self.state != PetGaze || self.frame != direction) {
            self.state = PetGaze; self.frame = direction; self.stateStarted = now;
            [self.view setNeedsDisplay:YES];
        }
    } else if (!inside) {
        self.hoverActive = NO;
        if (self.state == PetRap) {
            [self finishAction];
        }
        if (self.state == PetGaze && !self.dragging) {
            [self enterIdle];
        }
    } else if (self.state == PetGaze && !self.dragging) {
        [self enterIdle];
    }

    if (self.state == PetIdle) {
        if (now - self.stateStarted >= 0.18) {
            self.frame++;
            if (self.frame >= [self frameCount]) {
                self.frame = 0;
                self.idleLoopsCompleted++;
            }
            self.stateStarted = now;
            if (self.idleLoopsCompleted >= 6 && outsideDistance > GazeMargin) {
                [self startNextIdleSequenceAction];
            } else {
                [self.view setNeedsDisplay:YES];
            }
        }
    } else if (self.state == PetRap && now - self.stateStarted >= FrameStep) {
        if (inside && !self.dragging) {
            self.frame = (self.frame + 1) % [self frameCount];
            self.stateStarted = now;
            [self.view setNeedsDisplay:YES];
        }
    } else if (self.state != PetGaze && now - self.stateStarted >= FrameStep) {
        self.frame++;
        self.actionFramesPlayed++;
        self.stateStarted = now;
        if (self.frame >= [self frameCount]) {
            self.actionLoopsCompleted++;
        }
        self.frame = self.frame % [self frameCount];
        if ([self isIdleSequenceState:self.state] && self.actionLoopsCompleted >= 3) {
            if (self.angerAfterAction) { self.angerAfterAction = NO; [self startState:PetAngry]; }
            else [self startNextIdleSequenceAction];
        } else {
            [self.view setNeedsDisplay:YES];
        }
    }
}
- (void)beginDrag:(NSEvent *)event {
    self.dragging = YES; self.dragStarted = [self now];
    self.dragStart = [NSEvent mouseLocation]; self.windowStart = self.window.frame.origin;
    self.lastDragPoint = self.dragStart;
}
- (void)continueDrag:(NSEvent *)event {
    NSPoint p = [NSEvent mouseLocation];
    CGFloat totalDX = p.x - self.dragStart.x;
    CGFloat totalDY = p.y - self.dragStart.y;
    CGFloat stepDX = p.x - self.lastDragPoint.x;
    NSScreen *screen = self.window.screen ?: NSScreen.mainScreen;
    NSRect visible = screen.visibleFrame;
    NSRect screenFrame = screen.frame;
    CGFloat x = MIN(MAX(NSMinX(visible), self.windowStart.x + totalDX),
                    NSMaxX(visible) - WindowW);
    CGFloat minY = NSMinY(screenFrame);
    CGFloat maxY = MIN(NSMaxY(visible), NSMaxY(screenFrame)) - WindowH;
    CGFloat y = MIN(MAX(minY, self.windowStart.y + totalDY), maxY);
    [self.window setFrameOrigin:NSMakePoint(x, y)];
    if (fabs(stepDX) >= 1.0) {
        PetState direction = stepDX > 0 ? PetRunningRight : PetRunningLeft;
        if (self.state != direction) [self startState:direction];
    }
    self.lastDragPoint = p;
}
- (void)endDrag {
    if (!self.dragging) return;
    self.dragging = NO;
    self.dragSeconds += [self now] - self.dragStarted;
    if (self.state == PetRunningRight || self.state == PetRunningLeft) {
        if (self.dragSeconds > 7.0) { self.dragSeconds = 0; self.angerAfterAction = YES; }
        [self finishAction];
    }
}
- (void)quit { [NSApp terminate:nil]; }
@end

int main(int argc, const char **argv) {
    @autoreleasepool {
        NSApplication *app = NSApplication.sharedApplication;
        PetController *controller = [PetController new];
        app.delegate = controller;
        [app run];
    }
    return 0;
}
