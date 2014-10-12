package com.andersnissen.test;

import haxe.unit.TestRunner;

class TestMain {

    static function main()
    {
        var runner = new TestRunner();
        runner.add(new GameSessionManagerTests());

        runner.run();
    }

}
