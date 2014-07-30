package com.andersnissen.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxMath;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
    var titleText :FlxText;
    var highScoreText :FlxText;
    var gameText :FlxText;
    var gameSelectionButton :FlxText;
    var playButton :FlxText;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
        var gradientSprite = FlxGradient.createGradientFlxSprite(Settings.WIDTH, Settings.HEIGHT, [FlxColor.RED, FlxColor.BLUE]);
        gradientSprite.alpha = 0.3;
        add(gradientSprite);

        titleText = new FlxText(0, 50, Settings.WIDTH, "Game of Games", 36);
        titleText.color = FlxColor.BLUE;
        titleText.borderStyle = FlxText.BORDER_SHADOW;
        titleText.borderColor = FlxColor.GRAY;
        titleText.alignment = "center";
        add(titleText);

        highScoreText = new FlxText(0, 200, Settings.WIDTH, 'Highscore: ${Reg.highscore}', 30);
        highScoreText.alignment = "center";
        highScoreText.color = FlxColor.RED;
        add(highScoreText);

        gameText = new FlxText(0, 390, Settings.WIDTH, 'Games Unlocked: ${Reg.gameManager.getUnlockCount()}', 16);
        gameText.alignment = "center";
        gameText.color = FlxColor.BLUE;
        gameText.alpha = 0.5;
        add(gameText);

        gameSelectionButton = new FlxText(0, 480, Settings.WIDTH, 'Game Selection', 24);
        gameSelectionButton.alignment = "center";
        gameSelectionButton.color = FlxColor.KHAKI;
        gameSelectionButton.borderStyle = FlxText.BORDER_OUTLINE;
        gameSelectionButton.borderColor = FlxColor.NAVY_BLUE;
        gameSelectionButton.borderSize = 2.0;
        add(gameSelectionButton);

        playButton = new FlxText(0, 350, Settings.WIDTH, 'Play', 30);
        playButton.alignment = "center";
        playButton.color = FlxColor.YELLOW;
        playButton.borderStyle = FlxText.BORDER_OUTLINE;
        playButton.borderColor = FlxColor.BROWN;
        playButton.borderSize = 5.0;
        add(playButton);

        var options :TweenOptions = { type: FlxTween.PINGPONG };
        FlxTween.angle(highScoreText, -12, 12, 1, options );
        FlxTween.angle(gameText, -5, -10, 2.2, options );

        FlxTween.tween(playButton.scale, { x: 1.5, y: 1.5 }, 1, { type: FlxTween.PINGPONG, startDelay: 0.5 });

        //var oldPlayButton = new FlxButton(Settings.WIDTH / 2, 550, "Play", onPlayClicked);
        // oldPlayButton.setPosition(oldPlayButton.x - oldPlayButton.width / 2, oldPlayButton.y - oldPlayButton.height / 2);
        // add(oldPlayButton);

        #if DEBUG
        var resetButton = new FlxButton(Settings.WIDTH / 2, 600, "Reset Progress", function () {
            Reg.highscore = 0;
            Reg.speed = 1;
            Reg.gameManager.reset();
        });
        resetButton.setPosition(resetButton.x - resetButton.width / 2, resetButton.y - resetButton.height / 2);
        add(resetButton);
        #end

		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
        super.update();

        // var rotationSpeed :Float = 2;
        // var maxRotation :Float = 15;
        // highScoreText.angle = Math.sin(Sys.time() * rotationSpeed) * maxRotation;
        
        playButton.borderSize = Math.abs(Math.cos(Sys.time() * 3) * 4);

        #if !FLX_NO_TOUCH
        for (touch in FlxG.touches.list)
        {
            if (!touch.justPressed) continue;

            if (playButton.overlapsPoint(touch.getWorldPosition()))
            {
               onPlayClicked();
               break; 
            } else if (playButton.overlapsPoint(touch.getWorldPosition())) {
                onGameSelectionClicked();
                break;
            }
        }
        #else
        if (!FlxG.mouse.justPressed) return;
        if (playButton.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            onPlayClicked();
        } else if (gameSelectionButton.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            onGameSelectionClicked();
        }
        #end
	}

    function onPlayClicked()
    {
        Reg.score = 0;
        Reg.speed = 1;
        Reg.gameManager.reset();

        FlxG.switchState(Reg.gameManager.getNextGame());
    }

    function onGameSelectionClicked()
    {
        FlxG.switchState(new GameSelectState());
    }
}
