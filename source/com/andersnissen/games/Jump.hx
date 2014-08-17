package com.andersnissen.games;

import com.andersnissen.ColorScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.addons.effects.FlxTrailArea;

import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;

import com.andersnissen.states.GameState;

class Jump extends GameState
{
    var playerSprite :FlxSprite;
    var groundSprite :FlxSprite;
    var obstacles :FlxSpriteGroup;
    var isOnGround :Bool = true;

    override function setup() :Void
    {
        name = "Jump";
        description = "Jump over obstacles";
        controls = "Tab";

        for (i in 0...10) {
            var backgroundSprite = FlxGridOverlay.create(128, 128, Settings.WIDTH + 128, Settings.HEIGHT * 2, true, true, ColorScheme.GRAY, ColorScheme.TRANSPARENT);
            backgroundSprite.x = (Settings.WIDTH + 128) * i;
            backgroundSprite.y = -Settings.HEIGHT;
            add(backgroundSprite);
        }

        groundSprite = new FlxSprite(0, 0);
        groundSprite.makeGraphic(Settings.WIDTH * 2, 64, ColorScheme.PURPLE);
        add(groundSprite);

        playerSprite = new FlxSprite(Settings.WIDTH / 4, -32);
        playerSprite.makeGraphic(32, 32, ColorScheme.MAROON);
        add(playerSprite);

        FlxG.camera.follow(playerSprite);
        FlxG.camera.followLead.x = 15 / speed;

        obstacles = new FlxSpriteGroup();

        var x = 300 * speed;
        do {
            x += (500 + FlxG.random.int(-100, 100)) * speed;

            var width  = FlxG.random.getObject([64, 128]);
            var height = FlxG.random.getObject([64, 128]);
            var y = -height - (FlxG.random.bool(25) ? 32 : 0);
            var color = FlxG.random.getObject([ColorScheme.RED, ColorScheme.ORANGE, ColorScheme.YELLOW]);
            obstacles.add(new FlxSprite(x, y).makeGraphic(width, height, color));
        } while (x < (3500 * speed));

        add(obstacles);
    }

    override function start() :Void
    {
        playerSprite.velocity.x = 500 * speed;
    }

    override function end() :Void
    {
        playerSprite.velocity.x = 0;
    }
  
    override public function update():Void
    {
        super.update();

        if (playerSprite.overlaps(obstacles)) {
            lose(playerSprite.getMidpoint());
        }

        if (playerSprite.overlaps(groundSprite)) {
            playerSprite.velocity.y = 0;
            playerSprite.y = -32 + 1;
            if (!isOnGround) {
                isOnGround = true;
                success(playerSprite.getMidpoint());
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
