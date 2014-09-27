
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
    var background :FlxSprite;
    var textGroup :FlxSpriteGroup;

    function new(topText :String, text :String, ?bottomtText :String)
    {
        super();

        background = ShapeBuilder.createRect(0, 0, Settings.WIDTH, Settings.HEIGHT, ColorScheme.BLACK);
        background.alpha = 0.4;
        add(background);

        textGroup = new FlxSpriteGroup();

        var format = new FlxTextFormat(ColorScheme.RED, true, true, ColorScheme.WHITE);
        var markup = new FlxTextFormatMarkerPair(format, "*");

        var titleText = createText(text, Settings.HEIGHT / 3, 48, ColorScheme.BLACK, FlxTextBorderStyle.SHADOW, ColorScheme.SILVER, 10);
        titleText.applyMarkup(titleText.text, [markup]);
        textGroup.add(titleText);
        if (topText != null) {
            var topHeader = createText(topText, titleText.y - 20, 18, ColorScheme.BLACK, FlxTextBorderStyle.OUTLINE, ColorScheme.SILVER, 2);
            topHeader.applyMarkup(topHeader.text, [markup]);
            textGroup.add(topHeader);
        }
        if (bottomtText != null) {
            var bottomHeader = createText(bottomtText, titleText.y + titleText.height + 5, 18, ColorScheme.BLACK, FlxTextBorderStyle.OUTLINE, ColorScheme.SILVER, 2);
            bottomHeader.applyMarkup(bottomHeader.text, [markup]);
            textGroup.add(bottomHeader);
        }
        add(textGroup);
    }

    function createText(text :String, y :Float, textSize :Int, color :Int, borderStyle :FlxTextBorderStyle, borderColor :Int = FlxColor.BLACK, ?borderSize :Float = 0.0)
    {
        var margin = 5;
        var textButton = new FlxText(margin, y, Settings.WIDTH - margin * 2, text, textSize);
        textButton.alignment = "center";
        textButton.color = color;
        textButton.borderStyle = borderStyle;
        textButton.borderColor = borderColor;
        textButton.borderSize = borderSize;
        return textButton;
    }

    public function open(animationTime :Float)
    {
        background.alpha = 0;
        FlxTween.tween(background, { alpha: 0.3 }, animationTime, { ease: FlxEase.quadInOut });

        textGroup.angle = -5;
        textGroup.scale.set(0, 0);
        FlxTween.tween(textGroup.scale, { x: 1, y: 1 }, animationTime, { ease: FlxEase.elasticInOut });
        FlxTween.tween(textGroup, { angle: -2 }, 1.0, { type: FlxTween.PINGPONG });        
    }

    public function close(animationTime :Float)
    {
        FlxTween.tween(background, { alpha: 0.0 }, animationTime, { ease: FlxEase.quadInOut });

        FlxTween.tween(textGroup.scale, { x: 0, y: 0 }, animationTime, { ease: FlxEase.elasticInOut });
    }
}
