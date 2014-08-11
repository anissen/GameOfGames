package com.andersnissen.states;

import com.andersnissen.ColorScheme;
import com.andersnissen.Settings;
import flixel.effects.particles.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxGradient;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
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

class GameState extends FlxState
{
    var name :String = "Nameless Game";
    var description :String = "You're on your own...";
    var winningCondition :WinningCondition = WinningCondition.Survive;

    var timer :FlxTimer;

    var gameActive :Bool = false;

    var speed :Float = 1;

    var backgroundColor :Int;
    var gradientSprite :FlxSprite;
    var blackSprite :FlxSprite;

    // Particles
    var emitter :FlxEmitter;
    var whitePixel :FlxParticle;

    /**
     * Function that is called up when to state is created to set it up. 
     */
    override public function create() :Void
    {
        add(new FlxText(100, 100, 200, description));

        FlxG.cameras.fade(ColorScheme.BLACK, 0.1, true);

        gradientSprite = new FlxSprite(0, 0);
        gradientSprite.makeGraphic(Settings.WIDTH, Settings.HEIGHT, ColorScheme.randomExcept([ColorScheme.GREEN, ColorScheme.RED]));
        add(gradientSprite);

        blackSprite = new FlxSprite(0, 0);
        blackSprite.makeGraphic(Settings.WIDTH, 0);
        add(blackSprite);
        
        setup();

        backgroundColor = switch (winningCondition) {
            case Survive: ColorScheme.GREEN;
            case CompleteObjective: ColorScheme.RED;
            default: ColorScheme.random();
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

        function takeScreenshot(tween :FlxTween) :Void {
            #if (!FLX_NO_DEBUG && neko)
            trace("Screenshot!");
            flixel.addons.plugin.screengrab.FlxScreenGrab.grab(null, true, true);
            // var bitmap :flash.display.Bitmap = flixel.addons.plugin.screengrab.FlxScreenGrab.grab(new flash.geom.Rectangle(0, 0, Settings.WIDTH, Settings.HEIGHT), false, true); //
            // // Saving the BitmapData
            // var b :flash.utils.ByteArray = bitmap.bitmapData.encode("png", 1);
            // var fo :sys.io.FileOutput = sys.io.File.write('${name}.png', true);
            // fo.writeString(b.toString());
            // fo.close();
            #end
        }

        new FlxTimer(1 * FlxG.timeScale, function(_ :FlxTimer) {
            if (!gameActive) return;
            FlxG.sound.play("assets/sounds/heartbeat.ogg");
        }, 0);

        new FlxTimer(1 * FlxG.timeScale, function(_ :FlxTimer) {
            start();
            gameActive = true;
            timer = new FlxTimer(5, timesUp);
        });

        super.create();

        if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
            FlxG.sound.playMusic("assets/music/RoccoW_-_07_-_Weeklybeats_2014_7_-_Freaking_Viking.ogg");
        }
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
        return super.add(sprite);
    }

    function addSpriteGroup(spriteGroup :FlxSpriteGroup) :flixel.FlxBasic {
        function playSound(tween :FlxTween) {
            FlxG.sound.play("assets/sounds/click" + FlxG.random.int(1, 3) + ".ogg");
        }

        var delay :Float = 0;
        for (sprite in spriteGroup.members) {
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
        timer = FlxDestroyUtil.destroy(timer);

        super.destroy();
    }

    /**
     * Function that is called once every frame.
     */
    override public function update() :Void
    {
        if (timer != null && gameActive) {
            blackSprite.makeGraphic(Settings.WIDTH, Math.floor(timer.progress * Settings.HEIGHT) + 10, ColorScheme.BLACK);
            blackSprite.drawRect(0, 0, Settings.WIDTH, timer.progress * Settings.HEIGHT, backgroundColor);
        }

        if (gameActive) {
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

        FlxG.sound.play("assets/sounds/scratch.ogg");
        if (FlxG.sound.music != null && FlxG.sound.music.playing) {
            FlxG.sound.music.stop();
        }

        FlxG.camera.shake();
        FlxG.camera.flash(ColorScheme.RED);

        end();

        // Reg.networkManager.send({ "games": Reg.gameManager.getGamesPlayedList() });

        new FlxTimer(1 * FlxG.timeScale, function(_ :FlxTimer) {
            FlxG.switchState(new MenuState());
        });
    }

    function win(?position :FlxPoint) {
        if (!gameActive) return;
        gameActive = false;

        FlxG.sound.play("assets/sounds/cheer.ogg");

        end();

        Reg.score++;
        if (Reg.score > Reg.highscore)
        {
            Reg.highscore = Reg.score;
        }
        Reg.speed += 0.1;
        speed = Reg.speed;
        
        new FlxTimer(1 * FlxG.timeScale, function(_ :FlxTimer) {
            FlxG.cameras.fade(ColorScheme.BLACK, 0.1, false, function () {
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
        emitter.start(true, 0.01, 20);
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
