package com.andersnissen.games;

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

import com.andersnissen.states.GameState;

class Bounce extends GameState
{
	static inline var BAT_SPEED :Int = 1500;
	
	var _bat :FlxSprite;
	var _ball :FlxSprite;
	
    var bottomWall :FlxSprite;
	var walls :FlxGroup;
    
    var _batWidth :Int = 100;

    var xText :FlxText;
    var yText :FlxText;
    var zText :FlxText;
    var accText :FlxText;
    
    override function setup() :Void
    {
        name = "Breakout";

        var colors :Array<Int> = [FlxColor.BROWN, FlxColor.BEIGE, FlxColor.CRIMSON, FlxColor.FOREST_GREEN]; // Reg.getColors(43, 3);

        // this.bgColor = colors.shift(); //FlxColor.NAVY_BLUE;

        var trailArea = new FlxTrailArea(0, 0, 360, 640);
        trailArea.antialiasing = true;
        
		_bat = new FlxSprite(360 / 2 - _batWidth / 2, 600);
		_bat.makeGraphic(_batWidth, 12, colors.shift() /* FlxColor.CYAN */);
		_bat.immovable = true;
		
		_ball = new FlxSprite(360 / 2, 500);
		_ball.makeGraphic(12, 12, colors.shift());
		_ball.elasticity = 1;
		_ball.maxVelocity.set(350, 1500);
		_ball.velocity.y = -1500;
		
		walls = new FlxGroup();

        var wallColor = colors.shift();
		
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
		bottomWall.makeGraphic(640, wallWidth, FlxColor.TRANSPARENT);
		bottomWall.immovable = true;
		walls.add(bottomWall);
		
        trailArea.add(_ball);

        add(trailArea);
        add(_ball);
        add(walls);
		add(_bat);

        xText = new FlxText(0, 20, Settings.WIDTH, "x", 30);
        xText.alignment = "center";
        yText = new FlxText(0, xText.frameHeight + 30, Settings.WIDTH, "y", 30);
        yText.alignment = "center";
        zText = new FlxText(0, xText.frameHeight + yText.frameHeight + 40, Settings.WIDTH, "z", 30);
        zText.alignment = "center";
        accText = new FlxText(0, zText.frameHeight + xText.frameHeight + yText.frameHeight + 40, Settings.WIDTH, "acc", 30);
        accText.alignment = "center";
        
        add(xText);
        add(yText);
        add(zText);
        add(accText);
	}
	
	override public function update():Void
	{
		super.update();
		
		_bat.velocity.x = 0;
        _ball.velocity.y += 35 * speed;

        #if mobile
        if (FlxG.accelerometer.isSupported) {
          _bat.velocity.x = -((1 + FlxG.accelerometer.y / 2) * FlxG.accelerometer.x) * BAT_SPEED * speed;

          xText.text = "x: " + FlxMath.roundDecimal(FlxG.accelerometer.x, 1);
            yText.text = "y: " + FlxMath.roundDecimal(FlxG.accelerometer.y, 1);
            zText.text = "z: " + FlxMath.roundDecimal(FlxG.accelerometer.z, 1);
            accText.text = "acc: " + FlxMath.roundDecimal(_bat.velocity.x, 1);
        }
        #end

		#if !FLX_NO_TOUCH
		for (touch in FlxG.touches.list)
		{
			if (touch.pressed)
			{
				if (touch.x > 10 && touch.x < 290)
				_bat.x = touch.x;
			}
		}
        #else
        if (FlxG.keys.anyPressed(["LEFT", "A"]) && _bat.x > 10)
        {
            _bat.velocity.x = - BAT_SPEED;
        }
        else if (FlxG.keys.anyPressed(["RIGHT", "D"]) && _bat.x < 290)
        {
            _bat.velocity.x = BAT_SPEED;
        }
		#end
		
		if (_bat.x < 10)
		{
			_bat.x = 10;
		}
		
		if (_bat.x > 340 - _batWidth)
		{
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
		
		if (ballmid < batmid)
		{
			// Ball is on the left of the bat
			diff = batmid - ballmid;
			ball.velocity.x = ( -10 * diff);
            ball.angularVelocity = diff * 10;
        }
        else if (ballmid > batmid)
        {
            // Ball on the right of the bat
            diff = ballmid - batmid;
            ball.velocity.x = (10 * diff);
            ball.angularVelocity = diff * 10;
        }
        else
        {
            // Ball is perfectly in the middle
            // A little random X to stop it bouncing up!
            ball.velocity.x = 2 + FlxRandom.intRanged(0, 8);
            ball.angularVelocity = 0;
        }
        ball.velocity.y = -1500 * speed;
        // FlxG.camera.shake(0.01 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */);        
        success(ball.getMidpoint());
	}
}
