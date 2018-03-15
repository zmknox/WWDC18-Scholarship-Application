import Foundation
import SpriteKit

var grayPowerup = SKTexture(imageNamed: "grayPowerup")
var colorPowerup = SKTexture(imageNamed: "colorPowerup")
var grayPowerdown = SKTexture(imageNamed: "grayPowerdown")
var colorPowerdown = SKTexture(imageNamed: "colorPowerdown")

//: We'll use this function to give our SKView to the Playground pages.
public func gameView(accessible: Bool = true) -> SKView {
	let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 480, height: 320))
	
	let scene = AccessibleGameScene(size: CGSize(width: 480, height: 320))
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
		let powerup = SKSpriteNode(texture: powerupTexture!)
		powerup.name = "powerup"
		powerup.position = CGPoint(x: self.size.width * 0.25, y: self.size.height * 0.5)
		powerup.xScale = 0.35
		powerup.yScale = 0.35
		self.addChild(powerup)
		
		//adding powerdown
		let powerdown = SKSpriteNode(texture: powerdownTexture!)
		powerdown.name = "powerdown"
		powerdown.position = CGPoint(x: self.size.width * 0.75, y: self.size.height * 0.5)
		powerdown.xScale = 0.35
		powerdown.yScale = 0.35
		self.addChild(powerdown)
	}
	
	
}
