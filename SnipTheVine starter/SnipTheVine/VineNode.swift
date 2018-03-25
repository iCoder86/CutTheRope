
import UIKit
import SpriteKit

class VineNode: SKNode {
  
  private let length: Int
  private let anchorPoint: CGPoint
  private var vineSegments: [SKNode] = []
  
  init(length: Int, anchorPoint: CGPoint, name: String) {
    self.length = length
    self.anchorPoint = anchorPoint
    
    super.init()
    
    self.name = name
  }
  
  required init?(coder aDecoder: NSCoder) {
    length = aDecoder.decodeInteger(forKey: "length")
    anchorPoint = aDecoder.decodeCGPoint(forKey: "anchorPoint")

    super.init(coder: aDecoder)
  }
  
  func addToScene(_ scene: SKScene) {
    // add vine to scene
    zPosition = Layer.Vine
    
    // create vine holder
    let vineHolder = SKSpriteNode(imageNamed: ImageName.VineHolder)
    vineHolder.position = anchorPoint
    vineHolder.zPosition = 1
    
    addChild(vineHolder)
    
    vineHolder.physicsBody = SKPhysicsBody(circleOfRadius: vineHolder.size.width / 2)
    vineHolder.physicsBody?.isDynamic = false
    vineHolder.physicsBody?.categoryBitMask = PhysicsCategory.VineHolder
    vineHolder.physicsBody?.collisionBitMask = 0
    
    // add each of the vine parts
    for i in 0..<length {
      let vineSegment = SKSpriteNode(imageNamed: ImageName.VineTexture)
      let offset = vineSegment.size.height * CGFloat(i + 1)
      vineSegment.position = CGPoint(x: anchorPoint.x, y: anchorPoint.y - offset)
      vineSegment.name = name
      
      vineSegments.append(vineSegment)
      addChild(vineSegment)
      
      vineSegment.physicsBody = SKPhysicsBody(rectangleOf: vineSegment.size)
      vineSegment.physicsBody?.categoryBitMask = PhysicsCategory.Vine
      vineSegment.physicsBody?.collisionBitMask = PhysicsCategory.VineHolder
    }
    
    scene.addChild(self)
    
    // set up joint for vine holder
    let joint = SKPhysicsJointPin.joint(withBodyA: vineHolder.physicsBody!,
                                        bodyB: vineSegments[0].physicsBody!,
                                        anchor: CGPoint(x: vineHolder.frame.midX, y: vineHolder.frame.midY))
    scene.physicsWorld.add(joint)
    
    // set up joints between vine parts
    for i in 1..<length {
      let nodeA = vineSegments[i - 1]
      let nodeB = vineSegments[i]
      let joint = SKPhysicsJointPin.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!,
                                          anchor: CGPoint(x: nodeA.frame.midX, y: nodeA.frame.minY))
      
      scene.physicsWorld.add(joint)
    }
  }
  
  func attachToPrize(_ prize: SKSpriteNode) {
    // align last segment of vine with prize
    let lastNode = vineSegments.last!
    lastNode.position = CGPoint(x: prize.position.x, y: prize.position.y + prize.size.height * 0.1)
    
    // set up connecting joint
    let joint = SKPhysicsJointPin.joint(withBodyA: lastNode.physicsBody!,
                                        bodyB: prize.physicsBody!, anchor: lastNode.position)
    
    prize.scene?.physicsWorld.add(joint)
    
  }
}

