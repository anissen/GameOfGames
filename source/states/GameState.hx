package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

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

    var gameEnded :Bool = false;

    var speed :Float = 1;

    /**
     * Function that is called up when to state is created to set it up. 
     */
    override public function create():Void
    {
        add(new FlxText(100, 100, 200, description));
        timer = new FlxTimer(5, timesUp);

        FlxG.cameras.fade(FlxColor.BLACK, 0.1, true);

        super.create();
    }
    
    /**
     * Function that is called when this state is destroyed - you might want to 
     * consider setting all objects this state uses to null to help garbage collection.
     */
    override public function destroy():Void
    {
        timer = FlxDestroyUtil.destroy(timer);

        // Reg.gameManager.onGameUnlocked.remove(newGameUnlocked);

        super.destroy();
    }

    /**
     * Function that is called once every frame.
     */
    override public function update():Void
    {
        super.update();
    }

    function timesUp(timer :FlxTimer) {
        switch (winningCondition) {
            case Survive: win();
            case CompleteObjective: lose();
            case _: throw "Unknown WinningCondition";
        }
    }

    function lose() {
        if (gameEnded) return;
        gameEnded = true;

        FlxG.camera.shake();
        FlxG.camera.flash(FlxColor.RED);
        // FlxG.timeScale = 0.2;
        new FlxTimer(0.5 * FlxG.timeScale, function(timer :FlxTimer) {
            FlxG.switchState(new MenuState());
        });
    }

    function win() {
        if (gameEnded) return;
        gameEnded = true;
        
        Reg.score++;
        if (Reg.score > Reg.highscore)
        {
            Reg.highscore = Reg.score;
        }
        Reg.speed += 0.1;
        speed = Reg.speed;
        trace('Speed: $speed');
        // FlxG.camera.flash(FlxColor.GREEN);
        FlxG.cameras.fade(FlxColor.BLACK, 0.1, false, function () {
            FlxG.switchState(Reg.gameManager.getNextGame());
        });
    }

    // TODO: Make this into a pluggable system, e.g.
    // effects.flash()
    // effects.freeze()
    function success()
    {
        Sys.sleep(0.02);
        FlxG.camera.flash(0x22FFFFFF, 0.05);
        FlxG.camera.shake(0.01 /* intensity, default: 0.05 */, 0.05 /* duration, default: 0.5 */);
    }
    /* TODO: Implement the following functions:
        success(); // freeze followed by shake + sound + flash
        warning(); // freeze followed by shake + sound + flash
        explosion(); // particle explosion (e.g. ball hits the paddle)
        colorPalette(); // returns a color scheme

        // effects should be limited at first, to be unlocked through play
    */
}
