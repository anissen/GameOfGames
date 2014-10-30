package com.andersnissen.games;

import com.andersnissen.ColorScheme;
import com.andersnissen.ShapeBuilder;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.group.FlxSpriteGroup;
import com.andersnissen.states.GameState;
import flixel.math.FlxVelocity;
import flixel.text.FlxText;

using flixel.util.FlxSpriteUtil;

class RobotVacuumCleaner extends GameState
{
    var robotSprite :FlxSprite;
    var directionSprite :FlxSprite;
    var circles :FlxSpriteGroup;
    var vacuumRange :Int = 100;
    var robotRadius :Int = 30;
    var debrisRadius :Int = 20;
    var MAX_CIRCLES :Int;

    override function setup() :Void
    {
        name = "Robot Vacuum Cleaner";
        description = "???";
        controls = "Tap and hold";
        hints = "VACUUM!";
        winningCondition = WinningCondition.CompleteObjective;

        MAX_CIRCLES = FlxG.random.int(2, 6);

        circles = new FlxSpriteGroup();

        var circleCount = 0;
        while (circleCount < MAX_CIRCLES) {
            var x = FlxG.random.float(debrisRadius * 2, Settings.WIDTH - debrisRadius * 2);
            var y = FlxG.random.float(debrisRadius * 2, Settings.HEIGHT - debrisRadius * 2);
            var point = new FlxPoint(x, y);
            if (point.distanceTo(new FlxPoint(Settings.WIDTH / 2, Settings.HEIGHT / 2)) <= vacuumRange) continue;
            var validPosition = true;
            circles.forEach(function(c) {
                if (!validPosition) return;
                if (c.toPoint().distanceTo(point) < debrisRadius * 2)
                    validPosition = false;
            });
            if (!validPosition) continue;

            var circle = ShapeBuilder.createCircle(x, y, debrisRadius, ColorScheme.random());
            circles.add(circle);
            circleCount++;
        }
        addSpriteGroup(circles);

        var color = ColorScheme.random();
        robotSprite = ShapeBuilder.createCircle(Settings.WIDTH / 2, Settings.HEIGHT / 2, robotRadius, color);
        add(robotSprite);

        directionSprite = ShapeBuilder.createRect(Settings.WIDTH / 2, Settings.HEIGHT / 2, 64, 64, ColorScheme.TRANSPARENT);

        directionSprite.fill(ColorScheme.TRANSPARENT);
        directionSprite.drawLine(32, 32, 16, 64 - 16, { color: ColorScheme.BLACK, thickness: 2 } );
        directionSprite.drawLine(32, 32, 32, 64, { color: ColorScheme.BLACK, thickness: 2 } );
        directionSprite.drawLine(32, 32, 64 - 16, 64 - 16, { color: ColorScheme.BLACK, thickness: 2 } );
        add(directionSprite);

        rotateArrow();
    }

    function rotateArrow() {
        var directionPos = robotSprite.getMidpoint().addPoint(FlxVelocity.velocityFromAngle(robotSprite.angle, robotRadius + 32));
        directionSprite.setPosition(directionPos.x - 32, directionPos.y - 32);
        directionSprite.angle = 270 + flixel.math.FlxAngle.angleBetween(directionSprite, robotSprite, true);
    }

    override function updateGame(elapsed :Float) :Void
    {
        if (FlxG.mouse.pressed) {
            robotSprite.velocity.addPoint(FlxVelocity.velocityFromAngle(robotSprite.angle, 1200 * elapsed));
            wallBounce(robotSprite);
        } else {
            robotSprite.velocity.set(0, 0);
            robotSprite.angle += 300 * elapsed;
        }

        rotateArrow();

        circles.forEachAlive(function(circle) {
            var moveSpeed = (1 / circle.toPoint().distanceTo(robotSprite.toPoint())) * 300000 * elapsed;
            FlxVelocity.moveTowardsObject(circle, robotSprite, moveSpeed);
            if (robotSprite.toPoint().distanceTo(circle.toPoint()) <= robotRadius + debrisRadius) {
                success(circle.toPoint());
                circle.kill();
            }
        });

        if (circles.countLiving() == 0) {
            win();
        }
    }

    function wallBounce(sprite :FlxSprite) {
        if (sprite.x < 0) {
            sprite.x = 0;
            sprite.velocity.x *= -0.5;
        }
        if (sprite.y < 0) {
            sprite.y = 0;
            sprite.velocity.y *= -0.5;
        }
        if (sprite.x > Settings.WIDTH - sprite.width) {
            sprite.x = Settings.WIDTH - sprite.width;
            sprite.velocity.x *= -0.5;
        }
        if (sprite.y > Settings.HEIGHT - sprite.height) {
            sprite.y = Settings.HEIGHT - sprite.height;
            sprite.velocity.y *= -0.5;
        }    
    }
}
