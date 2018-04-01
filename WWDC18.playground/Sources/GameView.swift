import Foundation
import SpriteKit
import AVFoundation

var grayPowerup = SKTexture(imageNamed: "grayPowerup")
var grayPowerupSymbol = SKTexture(imageNamed: "grayPowerupSymbol")
var colorPowerup = SKTexture(imageNamed: "colorPowerup")
var colorPowerupSymbol = SKTexture(imageNamed: "colorPowerupSymbol")
var grayPowerdown = SKTexture(imageNamed: "grayPowerdown")
var grayPowerdownSymbol = SKTexture(imageNamed: "grayPowerdownSymbol")
var colorPowerdown = SKTexture(imageNamed: "colorPowerdown")
var colorPowerdownSymbol = SKTexture(imageNamed: "colorPowerdownSymbol")
var playerTexture = SKTexture(imageNamed: "Player")
var loseSound = SKAction.playSoundFileNamed("lose.m4a", waitForCompletion: false)
var winSound = SKAction.playSoundFileNamed("win.m4a", waitForCompletion: false)


//: We'll use this function to give our SKView to the Playground pages.
public func gameView(colors: Bool = true, symbols: Bool = false, startingLives: Int = 5, newOrbEvery: TimeInterval = 0.5, gameSpeed: Double = 6) -> SKView {
	let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 400, height: 600))
	
	let scene = AccessibleGameScene(size: CGSize(width: 400, height: 600))
	
	// Set variables chosen (as seen in Part 3)
	if colors {
		if symbols {
			scene.powerupTexture = colorPowerupSymbol
			scene.powerdownTexture = colorPowerdownSymbol
		}
		else {
			scene.powerupTexture = colorPowerup
			scene.powerdownTexture = colorPowerdown
		}
	}
	else {
		if symbols {
			scene.powerupTexture = grayPowerupSymbol
			scene.powerdownTexture = grayPowerdownSymbol
		}
		else {
			scene.powerupTexture = grayPowerup
			scene.powerdownTexture = grayPowerdown
		}
	}
	scene.startingLives = startingLives
	scene.newOrbEvery = newOrbEvery
	scene.gameSpeed = gameSpeed
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
	var startingLives = 0 // This variable helps when restarting the game
	var lives = 5
	let livesLabel = SKLabelNode(text: "Lives: 0")
	let pointsLabel = SKLabelNode(text: "Points: 0")
	// Game mechanic variables
	var newOrbEvery: TimeInterval = 0.5
	var gameSpeed: Double = 6 // This is essentially the gravity of the orbs
	// Game State Veriables
	var timeSinceLastOrb: TimeInterval = 0.0
	var lastFrame: TimeInterval = 0.0
	var gameover = false

	
	let player = SKSpriteNode(texture: playerTexture)

	override func didMove(to: SKView) {
		self.physicsWorld.contactDelegate = self
		self.backgroundColor = .black
		lives = startingLives
		
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
		player.physicsBody!.affectedByGravity = false // Player doesn't fall
		player.physicsBody!.isDynamic = false // and doesn't move when hit
		player.physicsBody!.collisionBitMask = 0x0001 // 0b00000001
		player.physicsBody!.categoryBitMask = 0x0000 // 0b00000000
		player.physicsBody!.contactTestBitMask = 0x0001 // 0b00000001
		player.physicsBody?.restitution = 0
		self.addChild(player)
		
		//Creating an out of frame ground to remove fallen orbs
		let oob = SKShapeNode(rectOf: CGSize(width: self.size.width, height: 100))
		oob.name = "oob"
		oob.position = CGPoint(x: self.size.width / 2, y: -100)
		oob.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: 100))
		oob.physicsBody!.affectedByGravity = false
		oob.physicsBody!.isDynamic = false
		oob.physicsBody!.collisionBitMask = 0x0001 // 0b00000001
		oob.physicsBody!.categoryBitMask = 0x0002 // 0b00000010
		oob.physicsBody!.contactTestBitMask = 0x0001 // 0b00000001
		oob.physicsBody?.restitution = 0
		self.addChild(oob)
		
		// Gravity is definted by the negated absolute value of gameSpeed
		self.physicsWorld.gravity = CGVector(dx: 0.0, dy: gameSpeed.magnitude * -1)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			// If the game is over, restart the game
			if(gameover) {
				gameover = false
				lives = startingLives
				points = 0
				player.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.1)
				for node in self.children {
					if node.name == "powerup" || node.name == "powerdown" ||
						node.name == "goLabel" {
						node.removeFromParent()
					}
				}
				self.physicsWorld.speed = 1
			}
			// Otherwise, move the player
			else {
				// Left
				if t.location(in: self).x < self.size.width * 0.5 {
					if(player.position.x >= self.size.width / 2.1) {
						player.run(SKAction.moveBy(x: self.size.width / -3, y: 0, duration: 0.2))
					}
				}
				// Right
				else {
					if(player.position.x <= self.size.width / 1.9) {
						player.run(SKAction.moveBy(x: self.size.width / 3, y: 0, duration: 0.2))
					}
				}
			}

		}
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		// Player and Orb contact
		if (contact.bodyB.node?.name == "powerup" ||
		   contact.bodyB.node?.name == "powerdown") &&
		   contact.bodyA.node?.name == "player" {
			// Powerup
			if(contact.bodyB.node?.name == "powerup") {
				points += 100
				self.run(winSound)
			}
			// Powerdown
			else {
				lives -= 1
				self.run(loseSound)
			}
			contact.bodyB.node?.removeFromParent()
			
		}
		// Orb and off screen ground contact
		else if (contact.bodyB.node?.name == "powerup" ||
			contact.bodyB.node?.name == "powerdown") &&
			contact.bodyA.node?.name == "oob" {
			contact.bodyB.node?.removeFromParent()
		}
	}

	
	override func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
		
		// Check for game over, if so, stop physics and draw labels
		if(lives <= 0 && !gameover) {
			gameover = true
			self.physicsWorld.speed = 0.0
			
			// "Game Over" label
			let gameOverLabel = SKLabelNode(text: "Game Over!")
			gameOverLabel.fontSize = 20
			gameOverLabel.fontName = "Helvetica"
			gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
			gameOverLabel.horizontalAlignmentMode = .center
			gameOverLabel.name = "goLabel"
			self.addChild(gameOverLabel)
			
			// "Score:" heading label
			let scoreLabelLabel = SKLabelNode(text: "Score:")
			scoreLabelLabel.fontSize = 20
			scoreLabelLabel.fontName = "Helvetica"
			scoreLabelLabel.position = CGPoint(x: self.size.width / 2, y: (self.size.height / 2) - 80)
			scoreLabelLabel.horizontalAlignmentMode = .center
			scoreLabelLabel.name = "goLabel"
			self.addChild(scoreLabelLabel)
			
			// The actual score label
			let scoreLabel = SKLabelNode(text: "\(points)")
			scoreLabel.fontSize = 30
			scoreLabel.fontName = "Helvetica"
			scoreLabel.position = CGPoint(x: self.size.width / 2, y: (self.size.height / 2) - 110)
			scoreLabel.horizontalAlignmentMode = .center
			scoreLabel.name = "goLabel"
			self.addChild(scoreLabel)
			
			// Label telling the player to try again
			let tryAgainLabel = SKLabelNode(text: "Tap to Retry")
			tryAgainLabel.fontSize = 20
			tryAgainLabel.fontName = "Helvetica"
			tryAgainLabel.position = CGPoint(x: self.size.width / 2, y: (self.size.height / 2) - 180)
			tryAgainLabel.horizontalAlignmentMode = .center
			tryAgainLabel.name = "goLabel"
			self.addChild(tryAgainLabel)
			
			self.run(SKAction.playSoundFileNamed("lose.m4a", waitForCompletion: true))
		}
		// Otherwise, do gameplay updates
		else {
			// Update labels
			livesLabel.text = "Lives: \(lives)"
			pointsLabel.text = "Points: \(points)"
			
			// update time since the last orb spawned
			timeSinceLastOrb += (currentTime - lastFrame)
			// and spawn a new orb if enough time has passed
			if(timeSinceLastOrb >= newOrbEvery) {
				let randomLane = arc4random_uniform(3) // in any lane
				let randomOrb = arc4random_uniform(2) // of any type
				var orbTexture: SKTexture!
				var orbName: String
				// choose type based on randomOrb
				if(randomOrb > 0) {
					orbTexture = powerupTexture
					orbName = "powerup"
				}
				else {
					orbTexture = powerdownTexture
					orbName = "powerdown"
				}
				// and lane based on randomLane
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
		}
		// update what the last frame was
		lastFrame = currentTime
	}
	
	// Create a new orb node
	// name, position, and texture are passed in as the orb could be a
	// powerup or powerdown, and be in any of the three lanes we have.
	func createOrb(_ texture: SKTexture?, position: CGPoint, name: String) -> SKSpriteNode {
		let powerup = SKSpriteNode(texture: texture!)
		powerup.name = name
		powerup.position = position
		powerup.xScale = 0.75
		powerup.yScale = 0.75
		powerup.physicsBody = SKPhysicsBody(circleOfRadius: powerup.size.width / 2)
		powerup.physicsBody!.collisionBitMask = 0x0000 // 0b00000000
		powerup.physicsBody!.categoryBitMask = 0x0003 // 0b00000011
		powerup.physicsBody!.restitution = 0
		powerup.physicsBody!.contactTestBitMask = 0x0003 // 0b00000011
		return powerup
	}
	
}
