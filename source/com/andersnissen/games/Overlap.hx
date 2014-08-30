package com.andersnissen.games;

import com.andersnissen.ColorScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.*;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

using flixel.util.FlxSpriteUtil;

import flixel.math.FlxRandom;
import com.andersnissen.states.GameState;

class Overlap extends GameState
{
    var rectangles :FlxSpriteGroup;
    var movingRect :FlxSprite;

    override function setup() :Void
    {
        name             = "No Overlap";
        description      = "Avoid overlap";
        controls         = "Drag";
        winningCondition = WinningCondition.CompleteObjective;

        rectangles = new FlxSpriteGroup();

        var rectMap :Array<Array<Int>> = [ for (y in 0...7) [ for (x in 0...4) 0 ]];
        for (i in 0...3) {
            var rectCount = 0;
            var rectsOnThisLayer = 3 - i; // first 3, then 2, then 1
            while (rectCount < rectsOnThisLayer) {
                var x = FlxG.random.int(0, 3);
                var y = FlxG.random.int(0, 6);
                if (rectMap[x][y] == i) {
                    rectMap[x][y]++;
                    rectCount++;

                    var rect = new FlxSprite(x * 96 + FlxG.random.float(-10, 10), y * 96 + FlxG.random.float(-10, 10));
                    var width = FlxG.random.getObject([64, 96]);
                    var height = FlxG.random.getObject([96, 128]);
                    rect.makeGraphic(width, height, ColorScheme.TRANSPARENT, true);
                    rect.drawRect(2, 2, width - 4, height - 4, ColorScheme.random(), { color: ColorScheme.BLACK, thickness: 2.0 });
                    rect.alpha = 0.7;
                    rectangles.add(rect);
                }
            }
        }

        add(rectangles);
    }

    override public function update(elapsed :Float) :Void
    {
        super.update(elapsed);

        #if !FLX_NO_TOUCH
        for (touch in FlxG.touches.list)
        {
            if (touch.pressed)
            {
                if (movingRect == null) {
                    rectangles.forEach(function (rect) {
                        if (movingRect != null) return;
                        if (rect.overlapsPoint(touch.getWorldPosition())) {
                            movingRect = rect;
                        }
                    });
                }
                if (movingRect != null) {
                    movingRect.setPosition(touch.getWorldPosition().x - movingRect.width / 2, touch.getWorldPosition().y - movingRect.height / 2);
                    if (FlxG.overlap(movingRect, rectangles)) {
                        FlxG.camera.shake(0.01 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */);
                    }
                }
            } else if (touch.justReleased) {
                if (!FlxG.overlap(movingRect, rectangles)) {
                    success(movingRect.getMidpoint());
                }

                movingRect = null;
            }
        }
        #else
        if (FlxG.mouse.pressed) {
            var pos = FlxG.mouse.getWorldPosition();
            if (movingRect == null) {
                rectangles.forEach(function (rect) {
                    if (movingRect != null) return;
                    if (rect.overlapsPoint(pos)) {
                        movingRect = rect;
                    }
                });
            }
            if (movingRect != null) {
                movingRect.setPosition(pos.x - movingRect.width / 2, pos.y - movingRect.height / 2);
                if (FlxG.overlap(movingRect, rectangles)) {
                    FlxG.camera.shake(0.01 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */);
                }
            }
        } else if (FlxG.mouse.justReleased) {
            if (!FlxG.overlap(movingRect, rectangles)) {
                success(movingRect.getMidpoint());
            }

            movingRect = null;
        }
        #end

        var overlaps = FlxG.overlap(rectangles, rectangles);
        if (!overlaps && movingRect == null) {
            win();
        }
    }
}
