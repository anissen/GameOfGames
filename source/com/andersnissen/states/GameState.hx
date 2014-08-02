package com.andersnissen.states;

import com.andersnissen.Settings;
import flixel.effects.particles.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

enum WinningCondition
{
    Survive;
    CompleteObjective;
}

class GameState extends FlxState
{
    var name :String = "Nameless Game";
    var description :String = "You're on your own...";
    var winningCondition :WinningCondition = WinningCondition.Survive;

    var timer :FlxTimer;

    var gameActive :Bool = false;

    var speed :Float = 1;

    var gradientSprite :FlxSprite;
    var blackSprite :FlxSprite;

    // Particles
    var emitter :FlxEmitterExt;
    var whitePixel :FlxParticle;

    var initialZoom :Float;

    /**
     * Function that is called up when to state is created to set it up. 
     */
    override public function create() :Void
    {
        add(new FlxText(100, 100, 200, description));

        FlxG.cameras.fade(FlxColor.BLACK, 0.1, true);

        gradientSprite = FlxGradient.createGradientFlxSprite(Settings.WIDTH, Settings.HEIGHT, [FlxColor.GREEN, FlxColor.GREEN, FlxColor.GREEN, FlxColor.YELLOW, FlxColor.RED], Math.floor(Settings.HEIGHT / 5), 90, false);
        gradientSprite.alpha = 0.3;
        add(gradientSprite);

        blackSprite = new FlxSprite(0, 0);
        blackSprite.makeGraphic(Math.floor(FlxG.worldBounds.width), 0);
        add(blackSprite);

        setup();

        var particleCount = 200;
        emitter = new FlxEmitterExt(Settings.WIDTH / 2, Settings.HEIGHT / 2, particleCount);
        // emitter.setXSpeed(100, 200);
        // emitter.setYSpeed(100, 200);
        emitter.bounce = 0.8;
        add(emitter);

        for (i in 0...(Std.int(particleCount / 2))) {
            whitePixel = new FlxParticle();
            whitePixel.makeGraphic(5, 5, FlxRandom.color());
            whitePixel.visible = false; 
            emitter.add(whitePixel);

            whitePixel = new FlxParticle();
            whitePixel.makeGraphic(2, 2, FlxRandom.color());
            whitePixel.visible = false;
            emitter.add(whitePixel);
        }

        initialZoom = FlxG.camera.zoom;
        FlxG.camera.zoom = initialZoom * 1.5;
        FlxG.camera.focusOn(new FlxPoint(Settings.WIDTH / 2, Settings.HEIGHT / 2));
        FlxTween.tween(FlxG.camera, { zoom: initialZoom }, 1 * FlxG.timeScale, { ease: FlxEase.quadInOut });

        new FlxTimer(1 * FlxG.timeScale, function(_ :FlxTimer) {
            start();
            gameActive = true;
            timer = new FlxTimer(5, timesUp);
        });

        super.create();
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
    
    /**
     * Function that is called when this state is destroyed - you might want to 
     * consider setting all objects this state uses to null to help garbage collection.
     */
    override public function destroy() :Void
    {
        timer = FlxDestroyUtil.destroy(timer);

        // Reg.gameManager.onGameUnlocked.remove(newGameUnlocked);

        super.destroy();
    }

    /**
     * Function that is called once every frame.
     */
    override public function update() :Void
    {
        // remove(gradientSprite);
        // gradientSprite = flixel.util.FlxGradient.createGradientFlxSprite(Math.floor(FlxG.worldBounds.width), Math.floor(FlxG.worldBounds.height), [FlxColor.BLACK, FlxColor.GREEN, FlxColor.GREEN, FlxColor.YELLOW, FlxColor.RED], 5, 0, false);
        // add(gradientSprite);

        if (timer != null && gameActive) {
            blackSprite.makeGraphic(Math.floor(FlxG.worldBounds.width), Math.floor(timer.progress * FlxG.worldBounds.height), FlxColor.BLACK);
        }

        if (gameActive) {
            // FlxG.camera.alpha += 0.01;
            super.update();
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

        end();

        // Reg.networkManager.send({ "game": name, "won": false });
        Reg.networkManager.send({ "games": Reg.gameManager.getGamesPlayedList() });

        FlxG.camera.shake();
        FlxG.camera.flash(FlxColor.RED);

        if (position != null) {
            FlxG.camera.focusOn(position);
        } else {
            FlxG.camera.focusOn(new FlxPoint(Settings.WIDTH / 2, Settings.HEIGHT / 2));
        }
        FlxTween.tween(FlxG.camera, { zoom: initialZoom * 1.5 }, 1 * FlxG.timeScale, { ease: FlxEase.quadInOut });

        new FlxTimer(1 * FlxG.timeScale, function(_ :FlxTimer) {
            FlxG.switchState(new MenuState());
        });
    }

    function win(?position :FlxPoint) {
        if (!gameActive) return;
        gameActive = false;

        end();

        Reg.score++;
        if (Reg.score > Reg.highscore)
        {
            Reg.highscore = Reg.score;
        }
        Reg.speed += 0.1;
        speed = Reg.speed;
        // trace('Speed: $speed');

        FlxTween.tween(FlxG.camera, { zoom: initialZoom * 1.5 }, 1 * FlxG.timeScale, { ease: FlxEase.quadInOut });
        if (position != null) {
            FlxG.camera.focusOn(position);
        } else {
            FlxG.camera.focusOn(new FlxPoint(Settings.WIDTH / 2, Settings.HEIGHT / 2));
        }
        
        new FlxTimer(1 * FlxG.timeScale, function(_ :FlxTimer) {
            FlxG.cameras.fade(FlxColor.BLACK, 0.1, false, function () {
                FlxG.switchState(Reg.gameManager.getNextGame());
            });
        });
    }

    // TODO: Make this into a pluggable system, e.g.
    // effects.flash()
    // effects.freeze()
    function success(?position :FlxPoint)
    {
        FlxG.sound.play("assets/sounds/success.wav", 0.5);

        #if android
        Sys.sleep(0.02);
        #elseif neko
        Sys.sleep(0.02);
        #end
        FlxG.camera.flash(0x22FFFFFF, 0.05);
        FlxG.camera.shake(0.01 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */);

        if (position != null) {
            emitter.setPosition(position.x, position.y);
        }
        emitter.start(true, 0, 0.01, 20);
    }

    /* TODO: Implement the following functions:
        success(); // freeze followed by shake + sound + flash
        warning(); // freeze followed by shake + sound + flash
        explosion(); // particle explosion (e.g. ball hits the paddle)
        colorPalette(); // returns a color scheme

        generalize input: touch/mouse, accelerometer

        // effects should be limited at first, to be unlocked through play
    */
}
