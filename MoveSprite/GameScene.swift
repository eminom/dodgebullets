//
//  GameScene.swift
//  MoveSprite
//
//  Created by baihai on 15/1/14.
//  Copyright (c) 2015 bai's gamehouse. All rights reserved.
//

import SpriteKit

class SKObjNode :SKLabelNode{
    var _no:Int = 0
}

class CircleBullet:SKShapeNode{
    var _no:Int = 0
}

typealias BulletNode = CircleBullet
typealias BulletSet = Dictionary<Int, BulletNode>

class GameScene: SKScene {
    
    internal override func didMoveToView(v: SKView) {
        //The default accessor is internal
        //The three access qualifier are not counterparts with C++'s public/protected/private
        initMyScene()
    }
    
    private func goWithLocation(org:CGPoint, _ loc:CGPoint)->CGPoint{
        var x, y:CGFloat
        if org.x > loc.x{
            x = -1
        } else if org.x < loc.x {
            x = 1
        } else {
            x = 0
        }
        if org.y > loc.y{
            y = -1
        } else if org.y < loc.y {
            y = 1
        } else {
            y = 0
        }
        return CGPoint(x:x, y:y)
    }
    
    override func touchesEnded(touches:NSSet, withEvent event: UIEvent){
        _shiftingSpeed = CGPoint(x:0, y:0)
    }
    
    override func touchesMoved(touches:NSSet, withEvent event:UIEvent){
        let oneTouch:UITouch = touches.anyObject() as UITouch   // and unwrapped as well
        let loc:CGPoint = oneTouch.locationInNode(self)
        let org:CGPoint = (_ship?.position)!      // To specify the implication type
        _shiftingSpeed = goWithLocation(org, loc)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        //Choose the only one
        // The type can be ommited here.(:UITouch)
        let oneTouch:UITouch = touches.anyObject() as UITouch   // and unwrapped as well
        let loc:CGPoint = oneTouch.locationInNode(self)
        let org:CGPoint? = _ship?.position      // To specify the implication type
        _shiftingSpeed = goWithLocation(org!, loc)

        /*
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let now = _ship?.position   //by deduction: it is an Optional<T>
            let nextPos = goWithLocation(now!, loc:location)
            _ship?.position = nextPos
            
            //Format string added.
            println("Go for \(nextPos.x, nextPos.y)")
            
            //createShip()
            
            /*
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
            */
        }
        */
    }
    
    private func initMyScene(){
        _prev = NSDate()
        createShip()
        
        //_bullets = [SKSpriteNode]()
        _bullets = Dictionary<Int, BulletNode>()
        _health = 0
        
        let label = SKLabelNode(text:"PLAYER STATUS")
        label.color = SKColor.blueColor()
        label.position = CGPoint(x:self.frame.width * 0.5, y:self.frame.height * 0.5)
        
        _healthBar = label
        addChild(label)
    }
    
    private func getRandomHori()->CGFloat{
        return CGFloat(arc4random() % 1024)/1024.0 * self.frame.width
    }
    
    private func getRandomVert()->CGFloat{
        return CGFloat(arc4random() % 1024)/1024.0 * self.frame.height
    }
    
    
    private class func createBulletNode(x:CGFloat, _ y:CGFloat, _ x1:CGFloat, _ y1:CGFloat)->BulletNode{
        let bullet0 = CircleBullet(circleOfRadius:24)  // Call SKShapdeNode:circleOfRadius
        bullet0.position = CGPoint(x:x, y:y)
        bullet0.fillColor = SKColor.redColor()         // So it is not hollow.
        let action = SKAction.moveTo(CGPoint(x:x1, y:y1), duration:3.5)
        bullet0.runAction(action)
        return bullet0
    }

    /* // Good to know
    private class func createBulletNode()->BulletNode{
        //let bullet = SKObjNode(text:"X")
        //bullet.addChild(bullet0)
        //bullet.fontColor = SKColor.redColor()
        //bullet.position = CGPoint(x:x0, y:y0) // Ok, you do it this way
    }*/
    
    // Burst something into the air
    private func createBullet(){
        let width = self.frame.width
        let height = self.frame.height
        let margin:CGFloat = 20.0
        var x0, x1, y0, y1:CGFloat   //These four are not optional. And compiler will ensure their initilization is done.
        let side = arc4random() % 4
        switch side {
        case 0:
            // Downside
            x0 = getRandomHori()
            x1 = getRandomHori()
            y0 = 0
            y1 = self.frame.height + margin
            
        case 1:
            // Upside
            x0 = getRandomHori()
            x1 = getRandomHori()
            y0 = self.frame.height
            y1 = 0 - margin
            
        case 2:
            // Left-side
            x0 = 0
            x1 = self.frame.width + margin
            y0 = getRandomVert()
            y1 = getRandomVert()
            
        case 3:
            // Right-side
            x0 = self.frame.height
            x1 = 0 - margin
            y0 = getRandomVert()
            y1 = getRandomVert()
            
        default:
            //
            x0 = 0
            y0 = 0
            x1 = self.frame.width
            y1 = self.frame.height
        }
        
        //
        let bullet = GameScene.createBulletNode(x0, y0, x1, y1)
        addChild(bullet)
        
        // Build with sequence no.
        _seq += 1
        bullet._no = _seq
        _bullets?[_seq] = bullet
    }
    
    private func createShip(){
        //Doesnt work this way
        //self.removeChildrenInArray([self._ship?])
        //self.removeChildrenInArray([self._ship])
        _ship?.removeFromParent()   //
        
        // It is obviously helpful if you learn Cocos2d-x before.
        let sprite = SKSpriteNode(imageNamed:"Spaceship")
        var x = self.frame.width * 0.5
        var y = self.frame.height * 0.5
        var x0 = x + CGFloat(arc4random() % 20)
        var y0 = y + CGFloat(arc4random() % 20)
        
        let location = CGPoint(x:x0, y:y0)
        sprite.xScale = 0.3
        sprite.yScale = 0.3
        sprite.position = location
        self.addChild(sprite)
        _ship = sprite
    }
    
    private func updateStatusBar() {
        _healthBar?.text = "HP :\(_health)"
        _healthBar!.fontColor = SKColor.purpleColor()
    }
    
    private func isOutOfRange(#pos:CGPoint)->Bool{
        let margin:CGFloat = 10.0
        return pos.x < 0 - margin
            ||
            (pos.x > self.frame.width + margin) ||
            pos.y < -margin
            || (pos.y > self.frame.height + margin)
    }
    
    private func checkBullets(){
        var removes:[Int]?
        for (each, v) in _bullets! {
            let bullet = v as BulletNode
            if _ship!.containsPoint(bullet.position) {
                if nil == removes {
                    removes = [Int]()
                }
                removes?.append(bullet._no)
                _health -= 1
            }
        }
        
        for (each, v) in _bullets!{
            let bullet = v as BulletNode
            let pos = bullet.position
            
            if isOutOfRange(pos:pos) {
                if nil == removes{
                    removes = [Int]()
                }
                removes?.append(bullet._no)
            }
        }
        
        if let rms = removes? {
            for no in rms {
                let removed = _bullets?.removeValueForKey(no)
                removed?.removeFromParent()
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        updateStatusBar()
        let now = NSDate()   // Not an optional. I wonder, do we have to alloc one each time we query ?
        if _prev!.timeIntervalSince1970 + _timeInt < now.timeIntervalSince1970 {
            _prev = now
            createBullet()
        }
        
        checkBullets()
        _ship?.position = CGPoint(x:_ship!.position.x + _shiftingSpeed.x, y: _ship!.position.y + _shiftingSpeed.y)
        
        println("bullet count to \(_bullets?.count)")
    }
    
    private var _health:Int = 0
    private var _seq:Int = 0
    private let _timeInt = 0.3
    
    private var _ship:SKSpriteNode?
    private var _healthBar:SKLabelNode?
    private var _bullets:BulletSet?
    private var _shiftingSpeed:CGPoint = CGPoint(x:0, y:0)
    private var _prev:NSDate?
}
