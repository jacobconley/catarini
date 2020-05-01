namespace catarini\exception; 
use \Catarini; 

class Exception extends \Exception { 
 
    public function __construct(string $message) { 
        parent::__construct($message); 
    }

}


class HttpException extends Exception implements Renderable { 
    private int $status;
    public function getHttpStatus() : int { return $this->status; }
    
    public function __construct(int $status = 500) { 
        $this->status = $status; 
        parent::__construct("HTTP $status"); 
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
