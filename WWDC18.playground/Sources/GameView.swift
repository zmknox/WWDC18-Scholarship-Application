import Foundation
import SpriteKit

//: We'll use this function to give our SKView to the Playground pages.
public func gameView() -> SKView {
	let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 480, height: 320))
	
	let scene = SKScene(size: CGSize(width: 480, height: 320))
	sceneView.showsFPS = true
	sceneView.presentScene(scene)
	
	return sceneView
}

/*:
This class will customize the SKScene to our needs.
*/
class AccessibleGameScene: SKScene {
	
}
