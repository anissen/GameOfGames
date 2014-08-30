package com.andersnissen.games;

import com.andersnissen.ColorScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxPath;

using flixel.util.FlxSpriteUtil;

import flixel.tweens.FlxTween;
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
        controls = "Drag";

        var margin = 0;
        var topLeft = new FlxPoint(margin, margin);
        var topRight = new FlxPoint(Settings.WIDTH - margin, margin);
        var bottomLeft = new FlxPoint(margin, Settings.HEIGHT - margin);
        var bottomRight = new FlxPoint(Settings.WIDTH - margin, Settings.HEIGHT - margin);

        laserPoint = new FlxSprite(topLeft.x - 32, topLeft.y - 32);
        laserPoint.makeGraphic(64, 64, ColorScheme.TRANSPARENT, true);
        laserPoint.drawCircle(32, 32, 32, ColorScheme.BLACK);
        laserPoint.drawCircle(32, 32, 30, ColorScheme.RED);
        add(laserPoint);

        laserPoint2 = new FlxSprite(topRight.x - 32, topRight.y - 32);
        laserPoint2.makeGraphic(64, 64, ColorScheme.TRANSPARENT, true);
        laserPoint2.drawCircle(32, 32, 32, ColorScheme.BLACK);
        laserPoint2.drawCircle(32, 32, 30, ColorScheme.RED);
        add(laserPoint2);

        playerSprite = new FlxSprite(Settings.WIDTH / 2 - 32, Settings.HEIGHT / 2 - 32);
        playerSprite.makeGraphic(64, 64, ColorScheme.BLACK, true);
        playerSprite.drawRect(2, 2, 60, 60, ColorScheme.randomExcept([this.backgroundColor]));
        playerSprite.centerOffsets();
        add(playerSprite);

        laserSprite = new FlxSprite(32, 0);
        laserSprite.makeGraphic(Settings.WIDTH - 64, 3, ColorScheme.RED);
        laserSprite.alpha = 0.8;
        add(laserSprite);

        laserBeamSprite = new FlxSprite(32, 0);
        laserBeamSprite.makeGraphic(Settings.WIDTH - 64, 10, ColorScheme.TRANSPARENT);
        laserBeamSprite.drawLine(5, 5, Settings.WIDTH - 64 - 5, 5, { color: ColorScheme.RED, thickness: 10 });
        laserBeamSprite.drawLine(5, 5, Settings.WIDTH - 64 - 5, 5, { color: ColorScheme.WHITE, thickness: 8 });
        add(laserBeamSprite);

        var path = new FlxPath(laserPoint, [bottomLeft, topLeft, bottomLeft, topLeft], 250 * speed);
        var path2 = new FlxPath(laserPoint2, [bottomRight, topRight, bottomRight, topRight], 250 * speed);

        laserTimer = new FlxTimer(0.8 / speed, makeLaser, 20);
    }

    override public function end() :Void
    {
        laserTimer.destroy();
    }
    
    override public function update(elapsed :Float) :Void
    {
        super.update(elapsed);

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
        laserBeamSprite.scale.y = 1;
        FlxTween.tween(laserBeamSprite.scale, { y: 0 }, 0.5);
        laserBeamSprite.fadeOut(0.5);
        
        FlxG.camera.flash(ColorScheme.RED, 0.2);
        // FlxG.camera.shake(0.01 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */);

        if (FlxG.overlap(laserBeamSprite, playerSprite)) {
            lose();
        } else {
            success(playerSprite.getMidpoint());
        }
    }
}
