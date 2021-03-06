/*:
# The Need for Accessibility
## Showing the importance of accessibility through a simulation
### A WWDC18 Scholarship Application by Zach Knox

As a developer, accessibility is one of the most important things to think about. I have a significant visual impairment, so it often affects me directly. This playground will simulate what its like to use an app, and to live in the world, which isn't designed to be accessible, and wll then allow you to make it more accessible!

>Make sure you open the live view in order to interact with this game (open the Assistant editor if using Xcode)

*/
/*:
## Part 1: A Walk in the Park

We'll start by playing through this game without any handicaps. Your goal is to grab powerups to increase your score, while avoiding the powerdowns. The game ends when you hit three powerdowns.

Tap the left side of the screen to move left, and the right side to move right!

>This part of the game was designed to be fairly simple to complete for someone with full vision, but as color is a primary differentiator (by design), it may be more difficult for some.

When you're ready, you can [continue to the next part](@next)
*/

import PlaygroundSupport

PlaygroundPage.current.liveView = gameView()
/*:
[Next](@next)

For Reference:
>This is a powerup:
>
>![powerup](colorPowerup.png)

>This is a powerdown:
>
>![powerdown](colorPowerdown.png)
*/
