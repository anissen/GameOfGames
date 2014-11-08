package com.andersnissen.games;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
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

    var CHAIN_LENGTH = 12;

    override function setup() :Void
    {
        name = "Hex Chain";
        description = "Make a chain of all BLUE";
        controls = "Drag";
        hints = "CHAIN BLUE";
        winningCondition = WinningCondition.CompleteObjective;

        hexSprites = new FlxSpriteGroup();
        hexToCollect = new Array<FlxSprite>();

        chain = new Array<FlxSprite>();

        var collectableHexMap :Array<Array<Bool>> = [ for (x in 0...4) [ for (y in 0...7) false ]];
        var collectableHexCount = 0;

        // Using the EVEN r (row) algorithm from http://www.redblobgames.com/grids/hexagons/#neighbors
        function getNeighbor(x :Int, y: Int, direction :Int) {
            var neighbors = [
               [ [ 1,  0], [ 1, -1], [ 0, -1],
                 [-1,  0], [ 0,  1], [ 1,  1] ],
               [ [ 1,  0], [ 0, -1], [-1, -1],
                 [-1,  0], [-1,  1], [ 0,  1] ]
            ];
            var d = neighbors[y & 1][direction];
            return { x: x + d[0], y: y + d[1] };
        }

        function canMoveToNeighbor(x :Int, y :Int) :Bool {
            if (x < 0 || x > 3) return false;
            if (y < 0 || y > 6) return false;
            if (x == 3 && y % 2 == 0) return false;
            if (collectableHexMap[x][y] == true) return false;
            return true;
        }

        function makeChain(x :Int, y :Int) {
            collectableHexMap[x][y] = true;
            collectableHexCount++;

            while (collectableHexCount < CHAIN_LENGTH) {
                var movedChain = false;
                var directions = FlxG.random.shuffleArray([0, 1, 2, 3, 4, 5], 15);
                for (d in directions) {
                    var neighbor = getNeighbor(x, y, d);
                    if (canMoveToNeighbor(neighbor.x, neighbor.y)) {
                        x = neighbor.x;
                        y = neighbor.y;
                        collectableHexMap[x][y] = true;
                        collectableHexCount++;
                        movedChain = true;
                        break;
                    }
                }
                if (!movedChain) return;
            }
        }

        var x = FlxG.random.int(0, 2);
        var y = FlxG.random.int(1, 5);
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
                hex.makeGraphic(Math.ceil(hexWidth), Math.ceil(hexHeight), ColorScheme.TRANSPARENT, true);

                var isCollectableHex = collectableHexMap[x][y];
                var color;
                if (isCollectableHex) {
                    color = ColorScheme.BLUE;
                    hexToCollect.push(hex);
                } else {
                    color = ColorScheme.randomExcept([ColorScheme.BLUE]);
                }

                hex.drawPolygon(polys.copy(), color, { color: ColorScheme.BLACK, thickness: 2.0 });
                hexSprites.add(hex);
            }
        }

        addSpriteGroup(hexSprites);

        chainSprite = new FlxSprite(0, 0);
        chainSprite.makeGraphic(Settings.WIDTH, Settings.HEIGHT, ColorScheme.TRANSPARENT);
        add(chainSprite);
    }

    override function updateGame(elapsed :Float) :Void
    {
        if (FlxG.mouse.pressed) {
            hexSprites.forEachAlive(function(hex :FlxSprite) {
                if (!hex.overlapsPoint(FlxG.mouse.getWorldPosition())) return;
                hexTouched(hex, FlxG.mouse.getWorldPosition());
            });
        } else if (FlxG.mouse.justReleased) {
            chainSprite.fill(ColorScheme.TRANSPARENT);
            while (chain.length > 0) {
                var hex = chain.pop();
                FlxTween.tween(hex, { alpha: 1 }, 0.4);
                FlxTween.tween(hex.scale, { x: 1, y: 1 }, 0.4);
            }
        }
    }

    function hexTouched(hex :FlxSprite, point :FlxPoint)
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
                // lose();
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

        chainSprite.fill(ColorScheme.TRANSPARENT);
        // Draw a dot if there is only one hex in the chain
        if (chain.length == 1) {
            chainSprite.drawCircle(chain[0].getMidpoint().x, chain[0].getMidpoint().y, hexRadius / 2, ColorScheme.BLACK);
            chainSprite.drawCircle(chain[0].getMidpoint().x, chain[0].getMidpoint().y, hexRadius / 2 - 5, ColorScheme.ORANGE);
        }
        for (chainIndex in 1...chain.length) {
            chainSprite.drawLine(chain[chainIndex - 1].getMidpoint().x, chain[chainIndex - 1].getMidpoint().y, chain[chainIndex].getMidpoint().x, chain[chainIndex].getMidpoint().y, { color: ColorScheme.BLACK, thickness: hexRadius } );
        }
        for (chainIndex in 1...chain.length) {
            chainSprite.drawLine(chain[chainIndex - 1].getMidpoint().x, chain[chainIndex - 1].getMidpoint().y, chain[chainIndex].getMidpoint().x, chain[chainIndex].getMidpoint().y, { color: ColorScheme.ORANGE, thickness: hexRadius - 5 } );
        }
    }
}
