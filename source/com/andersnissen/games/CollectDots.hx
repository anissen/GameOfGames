package com.andersnissen.games;

import com.andersnissen.ColorScheme;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.group.FlxSpriteGroup;
import com.andersnissen.states.GameState;

using flixel.util.FlxSpriteUtil;

class CollectDots extends GameState
{
    var dotSprites :FlxSpriteGroup;
    var dotsToCollect :Array<FlxSprite>;
    var cellSize :Int = 80;
    var radius :Int = 40;

    override function setup() :Void
    {
        name = "Collect The Dots";
        description = "Collect all the RED!";
        controls = "Tap/Drag";
        hints = "COLLECT RED!";
        winningCondition = WinningCondition.CompleteObjective;

        dotSprites = new FlxSpriteGroup();
        dotsToCollect = new Array<FlxSprite>();

        var collectableDotMap :Array<Array<Bool>> = [ for (x in 0...4) [ for (y in 0...7) false ]];
        var collectableDotCount = 0;
        while (collectableDotCount < 10) {
            var x = FlxG.random.int(0, 3);
            var y = FlxG.random.int(0, 6);
            if (collectableDotMap[x][y] == false) {
                collectableDotMap[x][y] = true;
                collectableDotCount++;
            }
        }

        for (y in 0...7) {
            for (x in 0...4) {
                var dot = new FlxSprite(x * cellSize + (x + 1) * 8, y * cellSize + (y + 1) * 8);
                dot.makeGraphic(cellSize, cellSize, ColorScheme.TRANSPARENT, true);
                var isCollectableDot = collectableDotMap[x][y];
                var color;
                if (isCollectableDot) {
                    color = ColorScheme.RED;
                    dotsToCollect.push(dot);
                } else {
                    color = ColorScheme.randomExcept([ColorScheme.RED]);
                }
                dot.drawCircle(cellSize / 2, cellSize / 2, radius, ColorScheme.BLACK);
                dot.drawCircle(cellSize / 2, cellSize / 2, radius - 2, color);
                dotSprites.add(dot);
            }
        }

        addSpriteGroup(dotSprites);
    }

    override function updateGame(elapsed :Float):Void
    {
        #if !FLX_NO_TOUCH
            for (touch in FlxG.touches.list)
            {
                if (touch.pressed)
                {
                    dotSprites.forEachAlive(function(dot :FlxSprite) {
                        if (!touch.overlaps(dot)) return;
                        dotTouched(dot, touch.getWorldPosition());
                    });
                }
            }
        #else
            if (FlxG.mouse.pressed) {
                dotSprites.forEachAlive(function(dot :FlxSprite) {
                    if (!dot.overlapsPoint(FlxG.mouse.getWorldPosition())) return;
                    dotTouched(dot, FlxG.mouse.getWorldPosition());
                });
            }
        #end
    }

    function dotTouched(dot :FlxSprite, point :FlxPoint)
    {
        if (point.distanceTo(dot.getMidpoint()) > radius * 0.9) return;

        var correctDot = (dotsToCollect.indexOf(dot) > -1);
        if (!correctDot) {
            lose();
            return;
        }

        dotsToCollect.remove(dot);
        dot.kill();

        success(point);

        if (dotsToCollect.length == 0) {
            win();
        }
    }
}
