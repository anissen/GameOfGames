package com.andersnissen;

import flixel.FlxG;
import com.andersnissen.states.GameState;
import com.andersnissen.states.MenuState;

class GameSession
{
    var gameManager :GameManager;
    var speed :Float;
    var score :Int;

    public function new()
    {

    }

    public function start(manager :GameManager) :Void
    {
        gameManager = manager;
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
        trace("GameSession: Game won!");

        score++;
        speed += 0.1;

        if (score > Reg.highscore) {
            Reg.highscore = score;
        }
        Reg.score = score;

        startGame(gameManager.getNextGame());
    }

    function lostGame() :Void
    {
        trace("GameSession: Game lost!");
        FlxG.switchState(new MenuState());
    }
}
