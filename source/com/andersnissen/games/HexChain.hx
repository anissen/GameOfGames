package com.andersnissen.games;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.group.FlxSpriteGroup;
import com.andersnissen.states.GameState;

using flixel.util.FlxSpriteUtil;

class HexChain extends GameState
{
    var hexSprites :FlxSpriteGroup;
    var hexToCollect :Array<FlxSprite>;
    var hexRadius :Int = 52;

    var chainLength :Int = 5;
    var chain :Array<FlxSprite>;
    var chainSprite :FlxSprite;

    override function setup() :Void
    {
        name = "Hex Chain";
        description = "Make a chain of 5!";
        winningCondition = WinningCondition.CompleteObjective;

        hexSprites = new FlxSpriteGroup();
        hexToCollect = new Array<FlxSprite>();

        chain = new Array<FlxSprite>();

        var collectableHexMap :Array<Array<Bool>> = [ for (x in 0...4) [ for (y in 0...7) false ]];
        var collectableHexCount = 0;
        
        function makeChain(x :Int, y :Int) {
            if (collectableHexCount > 8) return;

            if (x < 0 || x > 3) return;
            if (y < 0 || y > 6) return;
            if (x == 3 && y % 2 == 0) return;
            if (collectableHexMap[x][y] == true) return;

            collectableHexMap[x][y] = true;
            collectableHexCount++;
            if (collectableHexCount > 8) return;

            var neighborsX = FlxRandom.shuffleArray([x - 1, x, x + 1], 5);
            var neighborsY = FlxRandom.shuffleArray([y - 1, y, y + 1], 5);
            for (nX in neighborsX) {
                for (nY in neighborsY) {
                    if (collectableHexCount <= 8)
                        makeChain(nX, nY);
                }
            }
        }

        var x = FlxRandom.intRanged(1, 2);
        var y = FlxRandom.intRanged(2, 4);
        makeChain(x, y);

        var margin = 2;
        var hexHeight = hexRadius * 2;
        var verticalDistance = 3/4 * hexHeight + margin;
        var hexWidth = Math.sqrt(3) / 2 * hexHeight;
        var horizontalDistance = hexWidth + margin;

        var polys = new Array<FlxPoint>();
        for (edge in 0...6) {
            var angle = 2 * Math.PI / 6 * (edge + 0.5);
            var posX = hexWidth / 2 + Math.cos(angle) * hexRadius;
            var posY = hexHeight / 2 + Math.sin(angle) * hexRadius;
            polys.push(new FlxPoint(posX, posY));
        }

        for (y in 0...7) {
            for (x in 0...4) {
                if (x == 3 && y % 2 == 0) continue;
                
                var hex = new FlxSprite((y % 2 == 0 ? horizontalDistance / 2 : 0) + x * horizontalDistance, y * verticalDistance);
                hex.makeGraphic(Math.ceil(hexWidth), Math.ceil(hexHeight), FlxColor.TRANSPARENT, true);

                var isCollectableHex = collectableHexMap[x][y];
                var color;
                if (isCollectableHex) {
                    color = FlxColor.BLUE;
                    hexToCollect.push(hex);
                } else {
                    color = FlxRandom.getObject([FlxColor.RED, FlxColor.GREEN, FlxColor.YELLOW, FlxColor.CYAN]);
                }

                hex.drawPolygon(polys.copy(), color);

                // flixel.tweens.FlxTween.tween(hex.scale, { x: -1 }, 1, { startDelay: (y + x) / 10 });
                hexSprites.add(hex);
            }
        }

        add(hexSprites);

        chainSprite = new FlxSprite(0, 0);
        chainSprite.makeGraphic(Settings.WIDTH, Settings.HEIGHT, FlxColor.TRANSPARENT);
        add(chainSprite);
    }

    override public function update() :Void
    {
        if (!gameActive) return;

        super.update();

        #if !FLX_NO_TOUCH
        for (touch in FlxG.touches.list)
        {
            if (touch.pressed)
            {
                hexSprites.forEachAlive(function(hex :FlxSprite) {
                    if (!touch.overlaps(hex)) return;
                    hexTouched(hex, touch.getWorldPosition());
                });
            }
        }
        #else
        if (FlxG.mouse.pressed) {
            hexSprites.forEachAlive(function(hex :FlxSprite) {
                if (!hex.overlapsPoint(FlxG.mouse.getWorldPosition())) return;
                hexTouched(hex, FlxG.mouse.getWorldPosition());
            });
        }
        #end
    }

    function hexTouched(hex :FlxSprite, point :flixel.util.FlxPoint)
    {
        if (point.distanceTo(hex.getMidpoint()) > hexRadius * 0.9) return;

        var hexPositionInChain = chain.indexOf(hex);
        // Mouse/finger hovering over the last chained hex
        if (hexPositionInChain > -1 && hexPositionInChain == chain.length - 1) return;
        var isBacktracking = hexPositionInChain > -1;
        if (isBacktracking) {
            // Restore removed hexes when backtracking
            while (chain[chain.length - 1] != hex) {
                var oldHex = chain.pop();
                FlxTween.tween(oldHex, { alpha: 1 }, 0.4);
                FlxTween.tween(oldHex.scale, { x: 1, y: 1 }, 0.4);
            }
        } else {
            // Only chain adjacent hexes (i.e. with distance <= hexRadius * 2)
            if (chain.length > 0 && chain[chain.length - 1].getMidpoint().distanceTo(hex.getMidpoint()) > hexRadius * 3) return;

            var correctHex = (hexToCollect.indexOf(hex) > -1);
            if (!correctHex) {
                lose();
                return;
            }

            chain.push(hex);
            FlxTween.tween(hex, { alpha: 0 }, 0.4);
            FlxTween.tween(hex.scale, { x: 0, y: 0 }, 0.4);

            success(hex.getMidpoint());

            if (chain.length == hexToCollect.length) {
                win();
            }
        }

        chainSprite.fill(FlxColor.TRANSPARENT);
        // Draw a dot if there is only one hex in the chain
        if (chain.length == 1) {
            chainSprite.drawCircle(chain[0].getMidpoint().x, chain[0].getMidpoint().y, hexRadius / 2, FlxColor.BLACK);
            chainSprite.drawCircle(chain[0].getMidpoint().x, chain[0].getMidpoint().y, hexRadius / 2 - 5, FlxColor.YELLOW);
        }
        for (chainIndex in 1...chain.length) {
            chainSprite.drawLine(chain[chainIndex - 1].getMidpoint().x, chain[chainIndex - 1].getMidpoint().y, chain[chainIndex].getMidpoint().x, chain[chainIndex].getMidpoint().y, { color: FlxColor.BLACK, thickness: hexRadius } );
        }
        for (chainIndex in 1...chain.length) {
            chainSprite.drawLine(chain[chainIndex - 1].getMidpoint().x, chain[chainIndex - 1].getMidpoint().y, chain[chainIndex].getMidpoint().x, chain[chainIndex].getMidpoint().y, { color: FlxColor.YELLOW, thickness: hexRadius - 5 } );
        }
    }
}
