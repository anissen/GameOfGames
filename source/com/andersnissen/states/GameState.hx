package com.andersnissen.states;

import com.andersnissen.ColorScheme;
import com.andersnissen.DialogBox;
import com.andersnissen.Settings;
import flixel.effects.particles.*;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxGradient;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using flixel.util.FlxSpriteUtil;

enum WinningCondition
{
    Survive;
    CompleteObjective;
}

class GameState extends FlxTransitionableState
{
    var name :String = "Nameless Game";
    var description :String = "???";
    var controls :String = "???";
    var winningCondition :WinningCondition = WinningCondition.Survive;

    var gameTimer :FlxTimer;
    var heartBeatTimer :FlxTimer;
    var gameStartTimer :FlxTimer;
    var gameEndTimer :FlxTimer;

    var gameActive :Bool = false;

    var speed :Float = 1;

    var backgroundSprite :FlxSprite;
    var backgroundColor :Int;
    
    var timerSprite :FlxSprite;
    var timerSpriteColor :Int;

    // Particles
    var emitter :FlxEmitter;
    var whitePixel :FlxParticle;

    // Instructions box
    var instructions :DialogBox;

    public var onWin :FlxSignal;
    public var onLose :FlxSignal;

    public function new() :Void
    {
        super();
        onWin = new FlxSignal();
        onLose = new FlxSignal();

        this.transIn = FlxTransitionableState.defaultTransIn;
        this.transOut = FlxTransitionableState.defaultTransOut;
    }

    /**
     * Function that is called up when to state is created to set it up. 
     */
    override public function create() :Void
    {
        add(new FlxText(100, 100, 200, description));

        // FlxG.cameras.fade(ColorScheme.BLACK, 0.1, true);
        backgroundColor = ColorScheme.randomExcept([ColorScheme.GREEN, ColorScheme.RED]);
        backgroundSprite = new FlxSprite(0, 0);
        backgroundSprite.makeGraphic(Settings.WIDTH, Settings.HEIGHT, backgroundColor);
        add(backgroundSprite);

        timerSprite = new FlxSprite(0, 0);
        timerSprite.makeGraphic(Settings.WIDTH, 0);
        add(timerSprite);
        
        setup();

        timerSpriteColor = switch (winningCondition) {
            case Survive: ColorScheme.GREEN;
            case CompleteObjective: ColorScheme.RED;
            default: ColorScheme.random();
        };

        this.transIn.color = backgroundColor; //ColorScheme.random();

        var isNewUnlockedGame = Reg.gameManager.isNewGame();
        if (isNewUnlockedGame) {
            showInstructions();
        }

        var particleCount = 200;
        emitter = new FlxEmitter(Settings.WIDTH / 2, Settings.HEIGHT / 2, particleCount);
        add(emitter);

        for (i in 0...(Std.int(particleCount / 2))) {
            whitePixel = new FlxParticle();
            whitePixel.makeGraphic(5, 5, ColorScheme.random());
            whitePixel.visible = false; 
            emitter.add(whitePixel);

            whitePixel = new FlxParticle();
            whitePixel.makeGraphic(2, 2, ColorScheme.random());
            whitePixel.visible = false;
            emitter.add(whitePixel);
        }

        function takeScreenshot() {
            #if (!FLX_NO_DEBUG && neko)
            trace("Screenshot!");
            //flixel.addons.plugin.screengrab.FlxScreenGrab.grab(null, true, true);
            var bitmap :flash.display.Bitmap = flixel.addons.plugin.screengrab.FlxScreenGrab.grab(new flash.geom.Rectangle(0, 0, 450, 800), false, true); //
            // Saving the BitmapData
            var b :flash.utils.ByteArray = bitmap.bitmapData.encode("png", 1);
            var fo :sys.io.FileOutput = sys.io.File.write('${name}.png', true);
            fo.writeString(b.toString());
            fo.close();
            #end
        }

        var timeBeforeStarting = this.transIn.duration + (isNewUnlockedGame ? 3 : 0) / Reg.speed;
        gameStartTimer = new FlxTimer(timeBeforeStarting, function(_ :FlxTimer) {
            if (instructions != null) {
                instructions.close();
            }
            FlxG.camera.flash(0x22FFFFFF, 0.05);
            start();

            heartBeatTimer = new FlxTimer(1 / Reg.speed, function(_ :FlxTimer) {
                if (!gameActive) return;
                FlxG.sound.play("assets/sounds/heartbeat.ogg");
            }, 0);
            new FlxTimer(1 / Reg.speed, function(_ :FlxTimer) {
                takeScreenshot();
            });
            gameActive = true;
            gameTimer = new FlxTimer(5 / Reg.speed, timesUp);
        });

        super.create();

        if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
            var musicFiles = [
                "RoccoW_-_07_-_Weeklybeats_2014_7_-_Freaking_Viking.ogg",
                "RoccoW_-_09_-_Weeklybeats_2014_9_-_This_Little_Piggy_Danced.ogg",
                "RoccoW_-_Chips_Got_Kicks.ogg",
                "RoccoW_-_Pumped.ogg",
                "RoccoW_-_Sea_Battles_in_Space.ogg",
                "Rolemusic_-_01_-_Spell.ogg"
            ];
            var track = FlxG.random.getObject(musicFiles);
            // trace('Now playing "$track"');
            FlxG.sound.playMusic("assets/music/" + track);
        }
    }

    function showInstructions() :Void
    {
        instructions = new DialogBox("New Game!", this.description, 'Controls: ${this.controls}', ColorScheme.BLUE);
        add(instructions);
        instructions.open();
    }

    function showWinScreen() :Void
    {
        var winScreen = new DialogBox("You Won!", "Highscore: ??? games left", "Game unlocked: ??? games left", ColorScheme.GREEN);
        add(winScreen);
        winScreen.open();
    }

    function showLoseScreen() :Void
    {
        var loseScreen = new DialogBox("Game Over", 'Score: ${Reg.score}', 'Highcore: ${Reg.highscore}', ColorScheme.RED);
        add(loseScreen);
        loseScreen.open();
    }

    function setup() :Void
    {
        // overridden by inheriting class
    }

    function start() :Void
    {
        // overridden by inheriting class
    }

    function end() :Void
    {
        // overridden by inheriting class
    }

    function addSprite(sprite :FlxSprite) :flixel.FlxBasic {
        sprite.antialiasing = true;
        sprite.pixelPerfectRender = false;
        return super.add(sprite);
    }

    function addSpriteGroup(spriteGroup :FlxSpriteGroup) :flixel.FlxBasic {
        function playSound(tween :FlxTween) {
            FlxG.sound.play("assets/sounds/click" + FlxG.random.int(1, 3) + ".ogg");
        }

        var delay :Float = 0;
        for (sprite in spriteGroup.members) {
            sprite.antialiasing = true;
            sprite.pixelPerfectRender = false;

            var spriteEndScaleX = sprite.scale.x;
            var spriteEndScaleY = sprite.scale.y;
            sprite.scale.set(0, 0);
            FlxTween.tween(sprite.scale, { x: spriteEndScaleX, y: spriteEndScaleY }, 0.4, { startDelay: delay, ease: FlxEase.elasticOut, onStart: playSound });
            delay += 0.01;
        }
        return super.add(spriteGroup);
    }
    
    /**
     * Function that is called when this state is destroyed - you might want to 
     * consider setting all objects this state uses to null to help garbage collection.
     */
    override public function destroy() :Void
    {
        end();

        gameTimer = FlxDestroyUtil.destroy(gameTimer);
        heartBeatTimer = FlxDestroyUtil.destroy(heartBeatTimer);
        gameStartTimer = FlxDestroyUtil.destroy(gameStartTimer);
        gameEndTimer = FlxDestroyUtil.destroy(gameEndTimer);

        super.destroy();
    }

    /**
     * Function that is called once every frame.
     */
    override public function update(elapsed :Float) :Void
    {
        if (gameTimer != null && gameActive) {
            timerSprite.makeGraphic(Settings.WIDTH, Math.floor(gameTimer.progress * Settings.HEIGHT) + 10, ColorScheme.BLACK);
            timerSprite.drawRect(0, 0, Settings.WIDTH, Math.floor(gameTimer.progress * Settings.HEIGHT), timerSpriteColor);
        }

        if (gameActive) {
            super.update(elapsed);
        }
    }

    function timesUp(_ :FlxTimer) {
        switch (winningCondition) {
            case Survive: win();
            case CompleteObjective: lose();
            case _: throw "Unknown WinningCondition";
        }
    }

    function lose(?position :FlxPoint) {
        if (!gameActive) return;
        gameActive = false;

        FlxG.sound.play("assets/sounds/scratch.ogg");
        if (FlxG.sound.music != null && FlxG.sound.music.playing) {
            FlxG.sound.music.stop();
        }

        FlxG.camera.shake();
        FlxG.camera.flash(ColorScheme.RED);

        this.transOut.color = ColorScheme.RED;

        end();

        showLoseScreen();

        // Reg.networkManager.send({ "games": Reg.gameManager.getGamesPlayedList() });

        onLose.dispatch();
    }

    function win(?position :FlxPoint) {
        if (!gameActive) return;
        gameActive = false;

        FlxG.sound.play("assets/sounds/yeah.ogg");

        // showWinScreen();

        this.transOut.color = ColorScheme.GREEN;

        end();

        onWin.dispatch();
    }

    function success(?position :FlxPoint)
    {
        FlxG.sound.play("assets/sounds/success.wav", 0.5);

        #if android
        Sys.sleep(0.02);
        #elseif neko
        Sys.sleep(0.02);
        #end
        FlxG.camera.flash(0x22FFFFFF, 0.05);
        FlxG.camera.shake(0.015 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */);

        if (position != null) {
            emitter.setPosition(position.x, position.y);
        }
        emitter.start(true, 0.01, 20);
    }

    /* TODO: Implement the following functions:
        success(); // freeze followed by shake + sound + flash

        generalize input: touch/mouse, accelerometer
    */
}
