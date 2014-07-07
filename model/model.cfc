component name="model" {
	VARIABLES[ "helpers" ]=   {};
	VARIABLES[ "includes" ]=  [];
	VARIABLES[ "members" ]=   [];

	VARIABLES[ "qData" ]=     QueryNew( "" );



	public model function init( numeric id ) {
		if ( IsDefined( "ARGUMENTS.id" ) ) {
			setId( ARGUMENTS.id );
			_getData();
		}

		VARIABLES.includes.add( "JSON" );
		_loadIncludes();

		return THIS;
	}



	/******************/
	/******************/
	/* BEGIN: Getters */
	public string function getLabel( required string property ) {
		var aProperties = _getProperties();
		var oProperty = {};
		var i = 0;
		var label = "";

		for ( i = 1; i <= ArrayLen( aProperties ); i++ ) {
			oProperty = aProperties[ i ];

			if ( oProperty.name EQ ARGUMENTS.property ) {
				if ( StructKeyExists( oProperty, "label" ) ) {
					label = oProperty.label;
				} else if ( StructKeyExists( oProperty, "displayName" ) ) {
					label = oProperty.displayName;
				} else {
					label = oProperty.name;
				}

				break;
			}
		}

		return label;
	}


	public array function getMembers() {
		return VARIABLES.members;
	}


	public any function getProperty( required string name ) {
		if ( StructKeyExists( VARIABLES, ARGUMENTS.name ) ) {
			return VARIABLES[ ARGUMENTS.name ];
		}

		return;
	}
	/* END: Getters */
	/****************/
	/****************/



	/******************/
	/******************/
	/* BEGIN: Setters */
	public void function setProperties( required struct props ) {
		var key = "";

		for ( key in ARGUMENTS.props ) {
			if ( IsDefined( "ARGUMENTS.props.#key#" ) ) {
				setProperty( key, ARGUMENTS.props[ key ] );
			}
		}

		return;
	}


	public void function setProperty( required string name, required any value ) {
		if ( _hasMethod( "set" & ARGUMENTS.name ) ) {
			//Evaluate( "set#ARGUMENTS.name#( ARGUMENTS.value )" );
			//var method = _getMethod( ARGUMENTS.name );
			//method( ARGUMENTS.value );
		} else {

		}

		VARIABLES[ ARGUMENTS.name ] = ARGUMENTS.value;

		return;
	}
	/* END: Setters */
	/****************/
	/****************/



	/*****************************/
	/*****************************/
	/* BEGIN: Conversion methods */
	public numeric function toNumber() {
		return 0;
	}


	public string function toString() {
		//return SerializeJson( THIS.toStruct() );
		return SerializeJson( THIS );
	}


	public struct function toStruct( model exclude ) {
		var aProperties = _getPropertyList();
		var i = 0;
		var j = 0;
		var property = "";
		var stData = {};
		var subProperty = {};

		for ( i = 1; i <= ArrayLen( aProperties ); i++ ) {
			property = aProperties[ i ];

			if ( StructKeyExists( VARIABLES, property ) ) {
				if ( IsArray( VARIABLES[ property ] ) ) {
					// stData[ property ] = [ VARIABLES[ property ] ];
					stData[ property ] = [];

					for ( j = 1; j <= ArrayLen( VARIABLES[ property ] ); j++ ) {
						subProperty = VARIABLES[ property ][ j ];

						if ( !( IsDefined( "ARGUMENTS.exclude" ) && ARGUMENTS.exclude == subProperty ) ) {
							// stData[ property ].add( subProperty.toStruct( THIS ) );
						}

						// stData[ property ].add( subProperty.toStruct() );
						// stData[ property ].add( subProperty );
					}
				} else if ( IsObject( VARIABLES[ property ] ) ) {
					if ( !( IsDefined( "ARGUMENTS.exclude" ) && ARGUMENTS.exclude == VARIABLES[ property ] ) ) {
						stData[ property ] = VARIABLES[ property ].toStruct();
					}
				} else {
					stData[ property ] = VARIABLES[ property ].toStruct();
				}
			}
		}

		// return DeserializeJson( SerializeJson( THIS ) );
		return stData;
	}
	/* END: Conversion methods */
	/***************************/
	/***************************/



	public void function loadData()
			hint="Public method to invoke loading of data from database for object." {
		_loadData();

		return;
	}


	public any function OnMissingMethod( required string missingMethodName, required struct missingMethodArguments ) {
		var name = ARGUMENTS.missingMethodName;
		var args = ARGUMENTS.missingMethodArguments;

		if ( Left( name, 3 ) EQ "set" && Len( name ) GT 3 ) {
			return setProperty( Mid( name, 4, Len( name ) ), args[1] );
		} else if ( Left( name, 3 ) EQ "get" && Len( name ) GT 3 ) {
			return getProperty( Mid( name, 4, Len( name ) ), args[1] );
		}

		return;
	}



	/**************************/
	/**************************/
	/* BEGIN: Private Methods */
	private struct function _convertToStruct( aProperties ) {
		var i = 0;
		var propLen = ArrayLen( ARGUMENTS.aProperties );
		var returnStruct = {};

		for ( i = 1; i <= propLen; i++ ) {
			returnStruct[ ARGUMENTS.aProperties[i].name ] = ARGUMENTS.aProperties[i];
		}

		return returnStruct;
	}

	private array function _getColumnList() {
		var aList = [];
		var aProperties = _getProperties();
		var i = 0;
		var oProperty = {};

		for ( i = 1; i <= ArrayLen( aProperties ); i++ ) {
			oProperty = aProperties[ i ];
			if ( StructKeyExists( oProperty, "column" ) ) {
				aList.add( oProperty.column );
			}
		}

		return aList;
	}

	private query function _getData() {
		var i=         0;
		var propType=  "string";
		var props=     _getProperties();
		var q=         new query( dsn=VARIABLES.dsn );
		var sql=       "";

		sql = "SELECT " & ArrayToList( _getColumnList() );
		sql &= " FROM " & _getTable() & " pp";
		sql &= " WHERE 1=1 AND ROWNUM <= 50";
		for ( i = 1; i <= ArrayLen( props ); i++ ) {
			if ( StructKeyExists( props[i], "column" ) && Len( getProperty( props[i].name ) ) > 0 ) {
				propType = "string";

				if ( StructKeyExists( props[i], "type" ) ) {
					propType = props[i].type;
				}

				switch( LCase(propType) ) {
					case "date":
					case "datetime":
					case "time":
						sql &= " AND #props[i].column# = :#props[i].name# ";
						q.addParam( name=props[i].name, value=getProperty( props[i].name ), cfsqltype="cf_sql_datetime" );
						break;
					case "number":
					case "numeric":
						if ( getProperty( props[i].name ) > 0 ) {
							sql &= " AND #props[i].column# = :#props[i].name# ";
							q.addParam( name=props[i].name, value=getProperty( props[i].name ), cfsqltype="cf_sql_numeric" );
						}
						break;
					default:
						sql &= " AND REGEXP_LIKE( #props[i].column#, :#props[i].name# , 'i' )";
						q.addParam( name=props[i].name, value=getProperty( props[i].name ), cfsqltype="cf_sql_varchar" );
						break;
				}
			}
		}

		VARIABLES.qData = q.execute( sql=sql ).getResult();

		return VARIABLES.qData;
	}


	private any function _getMethod( required string method ) {
		return VARIABLES[ ARGUMENTS.method ];
	}


	private struct function _getMethods() {
		var methods=   {};
		var i=         0;
		var metaData=  GetMetaData( THIS );

		if ( StructKeyExists( metaData, "extends" ) ) {
			for ( i = 1; i <= ArrayLen( metaData.extends.functions ); i++ ) {
				methods[ metaData.extends.functions[i].name ] = metaData.extends.functions[i];
			}
		}

		for ( i = 1; i <= ArrayLen( metaData.functions ); i++ ) {
			methods[ metaData.functions[i].name ] = metaData.functions[i];
		}

		return methods;
	}


	private array function _getProperties() {
		return GetMetaData( THIS ).properties;
	}


	private array function _getPropertyList() {
		var aList = [];
		var aProperties = _getProperties();
		var i = 0;
		var propLen = ArrayLen( ARGUMENTS.aProperties );

		for ( i = 1; i <= propLen; i++ ) {
			aList.add( aProperties[ i ].name );
		}

		return aList;
	}


	private string function _getTable() {
		return GetMetaData( THIS ).table;
	}


	private boolean function _hasMethod( required string method ) {
		if ( StructKeyExists( _getMethods(), ARGUMENTS.method ) ) {
			return true;
		}

		return false;
	}

	private void function _loadData() {
		var aProperties = _getProperties();
		var i = 0;
		var j = 0;
		var oMember = {};
		var oProperty = {};

		// Queries the database and saves result set in VARIABLES.qData
		_getData();

		for ( i = 1; i <= VARIABLES.qData.RecordCount; i++ ) {
			if ( VARIABLES.qData.RecordCount > 1 ) {
				oMember = new "#GetMetaData( THIS ).name#"();
			} else {
				oMember = THIS;
			}

			for ( j = 1; j <= ArrayLen( aProperties ); j++ ) {
				oProperty = aProperties[ j ];
				if ( StructKeyExists( oProperty, "column" ) && StructKeyExists( VARIABLES.qData, oProperty.column ) ) {
					if ( IsValid( "integer", VARIABLES.qData[ oProperty.column ][ i ] ) ) {
						// TODO: This doesn't work correctly
						oMember.setProperty( oProperty.name, JavaCast( "long", REReplace( VARIABLES.qData[ oProperty.column ][ i ] , "[^\.0-9]+", "", "all" ) ) );
					} else if ( IsDate( VARIABLES.qData[ oProperty.column ][ i ] ) ) {
						oMember.setProperty( oProperty.name, helpers.JSON.toInternetTime( VARIABLES.qData[ oProperty.column ][ i ] ) );
					} else {
						oMember.setProperty( oProperty.name, VARIABLES.qData[ oProperty.column ][ i ] );
					}
				}
			}

			VARIABLES.members.add( oMember );
		}

		return;
	}


	private void function _loadIncludes() {
		var i = 0;

		for ( i = 1; i <= ArrayLen( VARIABLES.includes ); i++ ) {
			VARIABLES.helpers[ VARIABLES.includes[i] ] = new "helper.#VARIABLES.includes[i]#"();
		}
	}
}