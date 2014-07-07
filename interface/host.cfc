interface name="host" {
	public string  function $getHost     ();
	public string  function $getPassword ();
	public struct  function $getParams   ();
	public numeric function $getPort     ();
	public string  function $getUsername ();
	public void    function $setHost     ( required string hostName );
	public void    function $setParams   ( required struct params );
	public void    function $setPassword ( required string pass );
	public void    function $setPort     ( required numeric portNumber );
	public void    function $setUsername ( required string user );
}