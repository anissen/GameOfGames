package com.andersnissen;

import flixel.FlxG;
import com.andersnissen.states.GameState;
import com.andersnissen.states.MenuState;

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
        FlxG.switchState(new MenuState());
    }
}
