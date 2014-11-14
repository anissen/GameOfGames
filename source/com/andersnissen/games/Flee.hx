package com.andersnissen.games;

import com.andersnissen.ColorScheme;
import com.andersnissen.ShapeBuilder;
import com.andersnissen.states.GameState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using flixel.util.FlxSpriteUtil;
using flixel.math.FlxVelocity;
using flixel.math.FlxAngle;

class Flee extends GameState
{
    // var START_ENEMIES :Int;
    var MAX_ENEMIES :Int;
    var enemies :FlxSpriteGroup;
    var player :FlxSprite;

    override function setup() :Void {
        name = "Flee";
        description = "???";
        controls = "Touch and hold";
        hints = "FLEE!";
        winningCondition = WinningCondition.Survive;

        MAX_ENEMIES = FlxG.random.int(10, 25);
        // START_ENEMIES = FlxG.random.int(0, 3);

        enemies = new FlxSpriteGroup();
        add(enemies);

        player = ShapeBuilder.createRect(Settings.WIDTH / 2, Settings.HEIGHT / 2, 16, 16, colorPool.pickColor());
        add(player);
        
        // for (i in 0 ... START_ENEMIES) spawnEnemy(2.0);
    }

    override function start() {
        new flixel.util.FlxTimer(0.7 / speed, function(_) { spawnEnemy(); }, MAX_ENEMIES /*- START_ENEMIES*/);
    }

    function spawnEnemy(flickerTime :Float = 0.8) {
        var point = { x: FlxG.random.float(32, Settings.WIDTH - 32), y: FlxG.random.float(32, Settings.HEIGHT - 32) };
        var enemy = ShapeBuilder.createTriangle(point.x, point.y, 32, 32, ColorScheme.random());
        enemy.scale.set(0, 0);
        FlxTween.tween(enemy.scale, { x: 1, y: 1 }, 0.3, { ease: FlxEase.elasticInOut });
        add(enemy);
        enemy.flicker(flickerTime / speed, 0.04, true, true, function(_) { remove(enemy); enemies.add(enemy); });
    }

    function updateEnemies() {
        if (FlxG.mouse.pressed) {
            // move player
            player.moveTowardsPoint(FlxG.mouse.getWorldPosition(), 200 * speed);
            player.angle = player.angleBetweenPoint(FlxG.mouse.getWorldPosition(), true);
        } else {
            player.velocity.set(0, 0);
        }

        enemies.forEachAlive(function(enemy :FlxSprite) {
            enemy.moveTowardsObject(player, 100 * speed);
            enemy.angle = 90 + enemy.angleBetweenPoint(player.getMidpoint(), true);
        });

        if (player.overlaps(enemies)) {
            lose(player.getMidpoint());
        }
    }

    override function updateGame(elapsed :Float) :Void {
        updateEnemies();
    }
}