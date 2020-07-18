namespace catarini {

    class Exception extends \Exception { 
        protected int $httpStatus;
        public function getHttpStatus() : int { return $this->httpStatus; }
    
        public function __construct(string $message, int $httpStatus = 500) { 
            $this->httpStatus = $httpStatus; 
            parent::__construct($message); 
        }

    }

}

//TODO:  Move these shits to their appropriate namespaces, this is dumb 

namespace catarini\exceptions { 

    class Config extends \catarini\Exception { 
        
    }

    class InconsistentState extends \catarini\Exception { 

        
    }

    class InvalidOperation extends \catarini\Exception { 

    }

    class InvalidEnvironment extends \catarini\Exception { 
        // Weird things like "trying to create /db directory but there's a regular file there named db"
    }

}
