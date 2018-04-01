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
	var newOrbEvery: TimeInterval = 0.5
	var timeSinceLastOrb: TimeInterval = 0.0
	var lastFrame: TimeInterval = 0.0
	var gameSpeed = 6 // This is essentially the gravity of the orbs

	
	let player = SKSpriteNode(texture: playerTexture)

	override func didMove(to: SKView) {
		self.physicsWorld.contactDelegate = self
		self.backgroundColor = .black
		
		// Background
		let bg = SKSpriteNode(texture: SKTexture(imageNamed: "Background"))
		bg.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
		self.addChild(bg)
		
		// Points and Lives labels
		livesLabel.fontSize = 20
		livesLabel.fontColor = .white
		livesLabel.fontName = "Helvetica"
		livesLabel.position = CGPoint(x: 10, y: self.size.height - 30)
		livesLabel.horizontalAlignmentMode = .left
		self.addChild(livesLabel)
		
		pointsLabel.fontSize = 20
		pointsLabel.fontColor = .white
		pointsLabel.fontName = "Helvetica"
		pointsLabel.position = CGPoint(x: self.size.width - 10, y: self.size.height - 30)
		pointsLabel.horizontalAlignmentMode = .right
		self.addChild(pointsLabel)
		
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
		
		//Creating out of frame ground to remove old orbs0x0001
		let oob = SKShapeNode(rectOf: CGSize(width: self.size.width, height: 100))
		oob.name = "oob"
		oob.position = CGPoint(x: self.size.width / 2, y: -100)
		oob.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: 100))
		oob.physicsBody!.affectedByGravity = false
		oob.physicsBody!.isDynamic = false
		oob.physicsBody!.collisionBitMask = 0x0001
		oob.physicsBody!.categoryBitMask = 0x0002
		oob.physicsBody!.contactTestBitMask = 0x0001
		oob.physicsBody?.restitution = 0
		self.addChild(oob)
		
		self.physicsWorld.gravity = CGVector(dx: 0, dy: abs(gameSpeed) * -1)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			if t.location(in: self).x < self.size.width * 0.5 {
				if(player.position.x >= self.size.width / 2.1) {
					player.run(SKAction.moveBy(x: self.size.width / -3, y: 0, duration: 0.2))
				}
				//player.run(loseSound)
			}
			else {
				if(player.position.x <= self.size.width / 1.9) {
					player.run(SKAction.moveBy(x: self.size.width / 3, y: 0, duration: 0.2))
				}
				//player.run(winSound)
			}
		}
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		if (contact.bodyB.node?.name == "powerup" ||
		   contact.bodyB.node?.name == "powerdown") &&
		   contact.bodyA.node?.name == "player" {
			//let sound = SKAudioNode(fileNamed: "win")
			//sound.isPositional = false
			//self.addChild(sound)
			if(contact.bodyB.node?.name == "powerup") {
				points += 100
			}
			else {
				lives -= 1
			}
			contact.bodyB.node?.removeFromParent()
			//sound.run(winSound)
		}
		else if (contact.bodyB.node?.name == "powerup" ||
			contact.bodyB.node?.name == "powerdown") &&
			contact.bodyA.node?.name == "oob" {
			contact.bodyB.node?.removeFromParent()
		}
	}

	
	override func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
		livesLabel.text = "Lives: \(lives)"
		pointsLabel.text = "Points: \(points)"
		
		if(lives <= 0) {
			self.physicsWorld.speed = 0.0
			let gameOverLabel = SKLabelNode(text: "Game Over!")
			gameOverLabel.fontSize = 20
			gameOverLabel.fontName = "Helvetica"
			gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
			gameOverLabel.horizontalAlignmentMode = .center
			self.addChild(gameOverLabel)
		}
		
		timeSinceLastOrb += (currentTime - lastFrame)
		if(timeSinceLastOrb >= newOrbEvery) {
			let randomLane = arc4random_uniform(3)
			let randomOrb = arc4random_uniform(2)
			var orbTexture: SKTexture!
			var orbName: String
			if(randomOrb > 0) {
				orbTexture = powerupTexture
				orbName = "powerup"
			}
			else {
				orbTexture = powerdownTexture
				orbName = "powerdown"
			}
			switch randomLane {
			case 0:
				self.addChild(createOrb(orbTexture,
										position: CGPoint(x: self.size.width / 6, y: self.size.height + 50),
										name: orbName))
			case 1:
				self.addChild(createOrb(orbTexture,
										position: CGPoint(x: self.size.width / 2, y: self.size.height + 50),
										name: orbName))
			case 2:
				self.addChild(createOrb(orbTexture,
										position: CGPoint(x: self.size.width * 0.833, y: self.size.height + 50),
										name: orbName))
			default:
				self.addChild(createOrb(orbTexture,
										position: CGPoint(x: self.size.width / 2, y: self.size.height + 50),
										name: orbName))
			}
			timeSinceLastOrb = 0
		}
		lastFrame = currentTime
	}
	
	func createOrb(_ texture: SKTexture?, position: CGPoint, name: String) -> SKSpriteNode {
		let powerup = SKSpriteNode(texture: texture!)
		powerup.name = name
		powerup.position = position
		powerup.xScale = 0.35
		powerup.yScale = 0.35
		powerup.physicsBody = SKPhysicsBody(circleOfRadius: powerup.size.width / 2)
		powerup.physicsBody!.collisionBitMask = 0x0000
		powerup.physicsBody!.categoryBitMask = 0x0003
		powerup.physicsBody!.restitution = 0
		powerup.physicsBody!.contactTestBitMask = 0x0003
		return powerup
	}
	
}
