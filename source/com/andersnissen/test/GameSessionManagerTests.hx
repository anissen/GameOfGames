package com.andersnissen.test;

import haxe.unit.TestCase;

import flixel.FlxG;

class GameSessionManagerTests extends TestCase {
    public function testNoList() {
        var gameSessionManager = new com.andersnissen.GameSessionManager([]);
        assertEquals(0, gameSessionManager.getUnlockCount());
        assertEquals(0, gameSessionManager.getGamesPlayedList());
        assertEquals(0, gameSessionManager.getGamesUnlockedList());
        assertEquals(false, gameSessionManager.isNewGame());
        // assertEquals(false, gameSessionManager.getNext());
    }
}
