import Foundation
import SpriteKit
import AVFoundation

var grayPowerup = SKTexture(imageNamed: "grayPowerup")
var colorPowerup = SKTexture(imageNamed: "colorPowerup")
var grayPowerdown = SKTexture(imageNamed: "grayPowerdown")
var colorPowerdown = SKTexture(imageNamed: "colorPowerdown")
var playerTexture = SKTexture(imageNamed: "Player")
var loseSound = SKAction.playSoundFileNamed("lose.aif", waitForCompletion: false)
var winSound = SKAction.playSoundFileNamed("win.aif", waitForCompletion: false)


//: We'll use this function to give our SKView to the Playground pages.
public func gameView(accessible: Bool = true) -> SKView {
	let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 400, height: 600))
	
	let scene = AccessibleGameScene(size: CGSize(width: 400, height: 600))
	if accessible {
		scene.powerupTexture = colorPowerup
		scene.powerdownTexture = colorPowerdown
	}
	else {
		scene.powerupTexture = grayPowerup
		scene.powerdownTexture = grayPowerdown
	}
	sceneView.showsFPS = true
	sceneView.presentScene(scene)

	
	return sceneView
}

/*:
This class will customize the SKScene to our needs.
*/
class AccessibleGameScene: SKScene, SKPhysicsContactDelegate {
	
	var powerupTexture: SKTexture?
	var powerdownTexture: SKTexture?
	var points = 0
	var lives = 5
	let livesLabel = SKLabelNode(text: "Lives: 0")
	let pointsLabel = SKLabelNode(text: "Points: 0")

	
	let player = SKSpriteNode(texture: playerTexture)

	override func didMove(to: SKView) {
		self.physicsWorld.contactDelegate = self
		self.backgroundColor = .black
		
		// Points and Lives labels
		
		livesLabel.fontSize = 20
		livesLabel.fontColor = .white
		livesLabel.position = CGPoint(x: 10, y: self.size.height - 30)
		livesLabel.horizontalAlignmentMode = .left
		self.addChild(livesLabel)
		
		pointsLabel.fontSize = 20
		pointsLabel.fontColor = .white
		pointsLabel.position = CGPoint(x: self.size.width - 10, y: self.size.height - 30)
		pointsLabel.horizontalAlignmentMode = .right
		self.addChild(pointsLabel)


		//adding powerup
		let powerup = createOrb(powerupTexture, position: CGPoint(x: self.size.width * 0.25, y: self.size.height * 0.5), name: "powerup")
		self.addChild(powerup)
		
		//adding powerdown
		let powerdown = createOrb(powerdownTexture, position: CGPoint(x: self.size.width * 0.75, y: self.size.height * 0.5), name: "powerdown")
		self.addChild(powerdown)
		
		// Creating our player
		player.name = "player"
		player.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.1)
		player.xScale = 0.25
		player.yScale = 0.25
		player.physicsBody = SKPhysicsBody(circleOfRadius: 50)
		player.physicsBody!.affectedByGravity = false
		player.physicsBody!.isDynamic = false
		player.physicsBody!.collisionBitMask = 0x0001
		player.physicsBody!.categoryBitMask = 0x0000
		player.physicsBody!.contactTestBitMask = 0x0001
		player.physicsBody?.restitution = 0
		self.addChild(player)
		
		self.physicsWorld.gravity = CGVector(dx: 0, dy: -7.0)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			if t.location(in: self).x < self.size.width * 0.5 {
				player.run(SKAction.moveBy(x: self.size.width / -4, y: 0, duration: 0.2))
				//player.run(loseSound)
			}
			else {
				player.run(SKAction.moveBy(x: self.size.width / 4, y: 0, duration: 0.2))
				//player.run(winSound)
			}
		}
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		if (contact.bodyA.node?.name == "powerup" ||
		   contact.bodyA.node?.name == "powerdown") &&
		   contact.bodyB.node?.name == "player" {
			//let sound = SKAudioNode(fileNamed: "win")
			//sound.isPositional = false
			//self.addChild(sound)
			if(contact.bodyA.node?.name == "powerup") {
				points += 100
			}
			else {
				lives -= 1
			}
			contact.bodyA.node?.removeFromParent()
			//sound.run(winSound)
		}
	}

	
	override func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
		livesLabel.text = "Lives: \(lives)"
		pointsLabel.text = "Points: \(points)"
	}
	
	func createOrb(_ texture: SKTexture?, position: CGPoint, name: String) -> SKSpriteNode {
		let powerup = SKSpriteNode(texture: texture!)
		powerup.name = name
		powerup.position = position
		powerup.xScale = 0.35
		powerup.yScale = 0.35
		powerup.physicsBody = SKPhysicsBody(circleOfRadius: powerup.size.width / 2)
		powerup.physicsBody!.collisionBitMask = 0x0000
		powerup.physicsBody!.categoryBitMask = 0x0001
		powerup.physicsBody!.restitution = 0
		powerup.physicsBody!.contactTestBitMask = 0x0000
		return powerup
	}
	
}
