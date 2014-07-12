package games;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
import flixel.group.FlxSpriteGroup;
import states.GameState;

using flixel.util.FlxSpriteUtil;

class CollectDots extends GameState
{
    var dotSprites :FlxSpriteGroup;
    var dotsToCollect :Array<FlxSprite>;
    var cellSize :Int = 80;
    var radius :Int = 40;

    override public function create() :Void
    {
        name = "Collect The Dots";
        description = "Collect all the RED!";
        winningCondition = WinningCondition.CompleteObjective;

        dotSprites = new FlxSpriteGroup();
        dotsToCollect = new Array<FlxSprite>();

        var dotColors = [FlxColor.GREEN, FlxColor.GOLDEN, FlxColor.MAGENTA];

        var collectableDotMap :Array<Array<Bool>> = [ for (y in 0...7) [ for (x in 0...4) false ]];
        var collectableDotCount = 0;
        while (collectableDotCount < 10) {
            var x = FlxRandom.intRanged(0, 3);
            var y = FlxRandom.intRanged(0, 6);
            if (collectableDotMap[x][y] == false) {
                collectableDotMap[x][y] = true;
                collectableDotCount++;
            }
        }

        for (y in 0...7) {
            for (x in 0...4) {
                var dot = new FlxSprite(x * cellSize + (x + 1) * 8, y * cellSize + (y + 1) * 8);
                dot.makeGraphic(cellSize, cellSize, FlxColor.TRANSPARENT, true);
                var isCollectableDot = collectableDotMap[x][y];
                var color;
                if (isCollectableDot) {
                    color = FlxColor.RED;
                    dotsToCollect.push(dot);
                } else {
                    color = FlxRandom.getObject(dotColors);
                }
                dot.drawCircle(cellSize / 2, cellSize / 2, radius, color);
                dotSprites.add(dot);
            }
        }

        add(dotSprites);

        super.create();
    }

    override public function update():Void
    {
        super.update();

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

    function dotTouched(dot :FlxSprite, point :flixel.util.FlxPoint)
    {
        if (point.distanceTo(dot.getMidpoint()) > radius * 0.9) return;

        var correctDot = (dotsToCollect.indexOf(dot) > -1);
        if (!correctDot) {
            lose();
            return;
        }

        dotsToCollect.remove(dot);
        dot.kill();

        success();
        // FlxG.camera.shake(0.01 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */);

        if (dotsToCollect.length == 0) {
            win();
        }
    }
}
