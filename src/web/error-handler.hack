namespace catarini\render; 

use catarini\exception;


class ErrorHandler { 

    // Callbacks - take an HTTP status?  Not sure how else to do it 

    private ?(function(int): \XHPRoot) $xhp; 
    public function xhp((function(int): \XHPRoot) $lambda) : ErrorHandler { 
        $this->xhp = $lambda; 
        return $this; 
    }

    // Private API 

    public function _invoke_xhp(int $status) : \XHPRoot { 
        $x = $this->xhp; 
        if($x is nonnull) return $x($status);
        else return \_CatariniXHP::http_error($status); 
    }
}
