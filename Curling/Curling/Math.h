//
//  Math.h
//  Curling
//
//  Created by Dominik Lingnau on 24.04.14.
//  Copyright (c) 2014 Dominik Lingnau. All rights reserved.
//

#ifndef Curling_Math_h
#define Curling_Math_h

static inline CGPoint vectorAdd(CGPoint a, CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint vectorSub(CGPoint a, CGPoint b)
{
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint vectorScalarMult(CGPoint a, CGFloat f)
{
    return CGPointMake(a.x * f, a.y * f);
}

static inline CGFloat vectorLength(CGPoint a)
{
    return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint vectorNorm(CGPoint a)
{
    float length = vectorLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

static inline CGFloat vectorAngle(CGPoint a)
{
    return atan2f(a.x, a.y);
}

static inline CGPoint cartesianFromPolarCoordinate(CGFloat speed, CGFloat angle)
{
    return CGPointMake(speed * cosf(angle), speed * cosf(angle));
}

static inline CGFloat radiansToDegrees(CGFloat radians)
{
    return radians * (180 / M_PI);
}

static inline CGFloat degreesToRadians(CGFloat degrees)
{
    return degrees * (M_PI / 180);
}

#endif
