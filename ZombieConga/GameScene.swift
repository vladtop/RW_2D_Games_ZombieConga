//
//  GameScene.swift
//  ZombieConga
//
//  Created by Vladislav Dimitrov on 9/30/16.
//  Copyright © 2016 vlad. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    let zombie = SKSpriteNode(imageNamed: "zombie1")
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    
    let playableRect: CGRect
    
    var lastTouchLocation: CGPoint?
    
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        background.zPosition = -1
        
        addChild(background)
        
        zombie.position = CGPoint(x: 400, y: 400)
        
        addChild(zombie)
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        print("Amount to move: \(amountToMove)")
        
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        let offset = location - zombie.position
        
        let direction = offset.normalized()
        
        velocity = direction * zombieMovePointsPerSec
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        
        moveZombieToward(location: touchLocation)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocaiton = touch.location(in: self)
        
        sceneTouched(touchLocation: touchLocaiton)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        sceneTouched(touchLocation: touchLocation)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        print("\(dt) seconds since last update")
        
        if let lastTouchLocaiton = lastTouchLocation {
            let lastTouchLocationOffset = lastTouchLocaiton - zombie.position
            
            let zombieWillMove = zombieMovePointsPerSec * CGFloat(dt)
            
            if lastTouchLocationOffset.length() <= zombieWillMove {
                zombie.position = lastTouchLocaiton
                velocity = CGPoint.zero
            } else {
                moveSprite(sprite: zombie, velocity: velocity)
                rotateSprite(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
            }
        }
        
        boundsCheckZombie()
    }
}
