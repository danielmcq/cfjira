component name="XML" hint="XML Helper Class" {
	VARIABLES[ "data" ] = {};


	public component function init () {
		return THIS;
	}


	public struct function toStruct ( required string xmlNode, struct str )
			hint="Converts raw XML string into nested ColdFusion structs and arrays."
	{
		var attributes=    [];
		var i=             0;
		var j=             0;
		var inXml=         "";
		var key=           "";
		var outStruct=     StructNew();
		var tmpContainer=  "";

		if ( !IsDefined( "ARGUMENTS.str" ) ) {
			ARGUMENTS.str = StructNew();
		}

		outStruct = ARGUMENTS.str;

		inXml = XmlSearch( XmlParse(ARGUMENTS.xmlNode ), "/node()" );
		inXml = inXml[1];
		/* For each children of context node: */
		for ( i = 1; i <= ArrayLen( inXml.XmlChildren ); i++ ) {
			/* Read XML node name without namespace: */
			key = Replace(inXml.XmlChildren[i].XmlName, inXml.XmlChildren[i].XmlNsPrefix&":", "");

			/* If key with that name exists within output struct ... */
			if ( StructKeyExists( outStruct, key ) ) {
				/* ... and is not an array... */
				if ( !IsArray( outStruct[key] ) ) {
					/* ... get this item into temp variable, ... */
					tmpContainer = outStruct[key];
					/* ... setup array for this item because we have multiple items with same name, ... */
					outStruct[key] = ArrayNew(1);
					/* ... and reusing temp item as a first element of new array: */
					ArrayAppend( outStruct[key], tmpContainer );
				} else {
					/* Item is already an array: */
				}
				if ( ArrayLen(inXml.XmlChildren[i].XmlChildren) ) {
					/* recurse call: get complex item: */
					ArrayAppend( outStruct[key], toStruct( inXml.XmlChildren[i] ) );
				} else {
					/* else: assign node value as last element of array: */
					ArrayAppend( outStruct[key], inXml.XmlChildren[i].XmlText );
				}
			} else {
				/* This is not a struct. This may be first tag with some name. */
				/* This may also be one and only tag with this name. */
				/* If context child node has child nodes (which means it will be complex type): */
				if ( ArrayLen(inXml.XmlChildren[i].XmlChildren) ) {
					/* recurse call: get complex item: */
					outStruct[key] = toStruct( inXml.XmlChildren[i] );
				} else {
					if ( IsStruct(inXml.XmlAttributes) && StructCount(inXml.XmlAttributes) ) {
						attributes = StructKeyArray(inXml.XmlAttributes);

						for ( j = 1; j <= ArrayLen( attributes ); j++ ) {
							if ( attributes[j] CONTAINS "xmlns:" ) {
								/* remove any namespace attributes */
								StructDelete( inXml.XmlAttributes, attributes[j] );
							}
						}

						/* If there are any attributes left, append them to the response */
						if ( StructCount(inXml.XmlAttributes) ) {
							outStruct['_attributes'] = inXml.XmlAttributes;
						}
					}
					/* else: assign node value as last element of array: */
					/* if there are any attributes on this element */
					if ( IsStruct(inXml.XmlChildren[i].XmlAttributes) && StructCount(inXml.XmlChildren[i].XmlAttributes) ) {
						/* assign the text */
						outStruct[key] = inXml.XmlChildren[i].XmlText;

						/* check if there are no attributes with xmlns: , we don't want namespaces to be in the response */
						attributes = StructKeyArray(inXml.XmlChildren[i].XmlAttributes);

						for ( j = 1; j <= ArrayLen( attributes ); j ) {
							if ( attributes[j] CONTAINS "xmlns:" ) {
								/* remove any namespace attributes */
								StructDelete( inXml.XmlChildren[i].XmlAttributes, attributes[j] );
							}
						}

						/* If there are any attributes left, append them to the response */
						if ( StructCount(inXml.XmlChildren[i].XmlAttributes) ) {
							outStruct[key&'_attributes'] = inXml.XmlChildren[i].XmlAttributes;
						}
					} else {
						outStruct[key] = inXml.XmlChildren[i].XmlText;
					}
				}
			}
		}

		return outStruct;
	}
}