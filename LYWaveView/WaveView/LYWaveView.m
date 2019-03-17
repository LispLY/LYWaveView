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

/*
 思路：画3个透明的 shape layer，根据 displayLink 改变 layer 的位置
 
 */

//- (CGColorRef)fillColor {
//    return [self.color colorWithAlphaComponent:0.5].CGColor;
//}

-(void)awakeFromNib {
    [super awakeFromNib];
    self.displayLink = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(animate)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    self.amplitude = 0.2*CGRectGetHeight(self.bounds);
    self.color = [UIColor colorWithRed:0 green:150.0/255 blue:1.0 alpha:0.3];
    self.baseLine = 0.5*CGRectGetHeight(self.bounds);
    self.velocity = 3.0;
 }

- (void)layoutSubviews {
    CAShapeLayer *layer = [self layerWithPhase:0 period:M_PI*2];
    CAShapeLayer *layer2 = [self layerWithPhase:M_PI*0.667 period:M_PI*2];
    CAShapeLayer *layer3 = [self layerWithPhase:M_PI*1.333 period:M_PI*2];

    [self.layer addSublayer:layer];
    [self.layer addSublayer:layer2];
    [self.layer addSublayer:layer3];

}

- (void)dealloc {
    [_displayLink invalidate];
}


- (void)animate {
    for (CAShapeLayer *layer in self.layer.sublayers) {
        CGFloat xPosition = layer.position.x;
        if (layer.frame.origin.x <= -CGRectGetWidth(self.bounds) + self.velocity) {
            layer.position = CGPointMake(xPosition - self.velocity + CGRectGetWidth(self.bounds), layer.position.y);
        } else {
            layer.position = CGPointMake(xPosition - self.velocity, layer.position.y);
        }
    }
}

- (CAShapeLayer *)layerWithPhase:(CGFloat)phase period:(CGFloat)period {
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds) * 2, CGRectGetHeight(self.bounds));
    UIBezierPath *path = [UIBezierPath new];
    
    CGFloat showWidth = CGRectGetWidth(self.bounds);
    CGFloat y = CGRectGetHeight(layer.bounds) * self.baseLine;
    [path moveToPoint:CGPointMake(y, 0)];

    CGFloat y0 = sin(phase) * self.amplitude + self.baseLine;
    for (CGFloat x=0; x<=CGRectGetWidth(layer.bounds); x++) {
        y =  sin(x/showWidth * period + phase) * self.amplitude + self.baseLine;
        [path addLineToPoint:CGPointMake(x, y)];
    }
    CGPoint rightBottom = CGPointMake(2*CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGPoint leftBottom = CGPointMake(0, CGRectGetHeight(self.bounds));
    [path addLineToPoint:rightBottom];
    [path addLineToPoint:leftBottom];
    [path addLineToPoint:CGPointMake(0, y0)];
    [path closePath];

    layer.path = path.CGPath;
    layer.fillColor = [self.color colorWithAlphaComponent:0.5].CGColor;
    layer.delegate = self;
    return layer;
}
@end
