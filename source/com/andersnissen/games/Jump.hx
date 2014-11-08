package com.andersnissen.games;

import com.andersnissen.ColorScheme;
import com.andersnissen.Settings;
import com.andersnissen.ShapeBuilder;
import flixel.FlxCamera.FlxCameraShakeDirection;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.group.FlxSpriteGroup;

import com.andersnissen.states.GameState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Jump extends GameState
{
    var playerSprite :FlxSprite;
    var groundSprite :FlxSprite;
    var obstacles :FlxSpriteGroup;
    var isOnGround :Bool = true;
    var groundY :Int;

    override function setup() :Void
    {
        name = "Jump";
        description = "Jump over obstacles";
        controls = "Tap";
        hints = "JUMP!";

        var colorPool = new ColorPool();

        groundY = Settings.HEIGHT - 192;

        groundSprite = ShapeBuilder.createRect(-10, groundY, Settings.WIDTH + 20, 64, colorPool.pickColor());
        add(groundSprite);

        playerSprite = ShapeBuilder.createRect(32, groundY - 32, 32, 32, colorPool.pickColor());
        add(playerSprite);

        obstacles = new FlxSpriteGroup();

        var x = 150 + 50 * speed;
        do {
            x += (500 + FlxG.random.int(-100, 100)) * speed;

            var width  = FlxG.random.getObject([64, 128]);
            var height = FlxG.random.getObject([64, 128]);
            var y = groundY -height - (FlxG.random.bool(25) ? 32 : 0);
            var color = ColorScheme.randomExcept([this.backgroundColor, ColorScheme.GREEN]);
            obstacles.add(ShapeBuilder.createRect(x, y, width, height, color));
        } while (x < (4000 * speed));

        addSpriteGroup(obstacles);
      
        obstacles.velocity.x = -400 + (-10 * speed);
    }

    override function updateGame(elapsed :Float) :Void
    {
        if (playerSprite.overlaps(obstacles)) {
            lose(playerSprite.getMidpoint());
        }

        if (playerSprite.overlaps(groundSprite)) {
            playerSprite.velocity.y = 0;
            playerSprite.y = groundY - 32 + 1;
            if (!isOnGround) {
                isOnGround = true;
                success(playerSprite.getMidpoint());
                FlxG.camera.shake(0.02 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */, false, FlxCameraShakeDirection.X_AXIS);
            }

            if (FlxG.mouse.justPressed) {
                playerSprite.velocity.y -= 1400 + 90 * speed;
                FlxTween.tween(playerSprite, { angle: playerSprite.angle - 180 }, 0.4, { ease: FlxEase.quadInOut });
                isOnGround = false;
            }
        }
        else {
            playerSprite.velocity.y += 3800 * elapsed;
        }
    }
}
