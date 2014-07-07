component name="JSON" hint="JSON Helper Class" {
	public JSON function init () {
		return THIS;
	}


	public any function toInternetTime( required date dt ) {
		var oTimezone = CreateObject( "java", "java.util.Calendar" ).getInstance().getTimeZone();
		var tzAbbr = "GMT";

		tzAbbr = oTimezone.getDisplayName( oTimezone.inDaylightTime( ARGUMENTS.dt ), oTimezone.SHORT );

		return(
			DateFormat( ARGUMENTS.dt, "ddd, dd mmm yyyy " ) &
			TimeFormat( ARGUMENTS.dt, "HH:mm:ss" ) &
			" " & tzAbbr
		);
		//return DateFormat( ARGUMENTS.dt, "yyyy-mm-ddT" ) & TimeFormat( ARGUMENTS.dt, "HH:mm:ss.00-" ) & NumberFormat( GetTimeZoneInfo().utcHourOffset * 100, "0999" );
	}
}