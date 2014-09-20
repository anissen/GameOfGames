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
        controls = "???";
        winningCondition = WinningCondition.CompleteObjective;

        MAX_CIRCLES = FlxG.random.int(5, 10);

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

            var circle = ShapeBuilder.createCircle(x, y, debrisRadius, ColorScheme.randomExcept([ColorScheme.GREEN]));
            circles.add(circle);
            circleCount++;
        }
        addSpriteGroup(circles);

        var color = ColorScheme.random();
        robotSprite = ShapeBuilder.createCircle(Settings.WIDTH / 2, Settings.HEIGHT / 2, robotRadius, color);
        add(robotSprite);

        directionSprite = ShapeBuilder.createRect(Settings.WIDTH / 2, Settings.HEIGHT / 2, 8, 8, color);
        add(directionSprite);
    }

    override public function update(elapsed :Float) :Void
    {
        if (!gameActive) return;
        
        super.update(elapsed);

        if (FlxG.mouse.pressed) {
            robotSprite.velocity.addPoint(FlxVelocity.velocityFromAngle(robotSprite.angle, 20 * Reg.speed));
            robotSprite.bound(0, Settings.WIDTH, 0, Settings.HEIGHT);
            // TODO: Maybe use FlxCollision.createCameraWall
        } else {
            robotSprite.velocity.set(0, 0);
            robotSprite.angle += 200 * elapsed * Reg.speed;
        }

        var directionPos = robotSprite.getMidpoint().addPoint(FlxVelocity.velocityFromAngle(robotSprite.angle, robotRadius));
        directionSprite.setPosition(directionPos.x - 4, directionPos.y - 4);

        circles.forEachAlive(function(circle) {
            if (robotSprite.toPoint().distanceTo(circle.toPoint()) <= vacuumRange) {
                success(circle.toPoint());
                circle.kill();
            }
        });

        if (circles.countLiving() == 0) {
            win();
        }
    }
}
