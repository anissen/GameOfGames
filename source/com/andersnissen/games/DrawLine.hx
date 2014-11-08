package com.andersnissen.games;

import com.andersnissen.ColorScheme;
import com.andersnissen.ShapeBuilder;
import com.andersnissen.states.GameState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using flixel.util.FlxSpriteUtil;

class DrawLine extends GameState
{
    var MAX_LINES :Int;
    var lineDots :FlxSpriteGroup;
    var lineSprite :FlxSprite;

    override function setup() :Void
    {
        name = "Line Drawer";
        description = "???";
        controls = "Drag";
        hints = "CONNECT THE DOTS!";
        winningCondition = WinningCondition.CompleteObjective;

        MAX_LINES = FlxG.random.int(8, 16);

        lineDots = new FlxSpriteGroup();
        var point = { x: FlxG.random.float(32, Settings.WIDTH - 32), y: FlxG.random.float(32, Settings.HEIGHT - 32) };
        var vector = { x: FlxG.random.float(20, 25) * FlxG.random.sign(), y: FlxG.random.float(20, 25) * FlxG.random.sign() };
        lineDots.add(ShapeBuilder.createCircle(point.x, point.y, 32, ColorScheme.randomExcept(ColorScheme.BLACK, this.backgroundColor)));

        var lineCount = 0;
        while (lineCount < MAX_LINES) {
            vector.x *= FlxG.random.float(0.8, 1.2);
            vector.y *= FlxG.random.float(0.8, 1.2);
            var tempPoint = { x: point.x + vector.x, y: point.y + vector.y };
            tempPoint.x += vector.x;
            tempPoint.y += vector.y;
            if (tempPoint.x <= 32 || tempPoint.x >= Settings.WIDTH - 32) {
                vector.x *= -1;
                continue;
            }
            if (tempPoint.y <= 32 || tempPoint.y >= Settings.HEIGHT - 32) {
                vector.y *= -1; 
                continue;
            }
            point = tempPoint;

            lineCount++;

            var dot = ShapeBuilder.createCircle(point.x, point.y, 32, ColorScheme.random());
            dot.velocity.x = FlxG.random.float(-5, 5);
            dot.velocity.y = FlxG.random.float(-5, 5);
            lineDots.add(dot);
            FlxTween.tween(dot.scale, { x: 0.4, y: 0.4 }, 0.3, { ease: FlxEase.elasticInOut, startDelay: 1.0 -lineCount / MAX_LINES });
        }

        lineSprite = ShapeBuilder.createRect(0, 0, Settings.WIDTH, Settings.HEIGHT, ColorScheme.TRANSPARENT);
        add(lineSprite);
        add(lineDots);

        updateLines();
    }

    function updateLines() {
        lineSprite.fill(ColorScheme.TRANSPARENT);
        if (FlxG.mouse.pressed) {
            var firstDot = lineDots.getFirstAlive();
            if (firstDot != null) {
                var pMouse = FlxG.mouse.getWorldPosition();
                var pDot = firstDot.getMidpoint();
                lineSprite.drawLine(pMouse.x, pMouse.y, pDot.x, pDot.y, { color: ColorScheme.BLACK, thickness: 6 });
                lineSprite.drawLine(pMouse.x, pMouse.y, pDot.x, pDot.y, { color: ColorScheme.GREEN, thickness: 4 });
            }
        }

        var lastDot :FlxSprite = null;
        lineDots.forEachAlive(function(dot :FlxSprite) {
            if (lastDot != null) {
                var pLast = lastDot.getMidpoint();
                var p = dot.getMidpoint();
                lineSprite.drawLine(pLast.x, pLast.y, p.x, p.y, { color: ColorScheme.BLACK, thickness: 6 });
                lineSprite.drawLine(pLast.x, pLast.y, p.x, p.y, { color: ColorScheme.BLUE, thickness: 4 });
            }
            lastDot = dot;
        });
    }

    override function updateGame(elapsed :Float) :Void
    {
        if (FlxG.mouse.pressed) {
            var nextDot = lineDots.getFirstAlive();
            if (nextDot == null) {
                win(FlxG.mouse.getWorldPosition());
            } else if (nextDot.overlapsPoint(FlxG.mouse.getWorldPosition())) {
                success(nextDot.getMidpoint());
                nextDot.kill();
                if (lineDots.countLiving() > 0) {
                    FlxTween.tween(lineDots.getFirstAlive().scale, { x: 0.7, y: 0.7 }, 0.1, { ease: FlxEase.elasticInOut });
                }
            }
        }
        updateLines();
    }
}
