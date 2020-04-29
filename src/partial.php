<?hh // partial

namespace catarini; 

class PARTIAL { 
    public static function _SERVER()    : dict<string, mixed> { return $_SERVER; }
    public static function _GET()       : dict<string, mixed> { return $_GET; }
    public static function _POST()      : dict<string, mixed> { return $_POST; }
    public static function _COOKIE()    : dict<string, mixed> { return $_COOKIE; }

	public static function getRequestURI() : string { return $_SERVER['REQUEST_URI']; }
	public static function getRequestMethod() : string { return $_SERVER['REQUEST_METHOD']; }

    public static function getRequestContentType() : ?string { return $_SERVER['CONTENT_TYPE']; }



    //
    // Private
    // 

    public static function __set_SERVER($x) : void { $_SERVER = $x; }
}
