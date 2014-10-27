package com.andersnissen.games;

import com.andersnissen.ColorScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxRandom;
import flixel.addons.effects.FlxTrailArea;

import com.andersnissen.states.GameState;

using flixel.util.FlxSpriteUtil;

class Bounce extends GameState
{
    static inline var BAT_SPEED :Int = 500;
    
    var _bat :FlxSprite;
    var _ball :FlxSprite;
    
    var bottomWall :FlxSprite;
    var walls :FlxSpriteGroup;
    
    var _batWidth :Int = 100;

    var xText :FlxText;
    var yText :FlxText;
    var zText :FlxText;
    var accText :FlxText;
    
    override function setup() :Void
    {
        name = "Breakout";
        description = "Bounce the ball";
        controls = "Drag";
        hints = "BOUNCE!";

        var trailArea = new FlxTrailArea(0, 0, Settings.WIDTH, Settings.HEIGHT);
        trailArea.antialiasing = true;
        
        _bat = new FlxSprite(360 / 2 - _batWidth / 2, 550);
        _bat.makeGraphic(_batWidth, 16, ColorScheme.BLACK);
        _bat.drawRect(1, 1, _batWidth - 2, 10, colorPool.pickColor());
        _bat.immovable = true;
        
        _ball = new FlxSprite(360 / 2, 500);
        _ball.makeGraphic(12, 12, ColorScheme.BLACK);
        _ball.drawRect(1, 1, 10, 10, colorPool.pickColor());
        _ball.elasticity = 1;
        _ball.maxVelocity.set(350, 1000);
        _ball.velocity.x = FlxG.random.float(-100, 100);
        _ball.velocity.y = -1000;
        
        walls = new FlxSpriteGroup();

        var wallColor = colorPool.pickColor();
        
        var wallWidth :Int = 10;
        var leftWall = new FlxSprite(0, 0);
        leftWall.makeGraphic(wallWidth, 640, wallColor);
        leftWall.immovable = true;
        walls.add(leftWall);
        
        var rightWall = new FlxSprite(360 - wallWidth, 0);
        rightWall.makeGraphic(wallWidth, 640, wallColor);
        rightWall.immovable = true;
        walls.add(rightWall);
        
        var topWall = new FlxSprite(0, 0);
        topWall.makeGraphic(360, wallWidth, wallColor);
        topWall.immovable = true;
        walls.add(topWall);
        
        bottomWall = new FlxSprite(0, 640 - 1);
        bottomWall.makeGraphic(640, 200, ColorScheme.TRANSPARENT);
        bottomWall.immovable = true;
        walls.add(bottomWall);
        
        trailArea.add(_ball);

        add(trailArea);
        add(_ball);
        addSpriteGroup(walls);
        add(_bat);
    }
    
    override function updateGame(elapsed :Float) :Void
    {
        _bat.velocity.x = 0;
        _ball.velocity.y += 20 * speed;

        // #if mobile
        // if (FlxG.accelerometer.isSupported) {
        //   _bat.velocity.x = -((1 + FlxG.accelerometer.y / 2) * FlxG.accelerometer.x) * BAT_SPEED;
        // }
        // #end

        if (FlxG.mouse.pressed) {
            if (FlxG.mouse.x > 10 && FlxG.mouse.x < 290)
                _bat.x = FlxG.mouse.x - _batWidth / 2;
        }

        if (FlxG.keys.anyPressed(["LEFT", "A"]) && _bat.x > 10) {
            _bat.velocity.x = - BAT_SPEED;
        }
        else if (FlxG.keys.anyPressed(["RIGHT", "D"]) && _bat.x < 290) {
            _bat.velocity.x = BAT_SPEED;
        }
        
        if (_bat.x < 10) {
            _bat.x = 10;
        }
        
        if (_bat.x > 340 - _batWidth) {
            _bat.x = 340 - _batWidth;
        }
        
        FlxG.collide(_ball, bottomWall, ballLost);
        FlxG.collide(_ball, walls);
        FlxG.collide(_bat, _ball, ping);
    }
    
    private function ballLost(ball :FlxObject, wall :FlxObject) :Void
    {
        lose();
    }
    
    private function ping(bat :FlxObject, ball :FlxObject):Void
    {
        var batmid :Int = Std.int(bat.x) + 20;
        var ballmid :Int = Std.int(ball.x) + 3;
        var diff :Int;
        
        if (ballmid < batmid) {
            // Ball is on the left of the bat
            diff = batmid - ballmid;
            ball.velocity.x = ( -10 * diff);
            ball.angularVelocity = diff * 10;
        }
        else if (ballmid > batmid) {
            // Ball on the right of the bat
            diff = ballmid - batmid;
            ball.velocity.x = (10 * diff);
            ball.angularVelocity = diff * 10;
        }
        else {
            // Ball is perfectly in the middle, add little random X to stop it bouncing up!
            ball.velocity.x = 2 + FlxG.random.int(0, 8);
            ball.angularVelocity = 0;
        }
        ball.velocity.y = -1000;
        success(ball.getMidpoint());
    }
}
