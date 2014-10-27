package com.andersnissen.states;

import com.andersnissen.ColorScheme;
import com.andersnissen.GameTextOverlay;
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
    var hints :String = "???";
    var description :String = "???";
    var controls :String = "???";
    var winningCondition :WinningCondition = WinningCondition.Survive;

    var gameTimer :FlxTimer;
    var heartBeatTimer :FlxTimer;
    var gameStartTimer :FlxTimer;

    var gameActive :Bool = false;

    public var speed :Float = 1;
    public var score :Int = 0;
    public var training :Bool = false;

    var backgroundSprite :FlxSprite;
    var backgroundColor :Int;
    
    var timerSprite :FlxSprite;
    var timerSpriteColor :Int;

    // Particles
    var emitter :FlxEmitter;
    var whitePixel :FlxParticle;

    var spriteGroupsToAdd :Array<FlxSpriteGroup>;
    var totalSpritesToAdd :Int;

    var colorPool :ColorPool;

    public var onWin :FlxSignal;
    public var onLose :FlxSignal;

    var textOverlay :GameTextOverlay;

    public var gameIndex :Int;
    public var gameBatchSize :Int;

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
        backgroundColor = ColorScheme.randomExcept([ColorScheme.GREEN, ColorScheme.RED, ColorScheme.BLACK, ColorScheme.WHITE]);
        backgroundSprite = new FlxSprite(0, 0);
        backgroundSprite.makeGraphic(Settings.WIDTH, Settings.HEIGHT, backgroundColor);
        add(backgroundSprite);

        timerSprite = new FlxSprite(0, 0);
        timerSprite.makeGraphic(Settings.WIDTH, 1);
        add(timerSprite);

        colorPool = new ColorPool([this.backgroundColor, ColorScheme.RED, ColorScheme.GREEN]);

        spriteGroupsToAdd = new Array<FlxSpriteGroup>();
        totalSpritesToAdd = 0;
        setup();

        function playSound(tween :FlxTween) {
            FlxG.sound.play("assets/sounds/click" + FlxG.random.int(1, 3) + ".ogg");
        }

        var isNewUnlockedGame = Reg.gameManager.isNewGame();

        var maxDelay = 1.0 / speed;
        if (isNewUnlockedGame) {
            maxDelay = 3.0 / speed;
        } else if (training && score > 0) {
            maxDelay = 0.2 / speed;
        }

        var delay :Float = 0;
        for (spriteGroup in spriteGroupsToAdd) {
            spriteGroup.visible = true;
            for (sprite in spriteGroup.members) {
                sprite.antialiasing = true;
                sprite.pixelPerfectRender = false;

                var spriteEndScaleX = sprite.scale.x;
                var spriteEndScaleY = sprite.scale.y;
                sprite.scale.set(0, 0);
                FlxTween.tween(sprite.scale, { x: spriteEndScaleX, y: spriteEndScaleY }, 0.5, { startDelay: delay, ease: FlxEase.elasticInOut, onStart: playSound });
                var originalX = sprite.x;
                var originalY = sprite.y;
                var originalAngle = sprite.angle;
                sprite.x += FlxG.random.float(-40, 40);
                sprite.y += FlxG.random.float(-40, 40);
                sprite.angle += FlxG.random.float(-2, 2);
                FlxTween.tween(sprite, { x: originalX, y: originalY, angle: originalAngle }, 0.7, { startDelay: delay, ease: FlxEase.elasticInOut });
                delay += maxDelay / totalSpritesToAdd;
            }
        }

        timerSpriteColor = switch (winningCondition) {
            case Survive: ColorScheme.GREEN;
            case CompleteObjective: ColorScheme.RED;
            default: ColorScheme.random();
        };

        this.transIn.color = backgroundColor;

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

        var timeBeforeStarting = (this.transIn.duration / 2) / speed;
        if (isNewUnlockedGame) {
            timeBeforeStarting += 4 / speed;
        } else if (training && score > 0) {
            timeBeforeStarting += 1 / speed;
        } else {
            timeBeforeStarting += 2 / speed;
        }
        gameStartTimer = new FlxTimer(timeBeforeStarting, function(_ :FlxTimer) {
            if (textOverlay != null) {
                textOverlay.close(0.3 / speed);
            }
            // FlxG.camera.flash(0x22FFFFFF, 0.05);

            heartBeatTimer = new FlxTimer(1 / speed, function(_ :FlxTimer) {
                if (!gameActive) return;
                FlxG.sound.play("assets/sounds/heartbeat.ogg", 1);
            }, 0);
            // new FlxTimer(1 / speed, function(_ :FlxTimer) {
            //     takeScreenshot();
            // });
            gameActive = true;
            gameTimer = new FlxTimer(5 / speed, timesUp);
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
            FlxG.sound.playMusic("assets/music/" + track);
        }

        if (isNewUnlockedGame) {
            textOverlay = new GameTextOverlay("*NEW GAME*", hints, 'Controls: *$controls*');
        } else {
            if (training) {
                if (score == 0)
                    textOverlay = new GameTextOverlay("Training", hints, 'Controls: $controls');
            } else {
                textOverlay = new GameTextOverlay('Game $gameIndex / $gameBatchSize', hints);
            }
        }
        if (textOverlay != null) {
            add(textOverlay);
            textOverlay.open(0.5 / speed);
        }
    }

    function setup() :Void
    {
        // overridden by inheriting class
    }

    function addSprite(sprite :FlxSprite) :FlxSprite {
        sprite.antialiasing = true;
        sprite.pixelPerfectRender = false;
        super.add(sprite);
        return sprite;
    }

    function addSpriteGroup(spriteGroup :FlxSpriteGroup) {
        spriteGroupsToAdd.push(spriteGroup);
        spriteGroup.visible = false;
        totalSpritesToAdd += spriteGroup.members.length;
        super.add(spriteGroup);
    }
    
    /**
     * Function that is called when this state is destroyed - you might want to 
     * consider setting all objects this state uses to null to help garbage collection.
     */
    override public function destroy() :Void
    {
        gameTimer = FlxDestroyUtil.destroy(gameTimer);
        heartBeatTimer = FlxDestroyUtil.destroy(heartBeatTimer);
        gameStartTimer = FlxDestroyUtil.destroy(gameStartTimer);

        super.destroy();
    }

    /**
     * Function that is called once every frame.
     */
    override public function update(elapsed :Float) :Void
    {
        #if (android)
        // if (FlxG.android.anyJustPressed([27])) {
        //     lose();
        //     return;
        // }
        #end

        if (gameTimer != null && gameActive) {
            timerSprite.makeGraphic(Settings.WIDTH, Math.floor(gameTimer.progress * Settings.HEIGHT) + 10, ColorScheme.BLACK);
            timerSprite.drawRect(0, 0, Settings.WIDTH, Math.floor(gameTimer.progress * Settings.HEIGHT), timerSpriteColor);
        }

        if (gameActive) {
            super.update(elapsed * speed);
            updateGame(elapsed * speed);
        }
    }

    function updateGame(elapsed :Float) {
        // overridden by inheriting class
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

        FlxG.sound.play("assets/sounds/scratch" + FlxG.random.int(1, 3) + ".ogg");
        if (FlxG.sound.music != null && FlxG.sound.music.playing) {
            FlxG.sound.music.stop();
        }

        FlxG.camera.shake();
        FlxG.camera.flash(ColorScheme.RED);

        this.transOut.color = ColorScheme.RED;

        textOverlay = new GameTextOverlay(null, "GAME OVER", 'Score: *${score}*');
        add(textOverlay);
        textOverlay.open(1.0 / speed);

        new FlxTimer(2, function(_ :FlxTimer) {
            onLose.dispatch();
        });
    }

    function win(?position :FlxPoint) {
        if (!gameActive) return;
        gameActive = false;

        FlxG.sound.play(AssetPaths.start__ogg);

        this.transOut.color = ColorScheme.GREEN;

        onWin.dispatch();
    }

    function success(?position :FlxPoint)
    {
        FlxG.sound.play("assets/sounds/success.wav", 0.5);

        #if (android || neko)
        // Sys.sleep(0.02);
        #end
        FlxG.camera.flash(0x22FFFFFF, 0.05);
        FlxG.camera.shake(0.015 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */);

        if (position != null) {
            emitter.setPosition(position.x, position.y);
        }
        emitter.start(true, 0.01, 20);
    }
}
