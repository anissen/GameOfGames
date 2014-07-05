package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
    var titleText :FlxText;
    var scoreText :FlxText;
    var highScoreText :FlxText;
    var playButton :FlxButton;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
        titleText = new FlxText(0, FlxG.worldBounds.height * 1/6, FlxG.worldBounds.width, "Some Clever Title", 36);
        titleText.alignment = "center";
        add(titleText);

        scoreText = new FlxText(0, FlxG.worldBounds.height / 2 - 20, FlxG.worldBounds.width, 'Score: ${Reg.score}', 30);
        scoreText.alignment = "center";
        scoreText.color = FlxColor.GREEN;
        add(scoreText);

        highScoreText = new FlxText(0, FlxG.worldBounds.height / 2 + 20, FlxG.worldBounds.width, 'Highscore: ${Reg.highscore}', 30);
        highScoreText.alignment = "center";
        highScoreText.color = FlxColor.RED;
        add(highScoreText);

        playButton = new FlxButton(FlxG.worldBounds.width / 2, FlxG.worldBounds.height * 3/4, "Play", onPlayClicked);
        playButton.setPosition(playButton.x - playButton.width / 2, playButton.y - playButton.height / 2);
        add(playButton);

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
	}

    function onPlayClicked()
    {
        Reg.score = 0;
        Reg.speed = 1;

        FlxG.switchState(new games.Jump());
    }
}
