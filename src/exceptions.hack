namespace catarini\exception; 
use \Catarini; 

class Exception extends \Exception { 

    private Catarini $C; 
    public function __construct(Catarini $framework, string $message) { 
        parent::__construct($message); 
        $this->C = $framework; 
    }

}


class HttpException extends Exception implements Renderable { 
    private int $status;
    public function getHttpStatus() : int { return $this->status; }
    
    public function __construct(Catarini $C, int $status = 500) { 
        $this->status = $status; 
        parent::__construct($C, "HTTP $status"); 
    }

    // Overrideable XHP display 
    public function xhp() : \XHPRoot { 
        return Catarini::GET()->errors()->_invoke_xhp($this->status); 
    }
}



interface Renderable {
    require extends \Exception; 
     
    public function xhp() : \XHPRoot; 
    public function getHttpStatus() : int;
}
