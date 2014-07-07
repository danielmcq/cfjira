interface name="httpHost" extends="host" {
	public string function $getBaseUrl  ();
	public string function $getBasePath ();
	public string function $getProtocol ();
	public void   function $setBasePath ( required string path );
	public void   function $setProtocol ( required string protocol );
}