component name="webRequest" {
	if ( !StructKeyExists( VARIABLES, "initialized" ) ) {
		VARIABLES[ "initialized" ] = false;

		init();
	}


	public webRequest function init () {
		VARIABLES["cgi"]      = {};
		VARIABLES["cookie"]   = {};
		VARIABLES["form"]     = {};
		VARIABLES["headers"]  = {};
		VARIABLES["template"] = {};
		VARIABLES["url"]      = {};

		return THIS;
	}


	public struct function getCookie () {
		return Duplicate( VARIABLES.cookie );
	}


	public struct function getForm () {
		return Duplicate( VARIABLES.form );
	}


	public struct function getHeaders () {
		return Duplicate( VARIABLES.headers );
	}


	public string function getTemplate () {
		return VARIABLES.template;
	}


	public struct function getUrl () {
		return Duplicate( VARIABLES.url );
	}


	public void function setCookie ( required struct cookie ) {
		VARIABLES.cookie = ARGUMENTS.cookie;
	}


	public void function setForm ( required struct form ) {
		VARIABLES.form = ARGUMENTS.form;
	}


	public void function setHeaders ( required struct headers ) {
		VARIABLES.headers = ARGUMENTS.headers;
	}


	public void function setTemplate ( required string template ) {
		VARIABLES.template = ARGUMENTS.template;
	}


	public void function setUrl ( required struct url ) {
		VARIABLES.url = ARGUMENTS.url;
	}
}