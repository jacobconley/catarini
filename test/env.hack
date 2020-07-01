    function _test_db() : catarini\db\DatabaseInstance { 
        catarini\meta\CONFIG::_forceRoot(dirname(__FILE__)."/env/");
        return Catarini::GET()->db(); 
    }