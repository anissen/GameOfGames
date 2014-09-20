package com.andersnissen.states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
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
    var emitter :FlxEmitter;

    var newHighscore :Bool;
    var newGamesUnlocked :Int;

    function createTextButton(text :String, y :Float, textSize :Int, color :Int, borderStyle :FlxTextBorderStyle, borderColor :Int = FlxColor.BLACK, ?borderSize :Float = 0.0)
    {
        var textButton = new FlxText(0, y, Settings.WIDTH, text, textSize);
        textButton.alignment = "center";
        textButton.color = color;
        textButton.borderStyle = borderStyle;
        textButton.borderColor = borderColor;
        textButton.borderSize = borderSize;
        return textButton;
    }

    override public function new(?newHighscore :Bool = false, ?newGamesUnlocked :Int = 0) :Void
    {
        super();

        this.newHighscore = newHighscore;
        this.newGamesUnlocked = newGamesUnlocked;
    }

    function createBackground() {
        var gradientSprite = FlxGradient.createGradientFlxSprite(Settings.WIDTH, Settings.HEIGHT, [ColorScheme.RED, ColorScheme.BLUE]);
        gradientSprite.alpha = 0.3;
        add(gradientSprite);

        FlxTween.tween(gradientSprite, { alpha: 0.7 }, 5, { type: FlxTween.PINGPONG });
    }

    function createEmitter() {
        var particleCount = 200;
        emitter = new FlxEmitter(Settings.WIDTH / 2, Settings.HEIGHT / 2, particleCount);
        emitter.alpha.set(0.3, 0.8, 0.0, 0.2);
        emitter.start(false, 0.2, 0);

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
        add(emitter);
    }

    function createTitleText() {
        titleText = createTextButton("Game\nof\nGames", 25, 36, ColorScheme.BLUE, FlxTextBorderStyle.SHADOW, ColorScheme.GRAY, 2);
        add(titleText);
        FlxTween.tween(titleText, { y: 30 }, 2, { type: FlxTween.PINGPONG });
    }

    function createPlayButton() {
        playButton = createTextButton("Play", 350, 30, ColorScheme.YELLOW, FlxTextBorderStyle.OUTLINE, ColorScheme.MAROON, 5.0);
        add(playButton);
        FlxTween.tween(playButton.scale, { x: 1.5, y: 1.5 }, 1, { type: FlxTween.PINGPONG, startDelay: 0.5 });
    }

    function createTrainingButton() {
        gameText = createTextButton('${Reg.gameManager.getUnlockCount()} Games Unlocked', 485, 16, ColorScheme.BLUE, FlxTextBorderStyle.OUTLINE, ColorScheme.BLACK, 1.0);
        gameText.alpha = 0.7;
        if (newGamesUnlocked > 0) {
            // trace("Should handle new game unlocked!");
            var format = new FlxTextFormat(ColorScheme.RED, true, true, ColorScheme.WHITE);
            var markup = new FlxTextFormatMarkerPair(format, "*");
            gameText.applyMarkup(gameText.text + '\n*$newGamesUnlocked NEW!*', [markup]);
        }
        add(gameText);
        FlxTween.angle(gameText, -5, -10, 2.2, { type: FlxTween.PINGPONG });

        trainingButton = createTextButton("Training", 460, 24, ColorScheme.TEAL, FlxTextBorderStyle.OUTLINE, ColorScheme.LIME, 2.0);
        add(trainingButton);
        FlxTween.tween(trainingButton, { x: 10 }, 3, { type: FlxTween.PINGPONG });
    }

    function createHighscoreText() {
        highScoreText = createTextButton('Highscore\n${Reg.highscore}', 230, 32, ColorScheme.RED, FlxTextBorderStyle.OUTLINE, ColorScheme.BLACK, 3.0);
        add(highScoreText);

        FlxTween.angle(highScoreText, -12, 12, 1, { type: FlxTween.PINGPONG });

        if (newHighscore) {
            function highscoreSmallDone(_) {
                FlxTween.tween(highScoreText.scale, { x: 1.2, y: 1.2 }, 1.5, { type: FlxTween.PINGPONG });
                playMusic();
                emitter.start(false, 0.2, 0);
            }

            function highscoreBigDone(_) {
                FlxG.camera.shake(0.03, 0.15, null, true, FlxCameraShakeDirection.X_AXIS);
                FlxG.sound.play(AssetPaths.bump__ogg, 1);
                highScoreText.text = 'Highscore\n${Reg.highscore}';
                var highScorePos = highScoreText.getMidpoint();
                emitter.setPosition(highScorePos.x, highScorePos.y);
                emitter.start(true);
                FlxTween.tween(highScoreText.scale, { x: 1.0, y: 1.0 }, 0.7, { type: FlxTween.ONESHOT, onComplete: highscoreSmallDone});
            }

            highScoreText.text = 'NEW\nHIGHSCORE!';
            FlxTween.tween(highScoreText.scale, { x: 3, y: 3 }, 0.7, { type: FlxTween.ONESHOT, ease: FlxEase.elasticIn, onComplete: highscoreBigDone});
        } else {
            FlxTween.tween(highScoreText.scale, { x: 1.2, y: 1.2 }, 1.5, { type: FlxTween.PINGPONG });
            playMusic();
        }
    }

    function createCreditsButton() {
        creditsButton = createTextButton("Credits", 540, 24, ColorScheme.ORANGE, FlxTextBorderStyle.OUTLINE, ColorScheme.NAVY, 1.0);
        creditsButton.angle = 2.0;
        add(creditsButton);

        FlxTween.tween(creditsButton, { y: creditsButton.y + 10 }, 4, { type: FlxTween.PINGPONG });
        FlxTween.angle(creditsButton, 2, 8, 5, { type: FlxTween.PINGPONG });
    }

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create() :Void
    {
        #if (debug)
        if (FlxG.sound != null) {
            FlxG.sound.volume = 0.5;
        }
        #end

        createBackground();
        createEmitter();
        createTitleText();
        createPlayButton();
        createHighscoreText();
        createTrainingButton();
        createCreditsButton();

        // #if (debug)
        // var resetButton = new FlxButton(Settings.WIDTH / 2, 600, "Reset Progress", function () {
        //     Reg.highscore = 0;
        //     Reg.speed = 1;
        //     Reg.gameManager.reset();
        // });
        // resetButton.setPosition(resetButton.x - resetButton.width / 2, resetButton.y - resetButton.height / 2);
        // add(resetButton);
        // #end

        // var textfield = new openfl.text.TextField();
        // textfield.x = 40;
        // textfield.y = 620;
        // textfield.type = openfl.text.TextFieldType.INPUT;
        // textfield.text = "input";
        // textfield.textColor = 0xff00ff;
        // FlxG.addChildBelowMouse(textfield);

		super.create();
	}

    function playMusic() :Void
    {
        if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
            FlxG.sound.playMusic(AssetPaths.Kris_Keyser___06___Nitro__ogg);
        }
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

        #if (android)
        // if (FlxG.android.anyJustPressed([27])) {
        //     trace('Trying to exit?!');
        // }
        #end

        var emitterMargin = 20;
        emitter.setPosition(FlxG.random.float(emitterMargin, Settings.WIDTH - emitterMargin), FlxG.random.float(emitterMargin, Settings.HEIGHT - emitterMargin));

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
