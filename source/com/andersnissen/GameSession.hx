package com.andersnissen;

import com.andersnissen.ColorScheme;
import com.andersnissen.states.InfoState;
import flixel.FlxG;
import com.andersnissen.states.GameState;
import com.andersnissen.states.MenuState;
import flixel.util.FlxTimer;

class GameSession
{
    var gameManager :GameSessionManager;
    var speed :Float;
    var score :Int;
    var training :Bool;

    public function new()
    {

    }

    public function start(manager :GameSessionManager, ?isTraining :Bool = false) :Void
    {
        gameManager = manager;
        training = isTraining;
        speed = 1.0;
        score = 0;

        startGame(gameManager.getNextGame());
    }

    function startGame(game :GameState) :Void
    {
        Reg.speed = speed;

        var game :GameState = gameManager.getNextGame();
        game.onWin.addOnce(wonGame);
        game.onLose.addOnce(lostGame);

        Reg.setPostprocessingAmount(0.0);
        FlxG.switchState(game);
    }

    function wonGame() :Void
    {
        score++;
        speed += 0.1;

        if (!training) {
            if (score > Reg.highscore) {
                Reg.highscore = score;
            }
            Reg.score = score;
        }

        startGame(gameManager.getNextGame());
    }

    function lostGame() :Void
    {
        var infoState = new InfoState(4);
        infoState.bgColor = ColorScheme.RED;
        infoState.onDone.addOnce(function() {
            Reg.setPostprocessingAmount(0.0);
            FlxG.switchState(new MenuState());
        });
        Reg.setPostprocessingAmount(1.0);
        FlxG.switchState(infoState);
    }
}
