
package com.andersnissen.states;

import com.andersnissen.ColorScheme;
import com.andersnissen.Settings;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.math.FlxMath;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.text.FlxText.FlxTextBorderStyle;

class CreditsState extends FlxState
{
    var titleText :FlxText;
    var backButton :FlxText;

    override public function create() :Void
    {
        var gradientSprite = FlxGradient.createGradientFlxSprite(Settings.WIDTH, Settings.HEIGHT, [ColorScheme.MAROON, ColorScheme.BLUE]);
        gradientSprite.alpha = 0.3;
        add(gradientSprite);

        FlxTween.tween(gradientSprite, { alpha: 0.7 }, 5, { type: FlxTween.PINGPONG });

        titleText = new FlxText(0, 20, Settings.WIDTH, "Credits", 30);
        titleText.alignment = "center";
        titleText.color = ColorScheme.SILVER;
        titleText.borderStyle = FlxTextBorderStyle.OUTLINE;
        titleText.borderColor = ColorScheme.BLACK;
        titleText.borderSize = 0.0;
        add(titleText);

        FlxTween.tween(titleText, { borderSize: 5.0 }, 2, { type: FlxTween.PINGPONG });

        var lines = [
            "=DESIGN & PROGRAMMING",
            "Anders Nissen",
            "",
            "=MUSIC",
            "\"RoccoW\"",
            "Kris Keyser",
            "\"Rolemusic\"",
            "",
            "=SOUND FX",
            "freesounds.co.uk",
            "",
            "=THANKS TO",
            "You, for playing!"
        ];

        var lineNumber = 0;
        for (line in lines) {
            var isHeading = (line.length > 0 && line.charAt(0) == "=");
            var gameText = new FlxText(0, 80 + lineNumber * 35, Settings.WIDTH, (isHeading ? line.substr(1) : line), (isHeading ? 23 : 18));
            // gameText.font = "assets/fonts/kenpixel_blocks.ttf";
            gameText.color = ColorScheme.randomExcept([ColorScheme.BLACK, ColorScheme.NAVY, ColorScheme.GRAY]);
            gameText.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
            gameText.borderSize = 1;
            gameText.borderColor = ColorScheme.BLACK;
            gameText.alignment = FlxTextAlign.CENTER;
            gameText.alpha = 0.0;
            gameText.angle = FlxG.random.float(-5, 5);
            gameText.scale.y = -1;
            // gameText.x += - Settings.WIDTH / 2 + FlxG.random.float(Settings.WIDTH);
            add(gameText);

            FlxTween.tween(gameText, { alpha: 1, angle: 0, x: 0 }, 0.8, { startDelay: lineNumber * 0.15, ease: FlxEase.elasticInOut });
            FlxTween.tween(gameText.scale, { y: 1 }, 0.8, { startDelay: lineNumber * 0.15, ease: FlxEase.elasticInOut });

            lineNumber++;
        }

        backButton = new FlxText(0, Settings.HEIGHT - 80, Settings.WIDTH, 'Back', 30);
        backButton.alignment = "center";
        backButton.color = ColorScheme.FUCHSIA;
        backButton.borderStyle = FlxTextBorderStyle.OUTLINE;
        backButton.borderColor = ColorScheme.BLACK;
        backButton.borderSize = 3.0;
        add(backButton);

        FlxTween.tween(backButton.scale, { x: 1.5, y: 1.5 }, 1, { type: FlxTween.PINGPONG, startDelay: 0.5 });

        super.create();
    }
    
    override public function update(elapsed :Float) :Void
    {
        super.update(elapsed);

        if (FlxG.mouse.justPressed && backButton.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            onBackClicked();
        }
    }

    function onBackClicked()
    {
        FlxG.switchState(new MenuState());
    }
}
