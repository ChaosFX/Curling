//
//  Scene.h
//  Curling
//

//  Copyright (c) 2014 Dominik Lingnau. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(uint32_t, PhysicsCategory) {
    PhysicsCategoryBackground   = 1 << 0,
    PhysicsCategoryRock         = 1 << 1,
};

@interface Scene : SKScene <SKPhysicsContactDelegate>

@end
