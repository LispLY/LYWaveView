//
//  LYWaveView.m
//  LYWaveView
//
//  Created by LuLouie on 2019/3/11.
//  Copyright © 2019 llvm.xyz. All rights reserved.
//

#import "LYWaveView.h"
#import "YYWeakProxy.h"
//#import <CoreGraphics/CoreGraphics.h>

@interface LYWaveView ()
@property (nonatomic, assign) CGFloat amplitude;
@property (nonatomic, assign) CGFloat velocity;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat baseLine;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation LYWaveView

-(void)awakeFromNib {
    [super awakeFromNib];
    self.animation = YES;
}

- (void)setAnimation:(BOOL)animation {
    if (animation) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(animate)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        self.amplitude = 0.2*CGRectGetHeight(self.bounds);
        self.color = [UIColor colorWithRed:0 green:150.0/255 blue:1.0 alpha:1];
        self.baseLine = 0.5*CGRectGetHeight(self.bounds);
        self.velocity = 3.0;
        [self addWaveLayers];
    } else {
        [self.displayLink invalidate];
    }
    _animation = animation;
}

- (void)dealloc {
    [_displayLink invalidate];
}

- (void)addWaveLayers {
    [self.layer addSublayer:[self layerWithPhase:0 frequency:1.2]];
    [self.layer addSublayer:[self layerWithPhase:0.3 frequency:1]];
    [self.layer addSublayer:[self layerWithPhase:0.5 frequency:0.8]];

}



- (void)animate {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (CAShapeLayer *layer in self.layer.sublayers) {
        CGFloat xPosition = layer.position.x;
        CGFloat frequency =  ((NSNumber *)[layer valueForKey:@"frequency"]).floatValue;
        CGFloat onePeriodWidth = CGRectGetWidth(self.bounds)/frequency;
        
        // 从右向左
//        if (layer.frame.origin.x <= - onePeriodWidth) {
//            layer.position = CGPointMake(xPosition - self.velocity/frequency + onePeriodWidth, layer.position.y);
//        } else {
//            layer.position = CGPointMake(xPosition - self.velocity/frequency, layer.position.y);
//        }
        // 从左向右
        if (layer.frame.origin.x >= self.frame.origin.x) {
            layer.position = CGPointMake(xPosition + self.velocity/frequency - onePeriodWidth, layer.position.y);
        } else {
            layer.position = CGPointMake(xPosition + self.velocity/frequency, layer.position.y);
        }

    }
    [CATransaction commit];
}


// frame 宽度：

- (CAShapeLayer *)layerWithPhase:(CGFloat)phase frequency:(CGFloat)frequency {
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    [layer setValue:@(frequency) forKey:@"frequency"];
    
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat onePeriodWidth = viewWidth/frequency;
    CGFloat layerWidth = onePeriodWidth > viewWidth ? onePeriodWidth+viewWidth : viewWidth*2;
    
    layer.frame = CGRectMake(0, 0, layerWidth, CGRectGetHeight(self.bounds));
    UIBezierPath *path = [UIBezierPath new];
    
    CGFloat y0 = sin(-2*M_PI*phase) * self.amplitude + self.baseLine;
    CGPoint startingPoint = CGPointMake(0, y0);
    [path moveToPoint:startingPoint];
    /*
     y = A sin(Bx + C) + D
     
     振幅 amplitude：A
     周期 period： 2π/B
     频率 frequency：B/2π
     相移 Phase： −C/B
     垂直移位 baseLine：D
     
     B = 2π * frequency
     C = - 2π * frequency * phase
     */

    for (CGFloat x=0; x<=layerWidth; x++) {
        CGFloat y = sin(2*M_PI * x/viewWidth * frequency - 2*M_PI*phase) * self.amplitude + self.baseLine;
        [path addLineToPoint:CGPointMake(x, y)];
    }
    CGPoint rightBottom = CGPointMake(CGRectGetWidth(layer.bounds), CGRectGetHeight(layer.bounds));
    CGPoint leftBottom = CGPointMake(0, CGRectGetHeight(layer.bounds));
    [path addLineToPoint:rightBottom];
    [path addLineToPoint:leftBottom];
    [path addLineToPoint:startingPoint];
    [path closePath];

    layer.path = path.CGPath;
    layer.fillColor = [self.color colorWithAlphaComponent:0.3].CGColor;
    return layer;
}
@end
