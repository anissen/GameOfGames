
package com.andersnissen.states;

import com.andersnissen.ColorScheme;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.math.FlxMath;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.text.FlxText.FlxTextBorderStyle;

/**
 * A FlxState which can be used for the game's menu.
 */
class GameSelectState extends FlxState
{
    var titleText :FlxText;
    var backButton :FlxText;

    var gameList :FlxSpriteGroup;

    /**
     * Function that is called up when to state is created to set it up. 
     */
    override public function create():Void
    {
        var gradientSprite = FlxGradient.createGradientFlxSprite(Settings.WIDTH, Settings.HEIGHT, [FlxColor.YELLOW, FlxColor.RED]);
        gradientSprite.alpha = 0.3;
        add(gradientSprite);

        FlxTween.tween(gradientSprite, { alpha: 0.7 }, 5, { type: FlxTween.PINGPONG });

        titleText = new FlxText(0, 20, Settings.WIDTH, "Training", 30);
        titleText.alignment = "center";
        titleText.color = FlxColor.CYAN;
        titleText.borderStyle = FlxTextBorderStyle.OUTLINE;
        titleText.borderColor = FlxColor.BLACK;
        titleText.borderSize = 0.0;
        add(titleText);

        FlxTween.tween(titleText, { borderSize: 5.0 }, 2, { type: FlxTween.PINGPONG });

        gameList = new FlxSpriteGroup(0, 70);

        var gameCount = 0;
        for (gameName in Reg.gameManager.getGamesUnlockedList()) {
            var x = 20 + (gameCount % 3) * 110;
            var y = Math.floor(gameCount / 3) * 205;
            var gameInfo = new FlxSpriteGroup(x, y);

            var background = new FlxSprite(0, 0);
            background.makeGraphic(100, 195, ColorScheme.BLACK);
            gameInfo.add(background);

            var gameIcon = new FlxSprite(5, 5, "assets/images/games/" + gameName + ".png");
            gameIcon.origin.set(0, 0);
            gameIcon.scale.set(0.2, 0.2);
            gameInfo.add(gameIcon);

            var gameText = new FlxText(0, 162, 100, "HI: ??", 20);
            gameText.font = "assets/fonts/kenpixel_blocks.ttf";
            gameText.color = FlxColor.BLUE;
            gameText.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
            gameText.borderColor = FlxColor.WHITE;
            gameText.alignment = FlxTextAlign.CENTER;
            gameText.alpha = 0.0;
            gameInfo.add(gameText);

            gameList.add(gameInfo);
            gameInfo.forEach(function(sprite) {
                var originalX = sprite.x;
                sprite.x += 40;
                FlxTween.tween(sprite, { x: originalX, alpha: 1.0 }, 0.3, { startDelay: gameCount * 0.1 });
            });

            gameCount++;
        }

        add(gameList);

        backButton = new FlxText(0, Settings.HEIGHT - 100, Settings.WIDTH, 'Back', 30);
        backButton.alignment = "center";
        backButton.color = FlxColor.YELLOW;
        backButton.borderStyle = FlxTextBorderStyle.OUTLINE;
        backButton.borderColor = FlxColor.BROWN;
        backButton.borderSize = 5.0;
        add(backButton);

        FlxTween.tween(backButton.scale, { x: 1.5, y: 1.5 }, 1, { type: FlxTween.PINGPONG, startDelay: 0.5 });

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

        // for (swipe in FlxG.swipes) {
        //     trace(swipe);
        //     if (swipe.duration < 0.5 && swipe.distance > 50) {
        //         if (swipe.angle > -45 && swipe.angle < 45) {
        //             trace("Should trigger swipe!");
        //             gameList.forEach(function(obj) {
        //                 obj.y -= 100;
        //             });
        //         }
        //     }
        // }
        #if !FLX_NO_TOUCH
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed && backButton.overlapsPoint(touch.getWorldPosition()))
            {
               onBackClicked();
               break; 
            }
        }
        #else
        if (FlxG.mouse.justPressed && backButton.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            onBackClicked();
        }
        #end
    }

    function onBackClicked()
    {
        FlxG.switchState(new MenuState());
    }
}
