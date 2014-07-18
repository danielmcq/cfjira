interface name="webResponder" {
	public string function htmlBody     ( required struct webRequest );
	/**
	 * @returnformat "JSON"
	 */
	public string function jsonResponse ( required struct webRequest );
	public string function xmlResponse  ( required struct webRequest );
}