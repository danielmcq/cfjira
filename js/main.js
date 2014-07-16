// Jira Rest Tool :: JRT
(function ( jrt, $, undefined ) {
	// BEGIN: Private variables
	var urlJiraServiceBase,
	    urlJiraGetSubtasks,
	    urlJiraCreateSubtasks;
	// END: Private variables

	// BEGIN: Public methods
	jrt.init = function(){
		getJiraUrl( function(){
			setCreateTaskUrl();
			setSubtaskUrl();

			for ( var key in jrt ) {
				if ( typeof jrt[key] !== null && typeof jrt[key].init != "undefined" ) {
					jrt[key].init()
				}
			}
		});

		return this;
	}


	jrt.getCreateTaskUrl = function () {
		return urlJiraCreateSubtasks;
	};


	jrt.getSubtaskUrl = function () {
		return urlJiraGetSubtasks;
	}
	// END: Public methods


	// BEGIN: Package methods
	this.getBaseUrl = function( callback ){
		if ( typeof urlJiraServiceBase != "string" )
			getJiraUrl();

		callback ? callback( getBaseUrl() ) : null;

		return urlJiraServiceBase;
	};
	// END: Package methods


	// BEGIN: Private methods
	function getJiraUrl ( callback ) {
		$.get("?format=json",function(data,textStatus,jqXHR){
			// TODO: The whole "getBasrUrl" functionality needs to be re-arch'd
			// to handle the delay in the response
			//setBaseUrl( data.baseUrl );
			// Hardcoding until this can be fixed
			setBaseUrl( "JiraProxy.cfc" );
			callback ? callback( getBaseUrl() ) : null;
		});
	};


	function setBaseUrl ( url ) {
		urlJiraServiceBase = url ? url.toString() : null;
	};


	function setCreateTaskUrl ( path, callback ) {
		getBaseUrl(function(base){
			urlJiraCreateSubtasks = base + ( path || "?method=createIssueSubtask" );

			callback ? callback( getCreateTaskUrl() ) : null;
		});

		return jrt.getCreateTaskUrl();
	}


	function setSubtaskUrl ( path, callback ) {
		getBaseUrl(function(base){
			urlJiraGetSubtasks = base + ( path || "?method=getSubTasksByIssue" );

			callback ? callback( getSubtaskUrl() ) : null;
		});

		return jrt.getSubtaskUrl();
	}
	// END: Private methods
})( ( window.jrt = window.jrt || {} ), jQuery );