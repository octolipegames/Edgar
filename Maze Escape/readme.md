# Source files

## Main class

* **plpViewController.m** deals with user interaction when the App is launched: New Game / Credits / Resume, as well as “pause” and “repeat level” in-game buttons

* **plpMyScene.m** renders the scene and deals with touch actions while the game runs

## Objects

* **plpHero.m**: class for our main character Edgar

* **plpEnemy.m**: aliens

* **plpItem.m**: pickup items (uranium cells and boni)

* **plpPlatforms.m**: horizontal and vertical moving platforms

* **plpTrain.m**: little trains (actually minecarts)

## Tilemap parser

**JSTileMap.m** load .tmx tilemaps (we make them using the GPL editor [Tiled](http://www.mapeditor.org).

MIT-licensed code by Jeremy Stone and Christopher LaPollo -- GitHub repo: https://github.com/slycrel/JSTileMap