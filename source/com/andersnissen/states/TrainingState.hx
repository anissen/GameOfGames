
package com.andersnissen.states;

import com.andersnissen.ColorScheme;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
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
class TrainingState extends FlxState
{
    var titleText :FlxText;
    var backButton :FlxText;
    var pageText :FlxText;
    var gameList :FlxSpriteGroup;
    var pageNumber :Int = 0;
    var gamesPerPage :Int = 6;
    var totalPages :Int;

    public function new(pageNum :Int = 0) {
        super();
        pageNumber = pageNum;
    }

    /**
     * Function that is called up when to state is created to set it up. 
     */
    override public function create():Void
    {
        totalPages = Math.ceil(Reg.gameManager.getGamesUnlockedList().length / gamesPerPage);
        if (totalPages < 1) totalPages = 1;

        var gradientSprite = FlxGradient.createGradientFlxSprite(Settings.WIDTH, Settings.HEIGHT, [ColorScheme.PURPLE, ColorScheme.AQUA]);
        gradientSprite.alpha = 0.3;
        add(gradientSprite);

        FlxTween.tween(gradientSprite, { alpha: 0.7 }, 5, { type: FlxTween.PINGPONG });

        titleText = new FlxText(0, 20, Settings.WIDTH, "Training", 30);
        titleText.alignment = "center";
        titleText.color = ColorScheme.FUCHSIA;
        titleText.borderStyle = FlxTextBorderStyle.OUTLINE;
        titleText.borderColor = ColorScheme.BLACK;
        titleText.borderSize = 0.0;
        add(titleText);

        FlxTween.tween(titleText, { borderSize: 5.0 }, 2, { type: FlxTween.PINGPONG });

        gameList = new FlxSpriteGroup(0, 70);
        add(gameList);

        pageText = new FlxText(0, Settings.HEIGHT - 145, Settings.WIDTH, 'Page ${pageNumber+1} / $totalPages', 20);
        pageText.color = ColorScheme.BLACK;
        pageText.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
        pageText.borderSize = 2;
        pageText.borderColor = ColorScheme.YELLOW;
        pageText.alignment = FlxTextAlign.CENTER;
        add(pageText);

        backButton = new FlxText(0, Settings.HEIGHT - 80, Settings.WIDTH, 'Back', 30);
        backButton.alignment = "center";
        backButton.color = ColorScheme.ORANGE;
        backButton.borderStyle = FlxTextBorderStyle.OUTLINE;
        backButton.borderColor = ColorScheme.MAROON;
        backButton.borderSize = 3.0;
        add(backButton);

        FlxTween.tween(backButton.scale, { x: 1.5, y: 1.5 }, 1, { type: FlxTween.PINGPONG, startDelay: 0.5 });

        super.create();

        if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
            FlxG.sound.playMusic(AssetPaths.Kris_Keyser___06___Nitro__ogg);
        }

        showPage(pageNumber);
    }
    
    /**
     * Function that is called when this state is destroyed - you might want to 
     * consider setting all objects this state uses to null to help garbage collection.
     */
    override public function destroy() :Void
    {
        super.destroy();
    }

    /**
     * Function that is called once every frame.
     */
    override public function update(elapsed :Float) :Void
    {
        super.update(elapsed);

        for (swipe in FlxG.swipes) {
            if (swipe.duration < 0.5 && swipe.distance > 50) {
                if (swipe.angle > (90 - 45) && swipe.angle < (90 + 45)) {
                    if (pageNumber > 0) {
                        pageNumber--;
                        showPage(pageNumber);
                    }
                    return;
                } else if (swipe.angle < (-45) && swipe.angle > (-90 - 45)) {
                    if (pageNumber < (totalPages - 1)) {
                        pageNumber++;
                        showPage(pageNumber);
                    }
                    return;
                }
            }
        }

        if (FlxG.mouse.justPressed && backButton.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            onBackClicked();
        }

        if (FlxG.mouse.justReleased) {
            for (i in 0 ... gamesPerPage) {
                var gameIndex = pageNumber * gamesPerPage + i;
                if (i >= gameList.members.length) break;
                var game = gameList.members[i];
                if (game.overlapsPoint(FlxG.mouse.getWorldPosition())) {
                    onGameClicked(gameIndex);
                    return;
                }
            }
        }
    }

    function showPage(pageNumber :Int) {
        gameList.clear();

        var gameCount = 0;
        var unlockedGames = Reg.gameManager.getGamesUnlockedList();
        for (i in pageNumber * gamesPerPage ... unlockedGames.length) {
            if (gameCount == gamesPerPage) break;
            var gameName = unlockedGames[i];
            var x = 20 + (gameCount % 3) * 110;
            var y = 80 + Math.floor(gameCount / 3) * 205;
            var gameInfo = new FlxSpriteGroup(x, y);

            var background = ShapeBuilder.createRect(0, 0, 100, 195, ColorScheme.ORANGE);
            gameInfo.add(background);

            var gameIcon = new FlxSprite(5, 5, "assets/images/small_games/" + gameName + ".png");
            gameInfo.add(gameIcon);

            var highscore :Null<Int> = Reg.getTrainingHighscore(gameName);
            var highscoreText = "HI: ??";
            if (highscore != null)
                highscoreText = "HI: " + highscore;

            var gameText = new FlxText(0, 162, 100, highscoreText, 20);
            gameText.font = "assets/fonts/kenpixel_blocks.ttf";
            gameText.color = ColorScheme.BLACK;
            gameText.borderStyle = FlxTextBorderStyle.OUTLINE;
            gameText.borderSize = 1;
            gameText.borderColor = ColorScheme.SILVER;
            gameText.alignment = FlxTextAlign.CENTER;
            gameInfo.add(gameText);

            gameInfo.forEach(function(sprite) {
                sprite.alpha = 0;
                sprite.angle = FlxG.random.float(-10, 10);
                sprite.y += 30;
                FlxTween.tween(sprite, { alpha: 1, y: sprite.y - 30 }, 0.3, { startDelay: gameCount * 0.05, ease: FlxEase.elasticInOut });
                FlxTween.angle(sprite, sprite.angle, 0.15, { startDelay: gameCount * 0.05 - 0.05, ease: FlxEase.elasticInOut });
            });

            gameList.add(gameInfo);
            gameCount++;
        }

        pageText.text = 'Page ${pageNumber+1} / $totalPages';
        if (totalPages > 1) {
            if (pageNumber == 0) {
                pageText.text += "\n(swipe left)";
            } else if (pageNumber == (totalPages - 1)) {
                pageText.text += "\n(swipe right)";
            } else {
                pageText.text += "\n(swipe left/right)";
            }
        }
    }

    function onBackClicked()
    {
        FlxG.sound.play(AssetPaths.button_click, 1);
        FlxG.switchState(new MenuState());
    }

    function onGameClicked(gameIndex :Int)
    {
        FlxG.sound.play(AssetPaths.button_click, 1);
        Reg.gameSession.start(new GameSessionManager([Reg.gameList[gameIndex]]), true, pageNumber);
    }
}
