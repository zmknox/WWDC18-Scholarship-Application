import Foundation
import SpriteKit

var grayPowerup = SKTexture(imageNamed: "grayPowerup")
var colorPowerup = SKTexture(imageNamed: "colorPowerup")
var grayPowerdown = SKTexture(imageNamed: "grayPowerdown")
var colorPowerdown = SKTexture(imageNamed: "colorPowerdown")
var playerTexture = SKTexture(imageNamed: "Player")


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
class AccessibleGameScene: SKScene {
	
	var powerupTexture: SKTexture?
	var powerdownTexture: SKTexture?
	
	
	override func didMove(to: SKView) {
		self.backgroundColor = .black
		
		//adding powerup
		let powerup = createOrb(powerupTexture, position: CGPoint(x: self.size.width * 0.25, y: self.size.height * 0.5))
		self.addChild(powerup)
		
		//adding powerdown
		let powerdown = createOrb(powerdownTexture, position: CGPoint(x: self.size.width * 0.75, y: self.size.height * 0.5))
		self.addChild(powerdown)
		
		let player = SKSpriteNode(texture: playerTexture)
		player.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.1)
		player.xScale = 0.25
		player.yScale = 0.25
		self.addChild(player)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			if t.location(in: self).x < self.size.width * 0.5 {
				print("left")
			}
			else {
				print("right")
			}
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
	}
	
	func createOrb(_ texture: SKTexture?, position: CGPoint) -> SKSpriteNode {
		let powerup = SKSpriteNode(texture: texture!)
		powerup.name = "powerup"
		powerup.position = position
		powerup.xScale = 0.35
		powerup.yScale = 0.35
		powerup.physicsBody = SKPhysicsBody(circleOfRadius: powerup.size.width / 2)
		return powerup
	}
	
}
