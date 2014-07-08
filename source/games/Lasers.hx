package games;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.*;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

using flixel.util.FlxSpriteUtil;

import states.GameState;

class Lasers extends GameState
{
    var laserPoint :FlxSprite;
    var laserPoint2 :FlxSprite;
    var playerSprite :FlxSprite;
    var laserSprite :FlxSprite;

    override public function create() :Void
    {
        name = "Lasers";
        description = "Avoid the laser";

        var margin = 0;
        var pointA = new FlxPoint(margin, margin);
        var pointB = new FlxPoint(margin, FlxG.worldBounds.height - margin);
        var pointC = new FlxPoint(FlxG.worldBounds.width - margin, FlxG.worldBounds.height - margin);
        var pointD = new FlxPoint(FlxG.worldBounds.width - margin, margin);

        laserPoint = new FlxSprite(pointA.x - 32, pointA.y - 32);
        laserPoint.makeGraphic(64, 64, FlxColor.TRANSPARENT, true);
        laserPoint.drawCircle(32, 32, 32, FlxColor.RED);
        add(laserPoint);

        laserPoint2 = new FlxSprite(pointC.x - 32, pointC.y - 32);
        laserPoint2.makeGraphic(64, 64, FlxColor.TRANSPARENT, true);
        laserPoint2.drawCircle(32, 32, 32, FlxColor.RED);
        add(laserPoint2);

        playerSprite = new FlxSprite(FlxG.worldBounds.width / 2, 400);
        playerSprite.makeGraphic(64, 64, FlxColor.BLUE, true);
        playerSprite.centerOffsets();
        add(playerSprite);

        laserSprite = new FlxSprite(0, 0);
        laserSprite.makeGraphic(Math.floor(FlxG.worldBounds.width), Math.floor(FlxG.worldBounds.height), FlxColor.TRANSPARENT);
        add(laserSprite);

        var path = new FlxPath(laserPoint, [pointA, pointB, pointC, pointD], 350);
        var path2 = new FlxPath(laserPoint2, [pointC, pointD, pointA, pointB], 350);

        var laserTimer = new FlxTimer(0.5, makeLaser, 20);

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
        var lineStyle :LineStyle = { color: FlxColor.RED, thickness: 10 };
        
        laserSprite.alpha = 1;
        laserSprite.fill(FlxColor.TRANSPARENT);
        laserSprite.blend = openfl.display.BlendMode.ADD;
        laserSprite.drawLine(laserPoint.getMidpoint().x, laserPoint.getMidpoint().y, laserPoint2.getMidpoint().x, laserPoint2.getMidpoint().y, lineStyle);
        laserSprite.fadeOut();
        FlxG.camera.shake(0.01 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */);

        if (FlxG.pixelPerfectOverlap(laserSprite, playerSprite, 1)) {
            lose();
        }
    }
}
