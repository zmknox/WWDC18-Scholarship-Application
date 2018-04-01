import Foundation
/*:
[Previous](@previous)

## Part 3: Adding Accessibility

Clearly that second version was a lot more difficult than the
first. Let's try adding verious elements to make this game
more enjoyable to play. Play around with these setitngs until you
find the right balance for you!
*/
/*:
	We can add symbols to the orbs to help identify them, or add the color back to aid those with full vision. */
let symbols = true
let colors = false
/*:
	We could also try adjusting the number of lives we start with, giving us more chances to earn points. */
let lives = 5
/*:
	Finally, we can try and change the speed of either how often new orbs appear or how fast the orbs move. This can be used as both an accessibility tool and as a way to adjust difficulty.*/
let gameSpeed: Double = 6
let newOrbEvery: TimeInterval = 0.5
/*:
We can see with even this simple example how important
accessibility is in software. I have a visual impairment which
results in a lower visual acuity and full colorblindness. This led
me to use color as the prominent example, but as you can see with
this breadth of possibilities for how to make an app accessible,
this applies to so much more.

### Let's work together to make software accessible to everyone!
*/
import PlaygroundSupport

PlaygroundPage.current.liveView = gameView(colors: colors, symbols: symbols, startingLives: lives, newOrbEvery: newOrbEvery, gameSpeed: gameSpeed)
//: Thank You for trying my playground! —Zach Knox
