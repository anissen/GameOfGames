package games;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxMath;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
import flixel.addons.effects.FlxTrailArea;

import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxPoint;

import states.GameState;

class Jump extends GameState
{
    var playerSprite :FlxSprite;
    var groundSprite :FlxSprite;
    var obstacles :FlxSpriteGroup;
    var isOnGround :Bool = true;

    override public function create() :Void
    {
        name = "Jump";

        var width = 360;
        var height = 640;

        for (i in 0...10) {
            var backgroundSprite = FlxGridOverlay.create(128, 128, width + 128, height * 2, true, true, FlxColor.CHARCOAL, FlxColor.BLACK);
            backgroundSprite.x = (width + 128) * i;
            backgroundSprite.y = -height;
            add(backgroundSprite);
        }

        groundSprite = new FlxSprite(0, 0);
        groundSprite.makeGraphic(width * 2, 64, FlxColor.BROWN);
        add(groundSprite);

        playerSprite = new FlxSprite(width / 4, -32);
        playerSprite.makeGraphic(32, 32, FlxColor.AZURE);
        add(playerSprite);

        FlxG.camera.follow(playerSprite);
        FlxG.camera.followLead.x = 15 / speed;

        obstacles = new FlxSpriteGroup();

        var x = 300 * speed;
        do {
            x += (500 + FlxRandom.intRanged(-100, 100)) * speed;

            var width  = FlxRandom.getObject([64, 128]);
            var height = FlxRandom.getObject([64, 128]);
            var y = -height - (FlxRandom.chanceRoll(25) ? 32 : 0);
            var color = FlxRandom.getObject([FlxColor.RED, FlxColor.YELLOW, FlxColor.CRIMSON]);
            obstacles.add(new FlxSprite(x, y).makeGraphic(width, height, color));
        } while (x < (3500 * speed));

        add(obstacles);

        super.create();
    }

    override function start() :Void
    {
        playerSprite.velocity.x = 500 * speed;
    }

    override function end() :Void
    {
        trace("ended!");
        playerSprite.velocity.x = 0;
    }
  
    override public function update():Void
    {
        super.update();

        if (playerSprite.overlaps(obstacles)) {
            lose();
        }

        if (playerSprite.overlaps(groundSprite)) {
            playerSprite.velocity.y = 0;
            playerSprite.y = -32 + 1;
            if (!isOnGround) {
                isOnGround = true;
                // success();
                FlxG.camera.shake(0.02 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */);
            }

            if (!gameActive) return; // TODO: Put this check in the abstract input handler

            #if !FLX_NO_TOUCH
            for (touch in FlxG.touches.list)
            {
                if (touch.pressed)
                {
                   playerSprite.velocity.y -= 1500;
                   isOnGround = false;
                   break; 
                }
            }
            #else
            if (FlxG.mouse.justPressed) {
                playerSprite.velocity.y -= 1500;
                isOnGround = false;
            }
            #end
        }
        else {
            playerSprite.velocity.y += 80;
        }

        if (playerSprite.x > 8000) playerSprite.x = 0;
        groundSprite.x = playerSprite.x - 100;
    }
}
