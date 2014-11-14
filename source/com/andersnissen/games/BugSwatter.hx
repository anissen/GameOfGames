package com.andersnissen.games;

import com.andersnissen.ColorScheme;
import com.andersnissen.ShapeBuilder;
import com.andersnissen.states.GameState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxVelocity;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using flixel.util.FlxSpriteUtil;
using flixel.math.FlxVelocity;
using flixel.math.FlxAngle;

class BugSwatter extends GameState
{
    var MAX_BUGS :Int;
    var bugs :FlxSpriteGroup;

    override function setup() :Void {
        name = "Bug Swatter";
        description = "???";
        controls = "Tap";
        hints = "SQUASH!";
        winningCondition = WinningCondition.CompleteObjective;

        MAX_BUGS = FlxG.random.int(8, 16);

        bugs = new FlxSpriteGroup();
        for (i in 0 ... MAX_BUGS) spawnBug();
        bugs.forEachAlive(function(bug :FlxSprite) {
            bug.bound(16, Settings.WIDTH - 16, 16, Settings.HEIGHT - 16);
        });
        addSpriteGroup(bugs);
    }

    function spawnBug() {
        var point = { x: FlxG.random.float(32, Settings.WIDTH - 32), y: FlxG.random.float(32, Settings.HEIGHT - 32) };
        var color = ColorScheme.random();
        var bug = new FlxSprite(point.x, point.y)
            .makeGraphic(32 + 16, 64 + 16, ColorScheme.TRANSPARENT)
            // body:
            .drawCircle(8 + 16, 8 + 16, 12, ColorScheme.BLACK)
            .drawCircle(8 + 16, 8 + 32, 12, ColorScheme.BLACK)
            .drawCircle(8 + 16, 8 + 48, 12, ColorScheme.BLACK)
            .drawCircle(8 + 16, 8 + 48, 12 - 2, color)
            .drawCircle(8 + 16, 8 + 32, 12 - 2, color)
            .drawCircle(8 + 16, 8 + 16, 12 - 2, color)
            // eyes:
            .drawCircle(8 + 13, 8 + 13, 3, ColorScheme.BLACK)
            .drawCircle(8 + 19, 8 + 13, 3, ColorScheme.BLACK)
            .drawCircle(8 + 19, 8 + 13, 2, ColorScheme.WHITE)
            .drawCircle(8 + 13, 8 + 13, 2, ColorScheme.WHITE);
        var scale = FlxG.random.float(0.9, 1.4);
        bug.scale.set(scale, scale);
        bug.angle = FlxG.random.float(0, 360);
        bug.angularVelocity = FlxG.random.float(-40, 40);
        bug.velocity.copyFrom(FlxVelocity.velocityFromAngle(90 + bug.angle, -FlxG.random.float(10, 50)));
        bugs.add(bug);
    }

    function killBug(bug :FlxSprite) {
        success(bug.getMidpoint());
        bug.kill();
    }

    function updateBugs() {
        if (FlxG.mouse.justPressed) {
            bugs.forEachAlive(function(bug :FlxSprite) {
                if (bug.overlapsPoint(FlxG.mouse.getWorldPosition())) {
                    killBug(bug);                   
                }
            });
        }

        bugs.forEachAlive(function(bug :FlxSprite) {
            bug.bound(16, Settings.WIDTH - 16, 16, Settings.HEIGHT - 16);
        });

        if (bugs.countLiving() == 0) {
            win();
        }
    }

    override function updateGame(elapsed :Float) :Void {
        updateBugs();
    }
}
