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

        super.create();
    }
    
    /**
     * Function that is called when this state is destroyed - you might want to 
     * consider setting all objects this state uses to null to help garbage collection.
     */
    override public function destroy():Void
    {
        timer = FlxDestroyUtil.destroy(timer);
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
        trace('speed: $speed');
        FlxG.camera.flash(FlxColor.GREEN);
        // FlxG.timeScale = 0.2;
        new FlxTimer(0.5 * FlxG.timeScale, function(timer :FlxTimer) {
            var newGameState = switch (FlxRandom.intRanged(0, 2)) {
                case 0: new games.Jump();
                case 1: new games.ConnectDots();
                case 2: new games.Bounce();
                case _: throw "Unknown game";
            }
            FlxG.switchState(newGameState);
        });
    }
}
