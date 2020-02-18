class HTML { 

	protected Vector<XHPRoot> $htmlHead = Vector { };
	public function appendHead(XHPRoot $operand) : void { $this->htmlHead->add($operand); }
	public function appendAllHead(Vector<XHPRoot> $operand) : void { $this->htmlHead->addAll($operand); }

	protected Vector<XHPRoot> $htmlBody = Vector {};
	public function append(XHPRoot $operand) : void { $this->htmlBody->add($operand); }
	public function appendAll(Vector<XHPRoot> $operand) : void { $this->htmlBody->addAll($operand); }

	public function getHtmlHead() : Vector<XHPRoot> { return $this->htmlHead; }
	public function getHtmlBody() : Vector<XHPRoot> { return $this->htmlBody; }

	private ?string $htmlTitle; 
	public function getHtmlTitle() : ?string { return $this->htmlTitle; }
	public function setHtmlTitle(string $title) : void { $this->htmlTitle = $title; }


}


class CatariniXHP { 

        // Default error page here
        // Gotta style this stuff
    public static function http_error(int $status) : XHPRoot { 
        return <h1>HTTP ERROR {$status}</h1>; 
    }
}