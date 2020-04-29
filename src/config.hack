namespace catarini;

class CONFIG { 

    public function __construct() { }

    <<__Memoize>>
    public static function GET() : CONFIG { return new CONFIG(); }

}