namespace simian\framework;


use \simian\framework\FrameworkException; 

use \XHPRoot;
use namespace \HH\Lib\{ Str };


abstract class WebFramework extends BaseFramework
{
	public function __construct(\DictAccess $config, string $rootpath)
	{
		parent::__construct($config, $rootpath);

		$this->htmlHead->add(\sxhp_meta_charset());
	}

	//
	// HTML Rendering 
	// 

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

	public function RENDER(?XHPRoot $operand = NULL) : void { 
		\sxhp_render($operand, $this); 
	}

	//
	// HTML code inclusion
	// 

	/**
	 * Require a CSS stylesheet to be loaded.
	 * @param $url The full URL of the resource to include, or, if beginning with ~/, relative to the Web base URL 
	 * @return void
	 */
	public function CSS(string $url) : void
	{ 
		if( Str\starts_with($url, "~/") )	$url = $this->WebURL(Str\slice($url, 2)); 
		$this->htmlHead->add(\sxhp_css($url));
	}
	/**
	 * Require an external Javascript file. to be loaded.
	 * @param $url The full URL of the resource to include, or, if beginning with ~/, relative to the Web base URL 
	 * @return void
	 */
	public function JS(string $url) : void 
	{
		if( Str\starts_with($url, "~/") )	$url = $this->WebURL(Str\slice($url, 2)); 
		$this->htmlHead->add(\sxhp_js($url));
	}


	// 
	// Locale stuff
	//

	/**
	 * Return a standardized HTML nav containing links to switch locales, in their respective languages.
	 * If this happens after a LOCALE call has already been made, only the locales supplied in the argument to that function will be rendered here.
	 * @return nav#LOCALES > a 
	 */
	public function getLocaleNav() : XHPRoot
	{
		$LocaleKeys = $this->LocaleKeys;
		$list = \sxhp_nav();
		if($LocaleKeys is null) return $list; 
		if(\count($LocaleKeys) == 0) return $list;

		foreach($this->LocaleKeys ?? array() as $locale) { 
			$list->appendChild(\sxhp_link('?locale='.$locale, $this->LOCALE_NAMES_NATIVE[$locale]));
		}
		return $list;
	}

	//
	// Other
	//

	public function ImportSVG(string $file) : \XHPUnsafeRenderable { return new \sxhp_unsafe_file($file, $this); }
}
