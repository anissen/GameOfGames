
package com.andersnissen;

import com.andersnissen.ColorScheme;
import com.andersnissen.Settings;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using flixel.util.FlxSpriteUtil;

class DialogBox extends FlxSpriteGroup
{
    public function new(title: String, first: String, second: String, bgcolor: Int)
    {
        super();

        var width = Settings.WIDTH - 40;
        var height = 200;

        var borderSize = 5;
        var margin = borderSize + 10;

        var background = new FlxSprite(0, 0);
        background.makeGraphic(width, height, ColorScheme.TRANSPARENT);
        background.drawRect(0, 0, width, height, ColorScheme.BLACK);
        background.drawRect(borderSize, borderSize, width - 2 * borderSize, height - 2 * borderSize, bgcolor);
        background.alpha = 0.9;
        add(background);

        var titleText = new FlxText(margin, margin, width - 2 * margin, title, 28);
        titleText.color = ColorScheme.WHITE;
        titleText.borderStyle = FlxTextBorderStyle.SHADOW;
        titleText.borderColor = ColorScheme.GRAY;
        titleText.alignment = "center";
        add(titleText);

        var goalText = new FlxText(margin, margin + 60, width - 2 * margin, first, 18);
        goalText.font = "assets/fonts/arcade_r.ttf";
        goalText.color = ColorScheme.YELLOW;
        goalText.alignment = "center";
        add(goalText);

        var controlsText = new FlxText(margin, margin + 120, width - 2 * margin, second, 18);
        controlsText.font = "assets/fonts/arcade_r.ttf";
        controlsText.color = ColorScheme.ORANGE;
        controlsText.alignment = "center";
        add(controlsText);

        screenCenter();
    }

    public function open(?animationTime :Float = 0.5)
    {
        FlxTween.angle(this, this.angle, FlxG.random.float(-5, 5), animationTime, { ease: FlxEase.elasticInOut });
        forEach(function(obj) {
            obj.scale.set(0, 0);
            FlxTween.tween(obj.scale, { x: 1, y: 1 }, animationTime, { ease: FlxEase.elasticInOut });
        });
    }

    public function close(?animationTime :Float = 0.3)
    {
        FlxTween.angle(this, this.angle, 0, animationTime, { ease: FlxEase.elasticInOut });
        forEach(function(obj) {
            FlxTween.tween(obj.scale, { x: 0, y: 0 }, animationTime, { ease: FlxEase.elasticInOut });
        });
    }
}
