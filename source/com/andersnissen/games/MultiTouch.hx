package com.andersnissen.games;

import com.andersnissen.ColorScheme;
import com.andersnissen.ShapeBuilder;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import com.andersnissen.states.GameState;
import flixel.text.FlxText;

using flixel.util.FlxSpriteUtil;

class MultiTouch extends GameState
{
    var circles :FlxSpriteGroup;
    var texts :FlxSpriteGroup;
    var radius :Int = 55;
    var touchedCircles :Array<Bool>;
    var MAX_CIRCLES :Int;

    override function setup() :Void
    {
        name = "???";
        description = "Place a finger on each circle";
        controls = "Touch and hold";
        hints = "FINGER TWISTER";
        winningCondition = WinningCondition.CompleteObjective;

        MAX_CIRCLES = FlxG.random.int(2, 4);

        touchedCircles = [for (i in 0...MAX_CIRCLES) false];
        circles = new FlxSpriteGroup();
        texts = new FlxSpriteGroup();

        var circleCount = 0;
        while (circleCount < MAX_CIRCLES) {
            var x = FlxG.random.float(radius * 2, Settings.WIDTH - radius * 2);
            var y = FlxG.random.float(radius * 2, Settings.HEIGHT - radius * 2);
            var validPosition = true;
            circles.forEach(function(c) {
                if (!validPosition) return;
                if (c.toPoint().distanceTo(new FlxPoint(x, y)) < radius * 2)
                    validPosition = false;
            });
            if (!validPosition) continue;

            var circle = ShapeBuilder.createCircle(x, y, radius, ColorScheme.randomExcept([this.backgroundColor, ColorScheme.RED]));
            circles.add(circle);
            circleCount++;

            var text = new FlxText(x, y + radius / 2, radius * 2, '#$circleCount', 36);
            text.color = ColorScheme.WHITE;
            text.alignment = FlxTextAlign.CENTER;
            text.borderColor = ColorScheme.BLACK;
            text.borderStyle = FlxTextBorderStyle.OUTLINE;
            text.borderSize = 1;
            texts.add(text);
        }

        addSpriteGroup(circles);
        addSpriteGroup(texts);
    }

    override function updateGame(elapsed :Float):Void
    {
        #if !FLX_NO_TOUCH
        for (touch in FlxG.touches.list)
        {
            if (touch.touchPointID >= circles.countLiving()) return;
            if (touch.justPressed)
            {
                var circle = circles.members[touch.touchPointID];
                if (touch.getWorldPosition().distanceTo(circle.getMidpoint()) <= radius) {
                    circleTouched(touch.touchPointID, touch.getWorldPosition());
                }
            } else if (touch.justReleased) {
                touchedCircles[touch.touchPointID] = false;
            }
        }
        #else
        if (FlxG.mouse.justPressed) {
            var circleIndex = 0;
            circles.forEachAlive(function(circle :FlxSprite) {
                if (FlxG.mouse.getWorldPosition().distanceTo(circle.getMidpoint()) <= radius) {
                    circleTouched(circleIndex, FlxG.mouse.getWorldPosition());
                }
                circleIndex++;
            });
        }
        #end
    }

    function circleTouched(index :Int, point :FlxPoint)
    {
        // already touched
        if (touchedCircles[index]) return;

        // if any previous circle is missing, abort
        for (touchIndex in 0...index) {
            if (!touchedCircles[touchIndex]) {
                return;
            }
        }
        touchedCircles[index] = true;

        success(point);

        for (touched in touchedCircles) {
            if (!touched) return;
        }
        win();
    }
}
