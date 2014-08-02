package com.andersnissen.games;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.*;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

using flixel.util.FlxSpriteUtil;

import flixel.util.FlxColor;
import flixel.util.FlxRandom;
import com.andersnissen.states.GameState;

class Lasers extends GameState
{
    var laserPoint :FlxSprite;
    var laserPoint2 :FlxSprite;
    var playerSprite :FlxSprite;
    var laserSprite :FlxSprite;
    var clockwise :Bool;

    override function setup() :Void
    {
        name = "Lasers";
        description = "Avoid the laser";

        var margin = 0;
        var pointA = new FlxPoint(margin, margin);
        var pointB = new FlxPoint(margin, Settings.HEIGHT - margin);
        var pointC = new FlxPoint(Settings.WIDTH - margin, Settings.HEIGHT - margin);
        var pointD = new FlxPoint(Settings.WIDTH - margin, margin);

        clockwise = FlxRandom.chanceRoll();
        var point1 = (clockwise ? pointB : pointA);
        var point2 = (clockwise ? pointD : pointC);

        laserPoint = new FlxSprite(point1.x - 32, point1.y - 32);
        laserPoint.makeGraphic(64, 64, FlxColor.TRANSPARENT, true);
        laserPoint.drawCircle(32, 32, 32, FlxColor.RED);
        add(laserPoint);

        laserPoint2 = new FlxSprite(point2.x - 32, point2.y - 32);
        laserPoint2.makeGraphic(64, 64, FlxColor.TRANSPARENT, true);
        laserPoint2.drawCircle(32, 32, 32, FlxColor.RED);
        add(laserPoint2);

        playerSprite = new FlxSprite(Settings.WIDTH / 2, 400);
        playerSprite.makeGraphic(64, 64, FlxColor.BLUE, true);
        playerSprite.centerOffsets();
        add(playerSprite);

        laserSprite = new FlxSprite(0, 0);
        laserSprite.makeGraphic(Settings.WIDTH, Settings.HEIGHT, FlxColor.TRANSPARENT);
        add(laserSprite);

        var path = new FlxPath(laserPoint, (clockwise ? [pointB, pointA, pointD, pointC] : [pointA, pointB, pointC, pointD]), 300 * speed);
        var path2 = new FlxPath(laserPoint2, (clockwise ? [pointD, pointC, pointB, pointA] : [pointC, pointD, pointA, pointB]), 300 * speed);

        var laserTimer = new FlxTimer(0.8 / speed, makeLaser, 20);
    }
    
    override public function update():Void
    {
        super.update();

        #if !FLX_NO_TOUCH
        for (touch in FlxG.touches.list)
        {
            if (touch.pressed)
            {
                playerSprite.setPosition(touch.x - playerSprite.width / 2, touch.y - playerSprite.height / 2);
            }
        }
        #else
        if (FlxG.mouse.pressed) {
            var pos = FlxG.mouse.getWorldPosition();
            playerSprite.setPosition(pos.x - playerSprite.width / 2, pos.y - playerSprite.height / 2);
        }
        #end
    }

    function makeLaser(timer :FlxTimer) :Void
    {
        // var lineStyle :LineStyle = { color: FlxColor.RED, thickness: 10 };
        
        laserSprite.alpha = 1;
        laserSprite.fill(FlxColor.TRANSPARENT);
        laserSprite.blend = openfl.display.BlendMode.ADD;
        laserSprite.drawLine(laserPoint.getMidpoint().x, laserPoint.getMidpoint().y, laserPoint2.getMidpoint().x, laserPoint2.getMidpoint().y, { color: FlxColor.RED, thickness: 10 });
        laserSprite.drawLine(laserPoint.getMidpoint().x, laserPoint.getMidpoint().y, laserPoint2.getMidpoint().x, laserPoint2.getMidpoint().y, { color: FlxColor.WHITE, thickness: 8 });
        laserSprite.fadeOut();
        FlxG.camera.flash(FlxColor.CHARCOAL, 0.1);
        FlxG.camera.shake(0.01 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */);

        laserPoint.flicker(0.4 / speed);
        laserPoint2.flicker(0.4 / speed);

        if (FlxG.pixelPerfectOverlap(laserSprite, playerSprite, 1)) {
            lose();
        } else {
            success(playerSprite.getMidpoint());
        }
    }
}
