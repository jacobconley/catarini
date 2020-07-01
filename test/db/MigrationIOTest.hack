use function Facebook\FBExpect\expect;

use catarini\db\migration\{ MigrationController, MigrationVersion };

class MigrationIOTest extends Facebook\HackTest\HackTest { 

    <<__Memoize>>
    private function controller() : MigrationController { 
        return new MigrationController(_test_db()); 
    }

    private function _delta(bool $up, vec<string> $available, ?string $before, string $after) : vec<string> {
        return $this->controller()->_delta($up, $available, new MigrationVersion($after, $before)); 
    }

    //
    // Schema deltas
    //

    // Initial states - no information 

    public function testEmpty() : void { 
        expect( $this->controller()->_delta(TRUE, vec[], NULL) )->toBeSame(vec[]); 
    }

    public function testNull() : void { 
        $vec = vec['a', 'b', 'c'];
        $x = $this->controller()->_delta(TRUE, $vec, NULL);
        expect($x)->toBeSame($vec); 
    }

    public function testNull_back() : void { 
        $this->setExpectedException('\catarini\exceptions\InvalidOperation'); 
        $this->controller()->_delta(FALSE, vec['a'], NULL); 
    }

    // Inconsistency errors; the referenced migration isn't present

    public function testDNE() : void { 
        $this->setExpectedException('\catarini\exceptions\InconsistentState');
        $this->_delta(TRUE, vec['a', 'b', 'c'], 'b', 'e'); 
    }

    public function testDNE_back_before() : void { 
        $this->setExpectedException('\catarini\exceptions\InconsistentState');
        $this->_delta(FALSE, vec['a', 'b', 'c'], 'e', 'c'); 
    }

    public function testDNE_back_after() : void { 
        $this->setExpectedException('\catarini\exceptions\InconsistentState');
        $this->_delta(FALSE, vec['a', 'b', 'c'], 'b', 'e'); 
    }

    // Basic use cases


    public function testBasic() : void { 
        $x = $this->_delta(TRUE, vec[ 'a', 'b', 'c', 'd', 'e', 'f' ], NULL, 'c');
        expect($x)->toBeSame(vec[ 'd', 'e', 'f' ]);
    }

    public function testBasic_back() : void { 
        $x = $this->_delta(FALSE, vec[ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h' ], 'c', 'g');
        expect($x)->toBeSame(vec[ 'g', 'f', 'e', 'd' ]);
    }


    public function testFullRollback() : void { 
        $x = $this->_delta(FALSE, vec['a', 'b', 'c' ], NULL, 'c');
        expect($x)->toBeSame(vec[ 'c', 'b', 'a' ]); 
    }

}