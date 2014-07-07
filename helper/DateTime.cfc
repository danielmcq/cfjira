component name="DateTime" hint="Date and Time Helper Class" {
	VARIABLES[ "data" ] = {};


	public DateTime function init () {
		return THIS;
	}


	public date function parseISODateTimeString ( required string isoDt ) {
		return ParseDateTime( ARGUMENTS.isoDt.ReplaceFirst( "^.*?(\d{4})-?(\d{2})-?(\d{2})T([\d:]+).*$", "$1-$2-$3 $4" ) );
	}


	public string function toISODateTimeString ( required date dt ) {
		return DateFormat( ARGUMENTS.dt, "yyyy-mm-ddT" ) & TimeFormat( ARGUMENTS.dt, "HH:mm:ss.0-0600" );
	}

}