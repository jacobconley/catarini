    function _test_dir() : string { 
        return dirname(__FILE__)."/env/";
    }
    
    function _test_db() : catarini\db\DatabaseInstance { 
        catarini\meta\CONFIG::_forceRoot(_test_dir());
        return Catarini::GET()->db(); 
    }