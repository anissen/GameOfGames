
package com.andersnissen.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
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
    var backButton :FlxText;

    /**
     * Function that is called up when to state is created to set it up. 
     */
    override public function create():Void
    {
        var gradientSprite = FlxGradient.createGradientFlxSprite(Settings.WIDTH, Settings.HEIGHT, [FlxColor.YELLOW, FlxColor.RED]);
        gradientSprite.alpha = 0.3;
        add(gradientSprite);

        FlxTween.tween(gradientSprite, { alpha: 0.7 }, 5, { type: FlxTween.PINGPONG });

        var gameCount = 0;
        for (gameName in Reg.gameManager.getGamesUnlockedList()) {
            gameCount++;

            var gameText = new FlxText(50, gameCount * 40, Settings.WIDTH - 40, '#$gameCount $gameName', 20);
            gameText.color = FlxColor.BLUE;
            gameText.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
            gameText.borderColor = FlxColor.WHITE;
            gameText.alpha = 0.0;
            add(gameText);

            FlxTween.tween(gameText, { x: 20, alpha: 1.0 }, 0.3, { startDelay: gameCount * 0.1 });
        }

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
