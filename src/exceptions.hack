namespace catarini {

    class Exception extends \Exception { 
        private int $status;
        public function getHttpStatus() : int { return $this->status; }
    
        public function __construct(string $message, int $status = 500) { 
            $this->status = $status; 
            parent::__construct($message); 
        }

    }

}

namespace catarini\exceptions { 

    class Config extends \catarini\Exception { 
        
    }

    class InconsistentState extends \catarini\Exception { 

        
    }

}