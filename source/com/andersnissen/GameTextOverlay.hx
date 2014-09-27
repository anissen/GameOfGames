
package com.andersnissen;

import com.andersnissen.ColorScheme;
import com.andersnissen.Settings;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class GameTextOverlay extends FlxSpriteGroup
{
    function new(topText :String, text :String, ?bottomtText :String)
    {
        super();

        var format = new FlxTextFormat(ColorScheme.RED, true, true, ColorScheme.WHITE);
        var markup = new FlxTextFormatMarkerPair(format, "*");

        var titleText = createText(text, Settings.HEIGHT / 3, 48, ColorScheme.BLACK, FlxTextBorderStyle.SHADOW, ColorScheme.SILVER, 10);
        titleText.applyMarkup(titleText.text, [markup]);
        add(titleText);
        if (topText != null) {
            var topHeader = createText(topText, titleText.y - 20, 18, ColorScheme.BLACK, FlxTextBorderStyle.OUTLINE, ColorScheme.SILVER, 2);
            topHeader.applyMarkup(topHeader.text, [markup]);
            add(topHeader);
        }
        if (bottomtText != null) {
            var bottomHeader = createText(bottomtText, titleText.y + titleText.height + 10, 18, ColorScheme.BLACK, FlxTextBorderStyle.OUTLINE, ColorScheme.SILVER, 2);
            bottomHeader.applyMarkup(bottomHeader.text, [markup]);
            add(bottomHeader);
        }
    }

    function createText(text :String, y :Float, textSize :Int, color :Int, borderStyle :FlxTextBorderStyle, borderColor :Int = FlxColor.BLACK, ?borderSize :Float = 0.0)
    {
        var textButton = new FlxText(0, y, Settings.WIDTH, text, textSize);
        textButton.alignment = "center";
        textButton.color = color;
        textButton.borderStyle = borderStyle;
        textButton.borderColor = borderColor;
        textButton.borderSize = borderSize;
        return textButton;
    }

    public function open(animationTime :Float)
    {
        this.angle = -5;
        FlxTween.tween(this.scale, { x: 1, y: 1 }, animationTime, { ease: FlxEase.elasticInOut });
        FlxTween.tween(this, { angle: -2 }, 1.0, { type: FlxTween.PINGPONG });
    }

    public function close(animationTime :Float)
    {
        FlxTween.tween(this.scale, { x: 0, y: 0 }, animationTime, { ease: FlxEase.elasticInOut });
    }
}
