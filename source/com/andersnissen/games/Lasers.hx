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
    var laserBeamSprite :FlxSprite;
    var laserSprite :FlxSprite;

    var laserTimer :FlxTimer;

    override function setup() :Void
    {
        name = "Lasers";
        description = "Avoid the laser";

        var margin = 0;
        var topLeft = new FlxPoint(margin, margin);
        var topRight = new FlxPoint(Settings.WIDTH - margin, margin);
        var bottomLeft = new FlxPoint(margin, Settings.HEIGHT - margin);
        var bottomRight = new FlxPoint(Settings.WIDTH - margin, Settings.HEIGHT - margin);

        laserPoint = new FlxSprite(topLeft.x - 32, topLeft.y - 32);
        laserPoint.makeGraphic(64, 64, FlxColor.TRANSPARENT, true);
        laserPoint.drawCircle(32, 32, 32, FlxColor.BLACK);
        laserPoint.drawCircle(32, 32, 30, FlxColor.RED);
        add(laserPoint);

        laserPoint2 = new FlxSprite(topRight.x - 32, topRight.y - 32);
        laserPoint2.makeGraphic(64, 64, FlxColor.TRANSPARENT, true);
        laserPoint2.drawCircle(32, 32, 32, FlxColor.BLACK);
        laserPoint2.drawCircle(32, 32, 30, FlxColor.RED);
        add(laserPoint2);

        playerSprite = new FlxSprite(Settings.WIDTH / 2, 400);
        playerSprite.makeGraphic(64, 64, FlxColor.BLUE, true);
        playerSprite.centerOffsets();
        add(playerSprite);

        laserSprite = new FlxSprite(32, 0);
        laserSprite.makeGraphic(Settings.WIDTH - 64, 3, FlxColor.RED);
        laserSprite.alpha = 0.8;
        add(laserSprite);

        laserBeamSprite = new FlxSprite(32, 0);
        laserBeamSprite.makeGraphic(Settings.WIDTH - 64, 10, FlxColor.TRANSPARENT);
        laserBeamSprite.drawLine(5, 5, Settings.WIDTH - 64 - 5, 5, { color: FlxColor.RED, thickness: 10 });
        laserBeamSprite.drawLine(5, 5, Settings.WIDTH - 64 - 5, 5, { color: FlxColor.WHITE, thickness: 8 });
        add(laserBeamSprite);

        var path = new FlxPath(laserPoint, [bottomLeft, topLeft, bottomLeft, topLeft], 300 * speed);
        var path2 = new FlxPath(laserPoint2, [bottomRight, topRight, bottomRight, topRight], 300 * speed);

        laserTimer = new FlxTimer(0.8 / speed, makeLaser, 20);
    }
    
    override public function update():Void
    {
        super.update();

        laserSprite.y = laserPoint.getMidpoint().y;

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
        laserBeamSprite.y = laserPoint.getMidpoint().y;
        laserBeamSprite.alpha = 1;
        laserBeamSprite.fadeOut();
        // FlxG.camera.flash(FlxColor.CHARCOAL, 0.1);
        // FlxG.camera.shake(0.01 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */);

        if (FlxG.overlap(laserBeamSprite, playerSprite)) {
            lose();
        } else {
            success(playerSprite.getMidpoint());
        }
    }
}
