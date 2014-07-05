package games;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
import flixel.group.FlxSpriteGroup;
import states.GameState;

using flixel.util.FlxSpriteUtil;

class ConnectDots extends GameState
{
    var dotSprites :FlxSpriteGroup;
    var dotsToCollect :Array<FlxSprite>;
    var cellSize :Int = 80;
    var radius :Int = 40;

    override public function create() :Void
    {
        name = "Collect The Dots";
        description = "Collect all the BLUE!";
        winningCondition = WinningCondition.CompleteObjective;

        dotSprites = new FlxSpriteGroup();
        dotsToCollect = new Array<FlxSprite>();

        for (y in 0...7) {
            for (x in 0...4) {
                var dot = new FlxSprite(x * cellSize + (x + 1) * 8, y * cellSize + (y + 1) * 8);
                dot.makeGraphic(cellSize, cellSize, FlxColor.TRANSPARENT, true);
                if (FlxRandom.chanceRoll(30 - speed * 10)) { // TODO: Change this
                    dot.drawCircle(cellSize / 2, cellSize / 2, radius,  FlxColor.BLUE);
                    dotsToCollect.push(dot);
                } else {
                    dot.drawCircle(cellSize / 2, cellSize / 2, radius, FlxRandom.getObject([FlxColor.GREEN, FlxColor.GOLDEN, FlxColor.MAGENTA]));
                }
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

        if (dotsToCollect.length == 0) {
            win();
        }
    }
}
