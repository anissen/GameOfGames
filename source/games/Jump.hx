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
    private var playerSprite :FlxSprite;
    private var groundSprite :FlxSprite;
    private var obstacles :FlxSpriteGroup;

    override public function create() :Void
    {
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
        playerSprite.velocity.x = 500 * speed;
        add(playerSprite);

        FlxG.camera.follow(playerSprite);
        FlxG.camera.followLead.x = 15 / speed;

        obstacles = new FlxSpriteGroup();
        // obstacles.add(new FlxSprite(800 * speed, -32).makeGraphic(64, 64, FlxColor.YELLOW));
        // obstacles.add(new FlxSprite(1400 * speed, -32).makeGraphic(64, 64, FlxColor.YELLOW));
        // obstacles.add(new FlxSprite(1700 * speed, -64 - 32).makeGraphic(64, 64, FlxColor.RED));
        // obstacles.add(new FlxSprite(2100 * speed, -128 + 32).makeGraphic(64, 128, FlxColor.RED));
        // obstacles.add(new FlxSprite(2600 * speed, -128 + 32).makeGraphic(64, 128, FlxColor.RED));
        // obstacles.add(new FlxSprite(3000 * speed, -128 - 32).makeGraphic(128, 128, FlxColor.RED));
        // obstacles.add(new FlxSprite(3300 * speed, -128 + 32).makeGraphic(128, 128, FlxColor.RED));


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
  
    override public function update():Void
    {
        super.update();

        if (playerSprite.overlaps(obstacles)) {
            // FlxG.camera.flash(FlxColor.RED);
            // playerSprite.x = 0;
            lose();
        }

        if (playerSprite.overlaps(groundSprite)) {
            playerSprite.velocity.y = 0;
            playerSprite.y = -32 + 1;
            #if !FLX_NO_TOUCH
            for (touch in FlxG.touches.list)
            {
                if (touch.pressed)
                {
                   playerSprite.velocity.y -= 1500;
                   break; 
                }
            }
            #else
            if (FlxG.mouse.justPressed) {
                playerSprite.velocity.y -= 1500;
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
