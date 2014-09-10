package com.andersnissen.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxGradient;
import flixel.math.FlxMath;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.effects.particles.*;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import com.andersnissen.ColorScheme;
import flixel.effects.postprocess.PostProcess;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
    var titleText :FlxText;
    var highScoreText :FlxText;
    var gameText :FlxText;
    var trainingButton :FlxText;
    var playButton :FlxText;
    var creditsButton :FlxText;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
        var gradientSprite = FlxGradient.createGradientFlxSprite(Settings.WIDTH, Settings.HEIGHT, [ColorScheme.RED, ColorScheme.BLUE]);
        gradientSprite.alpha = 0.3;
        add(gradientSprite);

        FlxTween.tween(gradientSprite, { alpha: 0.7 }, 5, { type: FlxTween.PINGPONG });

        var particleCount = 200;
        var emitter = new FlxEmitter(Settings.WIDTH / 2, Settings.HEIGHT / 2, particleCount);
        add(emitter);

        for (i in 0...(Std.int(particleCount / 2))) {
            var whitePixel = new FlxParticle();
            whitePixel.makeGraphic(25, 25, ColorScheme.random());
            whitePixel.visible = false; 
            emitter.add(whitePixel);

            whitePixel = new FlxParticle();
            whitePixel.makeGraphic(5, 5, ColorScheme.random());
            whitePixel.visible = false;
            emitter.add(whitePixel);
        }

        emitter.alpha.set(0.3, 0.8, 0.0, 0.2);
        emitter.start(false, 0.2, 0);

        titleText = new FlxText(0, 20, Settings.WIDTH, "Game\nof\nGames", 36);
        titleText.color = ColorScheme.BLUE;
        titleText.borderStyle = FlxTextBorderStyle.SHADOW;
        titleText.borderSize = 2;
        titleText.borderColor = ColorScheme.GRAY;
        titleText.alignment = "center";
        add(titleText);

        FlxTween.tween(titleText, { y: 30 }, 2, { type: FlxTween.PINGPONG });

        highScoreText = new FlxText(0, 230, Settings.WIDTH, 'Highscore: ${Reg.highscore}', 30);
        highScoreText.alignment = "center";
        highScoreText.color = ColorScheme.RED;
        add(highScoreText);

        gameText = new FlxText(0, 390, Settings.WIDTH, 'Games Unlocked: ${Reg.gameManager.getUnlockCount()}', 16);
        gameText.alignment = "center";
        gameText.color = ColorScheme.BLUE;
        gameText.alpha = 0.5;
        add(gameText);

        playButton = new FlxText(0, 350, Settings.WIDTH, 'Play', 30);
        playButton.alignment = "center";
        playButton.color = ColorScheme.YELLOW;
        playButton.borderStyle = FlxTextBorderStyle.OUTLINE;
        playButton.borderColor = ColorScheme.MAROON;
        playButton.borderSize = 5.0;
        add(playButton);

        trainingButton = new FlxText(-10, 480, Settings.WIDTH, 'Training', 24);
        trainingButton.alignment = "center";
        trainingButton.color = ColorScheme.TEAL;
        trainingButton.borderStyle = FlxTextBorderStyle.OUTLINE;
        trainingButton.borderColor = ColorScheme.NAVY;
        trainingButton.borderSize = 2.0;
        add(trainingButton);

        FlxTween.tween(trainingButton, { x: 10 }, 3, { type: FlxTween.PINGPONG });

        var options :TweenOptions = { type: FlxTween.PINGPONG };
        FlxTween.angle(highScoreText, -12, 12, 1, options );
        FlxTween.angle(gameText, -5, -10, 2.2, options );

        FlxTween.tween(highScoreText.scale, { x: 1.2, y: 1.2 }, 1.5, { type: FlxTween.PINGPONG });
        FlxTween.tween(playButton.scale, { x: 1.5, y: 1.5 }, 1, { type: FlxTween.PINGPONG, startDelay: 0.5 });

        creditsButton = new FlxText(-10, 540, Settings.WIDTH, 'Credits', 24);
        creditsButton.alignment = "center";
        creditsButton.color = ColorScheme.MAROON;
        creditsButton.borderStyle = FlxTextBorderStyle.OUTLINE;
        creditsButton.borderColor = ColorScheme.BLUE;
        creditsButton.borderSize = 1.0;
        creditsButton.angle = 2.0;
        add(creditsButton);

        FlxTween.tween(creditsButton, { y: creditsButton.y + 10 }, 4, { type: FlxTween.PINGPONG });
        FlxTween.angle(creditsButton, 2, 8, 5, options );


        #if DEBUG
        var resetButton = new FlxButton(Settings.WIDTH / 2, 600, "Reset Progress", function () {
            Reg.highscore = 0;
            Reg.speed = 1;
            Reg.gameManager.reset();
        });
        resetButton.setPosition(resetButton.x - resetButton.width / 2, resetButton.y - resetButton.height / 2);
        add(resetButton);
        #end

        // var textfield = new openfl.text.TextField();
        // textfield.x = 40;
        // textfield.y = 620;
        // textfield.type = openfl.text.TextFieldType.INPUT;
        // textfield.text = "input";
        // textfield.textColor = 0xff00ff;
        // FlxG.addChildBelowMouse(textfield);

		super.create();

        if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
            FlxG.sound.playMusic("assets/music/Kris_Keyser_-_06_-_Nitro.ogg");
        }

        // FlxG.debugger.visible = true;
        // FlxG.sound.volume = 0.5;
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
	override public function update(elapsed :Float):Void
	{
        super.update(elapsed);

        // var rotationSpeed :Float = 2;
        // var maxRotation :Float = 15;
        // highScoreText.angle = Math.sin(Sys.time() * rotationSpeed) * maxRotation;

        #if (neko || cpp)
        playButton.borderSize = Math.abs(Math.cos(Sys.time() * 3) * 4);
        #end

        #if !FLX_NO_TOUCH
        for (touch in FlxG.touches.list)
        {
            if (!touch.justPressed) continue;

            if (playButton.overlapsPoint(touch.getWorldPosition()))
            {
               onPlayClicked();
               break; 
            } else if (trainingButton.overlapsPoint(touch.getWorldPosition())) {
                onTrainingClicked();
                break;
            } else if (creditsButton.overlapsPoint(touch.getWorldPosition())) {
                onCreditsClicked();
                break;
            }
        }
        #else
        if (!FlxG.mouse.justPressed) return;
        if (playButton.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            onPlayClicked();
        } else if (trainingButton.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            onTrainingClicked();
        } else if (creditsButton.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            onCreditsClicked();
        }
        #end
	}

    function onPlayClicked()
    {
        Reg.score = 0;
        Reg.speed = 1;
        Reg.gameManager.reset();

        if (FlxG.sound.music != null && FlxG.sound.music.playing) {
            FlxG.sound.music.stop();
        }

        // FlxG.switchState(Reg.gameManager.getNextGame());
        Reg.gameSession.start(Reg.gameManager);
    }

    function onTrainingClicked()
    {
        FlxG.switchState(new TrainingState());
    }

    function onCreditsClicked()
    {
        FlxG.switchState(new CreditsState());
    }
}
