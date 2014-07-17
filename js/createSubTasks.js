/**********************************
 * BEGIN: UI module
**********************************/
(function ( ui, undefined ) {
	var TEXT_ISSUE_SEARCH_NOT_FOUND = "ISSUE NOT FOUND";
	var SELECTOR = {
		BUTTON: {
			CREATE_TASKS: "#createTasksButton",
			CLEAR_SELECTED: "#clear",
			LOGIN: "#login",
			LOGOUT: "#logout",
			SELECT_ALL: "#checkAll",
			SELECT_REQUIRED: "#checkRequired"
		},
		FORM: {
			AUTHENTICATE: "#authenticateForm",
			PARENT_ISSUE: "#parentIssueForm"
		},
		INPUT: {
			ISSUE_KEY: "#parentKey",
			PASSWORD: "#pwd",
			USERNAME: "#username"
		}
	};
	var HEADER = {
		USERNAME: "X-AUSERNAME"
	};


	// BEGIN: Public methods
	ui.init = function(){
		$(SELECTOR.FORM.PARENT_ISSUE).on("click keypress","button,"+SELECTOR.INPUT.ISSUE_KEY,ui.issueSearchEvent);
		$("nav").on( "click",  SELECTOR.BUTTON.CREATE_TASKS,    ui.issueCreateSubTasks);
		$("nav").on( "click",  SELECTOR.BUTTON.CLEAR_SELECTED,  ui.issuesUnmarkAll);
		$("nav").on( "click",  SELECTOR.BUTTON.SELECT_REQUIRED, ui.issuesMarkRequired);
		$("nav").on( "click",  SELECTOR.BUTTON.SELECT_ALL,      ui.issuesMarkAll);
		$("nav").on( "submit", SELECTOR.FORM.AUTHENTICATE,      ui.loginEvent);
		$("nav").on( "click",  SELECTOR.BUTTON.LOGOUT,          ui.logoutEvent);

		loginSuccess();

		$(SELECTOR.BUTTON.LOGOUT).hide().attr("disabled", true);
	};


	ui.addSubTaskIssue = function ( issueOrId ) {
		var issue;

		if (
			typeof issueOrId.fields != "undefined"
			&& typeof issueOrId.fields.issuetype != "undefined"
			&& typeof issueOrId.fields.status != "undefined"
			&& typeof issueOrId.fields.summary != "undefined"
		) {
			issue = issueOrId;

			$('.task_' + issue.fields.issuetype.id +" .list-group").append(
				$("<li>").addClass("list-group-item existingTask").append(
					$("<img>")
							.attr("src", issue.fields.status.iconUrl)
							.attr("title", issue.fields.status.name)
				)
				.append(
						$("<a>")
						.attr("href", jrt.issue.parseWebUrl(issue))
						.attr("target", "_blank")
						.text(" "+issue.key)
				).append(" "+issue.fields.summary)
			);

			$('.task_' + issue.fields.issuetype.id).each(function () {
				$(this).removeClass("list-group-item-danger").addClass("list-group-item-success");
				$(this).find(".input-group").removeClass("has-error").addClass("has-success");
				$(this).find(".badge").text($(this).find(".list-group-item.existingTask").length)
			});
		} else {
			jrt.issue.find( issueOrId, ui.addSubTaskIssue );
		}
	};


	ui.addSubTaskIssues = function ( issues ) {
		for ( var i in issues ) {
			ui.addSubTaskIssue( issues[i] );
		}
	};


	ui.disableControls = function () {
		$( SELECTOR.BUTTON.CREATE_TASKS ).prop( "disabled", true );
		$( SELECTOR.BUTTON.CLEAR_SELECTED ).prop( "disabled", true );
		$( SELECTOR.BUTTON.SELECT_REQUIRED ).prop( "disabled", true );
		$( SELECTOR.BUTTON.SELECT_ALL ).prop( "disabled", true );
	};


	ui.enableControls = function () {
		$( SELECTOR.BUTTON.CREATE_TASKS ).prop( "disabled", false );
		$( SELECTOR.BUTTON.CLEAR_SELECTED ).prop( "disabled", false );
		$( SELECTOR.BUTTON.SELECT_REQUIRED ).prop( "disabled", false );
		$( SELECTOR.BUTTON.SELECT_ALL ).prop( "disabled", false );

	};


	ui.issueCreateSubTasks = function (){
		var taskVal, subtask;

		if ($("#issueStatus").html() == '') {
			jrt.ui.notify( "You must find a valid Jira issue to create sub-tasks" );

			return false;
		}

		$( "#subTasks input[type=checkbox]" ).each(function () {
			if($(this).is(':checked')){
				taskVal = $(this).val();

				subtask = {
					"parentKey": $("#parentKey").val(),
					"projectKey": $("#parentKey").val().split("-")[0],
					"issueTypeId": $("#issueTypeVal_" + taskVal).val(),
					"issueTypeName": $("#taskrow_" + $("#issueTypeVal_" + taskVal).val() + " img").attr( "title" ),
					"summary": $("#summary_" + taskVal).val()
				};
				jrt.issue.createSubTask( subtask, new Date().getTime().toString() );
			}
		});

		// TODO: Change this so that a proper callback is fired after all
		// subtask creation threads are complete.
		setTimeout(function(){
			jrt.issue.find( jrt.ui.getIssueSearchValue(), jrt.ui.issueSearchSuccess );
		},2000);
	};


	ui.getIssueSearchValue = function () {
		return $( SELECTOR.INPUT.ISSUE_KEY ).val();
	};


	ui.issueSearchEvent = function(event){
		var key;

		if ( event.which == 13 || $(event.target).hasClass("btn") ) {
			key = ui.getIssueSearchValue();

			if ( key.length ) {
				jrt.issue.find( key, ui.issueSearchSuccess );
			}

			return false;
		}
	};


	ui.issueSearchSuccess = function ( issue ) {
		if ( typeof issue.id != "undefined" ) {
			$("#issueStatus").html(
				$("<img>")
					.attr("src",issue.fields.status.iconUrl)
					.attr("title",issue.fields.status.name)
			).append(" "+issue.fields.status.name);
			$("#issueSummary").html(
				$("<img>")
					.attr("src",issue.fields.issuetype.iconUrl)
					.attr("title",issue.fields.issuetype.name)
			).append(
				" "
			).append(
				$("<a>")
					.attr("href",jrt.issue.parseWebUrl(issue))
					.text(issue.key)
			).append(" "+issue.fields.summary);

			jrt.issue.getSubTasks( issue.id );
		} else {
			$("#issueSummary").html( $("<span>").addClass("label label-danger").text("ISSUE NOT FOUND") );
			$("#issueStatus").html("");
			ui.removeSubtasks();
			resetHighlighting();
		}
	}


	ui.issuesMarkAll = function () {
		$("#subTasks input[type=checkbox]").each(function () {
			$(this).prop("checked", true);
		});
	};


	ui.issuesMarkRequired = function () {
		ui.issuesUnmarkAll();

		$(".required input[type=checkbox]").each(function () {
			$(this).prop("checked", true);
		});
	};


	ui.issuesUnmarkAll = function (){
		$("#subTasks input[type=checkbox]").each(function () {
			$(this).prop("checked", false);
		});
	};


	ui.loginEvent = function (event) {
		var username = $(SELECTOR.INPUT.USERNAME).val();
		var password = $(SELECTOR.INPUT.PASSWORD).val();

		jrt.session.login( username, password, loginSuccess, loginError );

		return false;
	};


	ui.logoutEvent = function (event) {
		jrt.session.logout( logoutSuccess, logoutError );
	};


	ui.notify = function ( message ) {
		alert(message);
	};


	ui.removeSubtasks = function(){
		$(".existingTask").remove();
	};
	// END: Public methods


	// BEGIN: Private Methods
	function loginError (jqXHR,textStatus,errorThrown) {
		if (
				errorThrown === "Unauthorized"
				&& typeof jqXHR.responseJSON != "undefined"
				&& typeof jqXHR.responseJSON.response.body != "undefined"
		) {
			var response = jqXHR.responseJSON.response.body;

			if ( typeof response.errorMessages != "undefined" ) {
				ui.notify( response.errorMessages.join( "\n" ) );
			}
		}
	}


	function loginSuccess (data,textStatus,jqXHR) {
		jrt.session.get(function( session ){
			if ( session.authenticated ) {
				$(SELECTOR.INPUT.USERNAME).hide().attr("disabled", true).val("");
				$(SELECTOR.INPUT.PASSWORD).hide().attr("disabled", true).val("");
				$(SELECTOR.BUTTON.LOGIN).hide().attr("disabled", true);
				$(SELECTOR.BUTTON.LOGOUT).show().attr("disabled", false);

				$("#loggedInUser .name").show().text(session.username);
				$("#loggedInUser").show();
			}
		});
	}


	function logoutError (jqXHR,textStatus,errorThrown) {
	}


	function logoutSuccess (data,textStatus,jqXHR) {
		$(SELECTOR.INPUT.USERNAME).show().attr("disabled", false).val("");
		$(SELECTOR.INPUT.PASSWORD).show().attr("disabled", false).val("");
		$(SELECTOR.BUTTON.LOGIN).show().attr("disabled", false);
		$(SELECTOR.BUTTON.LOGOUT).hide().attr("disabled", true);

		$("#loggedInUser .name").hide().text("Not logged in");
		$("#loggedInUser").hide();
	}


	function resetHighlighting () {
		$(".required").removeClass("alert-success").addClass("alert alert-danger");
	}
	// END: Private Methods
})( ( jrt.ui = jrt.ui || {} ) );
/**********************************
 * END: UI module
**********************************/



/**********************************
 * BEGIN: Session module
**********************************/
(function ( sess, undefined ) {
	var session = {
		authenticated: false,
		username: ""
	};


	sess.init = function () {
		//sess.get();
	};


	sess.get = function ( ready ) {
		$.ajax( getBaseUrl()+"?method=getSession",{
			"dataType": "json",
			"error": function(jqXHR,textStatus,errorThrown){
				setAuthenticated(false);

				ready ? ready(copySession()) : null;
			},
			"success": function(data,textStatus,jqXHR){
				setAuthenticated(true);
				session.username = data.response.body.name;

				ready ? ready(copySession()) : null;
			}
		});
	};


	sess.login = function ( username, password, success, error ) {
		$.ajax( getBaseUrl()+"?method=login",{
			"method": "POST",
			"data":   {
				"username": username || "",
				"password": password || ""
			},
			"dataType": "json",
			"error": error,
			"success": function(data,textStatus,jqXHR){
				setAuthenticated(true);
				success(data,textStatus,jqXHR);
			}
		});
	};


	sess.logout = function ( success, error ) {
		$.ajax( getBaseUrl()+"?method=logout",{
			"dataType": "json",
			"error": error,
			"success": function(data,textStatus,jqXHR){
				setAuthenticated(false);
				success( data, textStatus, jqXHR );
			}
		});
	};


	// Return a copy of the session so that outside objects can't modify state
	function copySession () {
		return JSON.parse( JSON.stringify( session ) );
	}


	function getAuthenticated () {
		return session.authenticated;
	}


	function setAuthenticated ( val ) {
		// Fancy way of ensuring that only a boolean value is set
		session.authenticated = val && true || false;
	}
})( ( jrt.session = jrt.session || {} ) );
/**********************************
 * END: Session module
**********************************/



/**********************************
 * BEGIN: Issue module
**********************************/
(function ( iss, undefined ) {
	var isAuthenticated = false;
	var createQueue = {};


	iss.createSubTask = function ( subtask, requestId ){
		var MIN_SUMMARY_LENGTH = 4;

		if ( !requestId ) requestId = new Date().getTime().toString();

		if ( subtask.summary.length > MIN_SUMMARY_LENGTH ) {
			createQueueAdd( requestId );
			$.ajax({
				url: jrt.getCreateTaskUrl(),
				data: subtask,
				"success": function ( data, textStatus, jqXHR ){
					if ( typeof data.key != "undefined" ) {
						jrt.ui.addSubTaskIssue( data );
					}
				},
				"error": function ( jqXHR, textStatus, errorThrown ) {
					jrt.ui.notify( "Failed to create subtask\n'"+subtask.summary+"'" );
				},
				"complete": function ( jqXHR, textStatus ) {
					createQueueRemove( requestId );
				}
			});
		} else {
			jrt.ui.notify( "Summary length must be more than "+MIN_SUMMARY_LENGTH+" characters long." );
		}
	};


	iss.find = function ( issueOrId, success, error ) {
		var id;

		if ( typeof issueOrId.key != "undefined" ) {
			id = issueOrId.key;
		} else {
			id = issueOrId.toString();
		}

		$.ajax( getBaseUrl()+"?method=getIssueByKey",{
			"data":   {
				"issueKey": id || ""
			},
			"dataType": "json",
			"error": error,
			"success": success
		});
	};


	iss.getSubTasks = function ( id ){
		var data = 'issueid=' + id;
		$.ajax({
			url: jrt.getSubtaskUrl(),
			data: data,
			success: function( data, textStatus, jqXHR ) {
				var issues = $.parseJSON( data );

				jrt.ui.removeSubtasks();
				jrt.ui.addSubTaskIssues( issues );
			},
			error: function ( jqXHR, textStatus, errorThrown ) {
				jrt.ui.notify( "Error finding issue '"+id+"'" );
			}
		});
	};


	iss.parseWebUrl = function ( issue ) {
		return issue.self.replace("rest/api/2/issue", "browse").replace(issue.id, issue.key);
	};


	function createQueueAdd ( requestId ) {
		if ( $.isEmptyObject( createQueue ) ) eventQueueFillStart();

		createQueue[ requestId ] = null;
		eventQueueAdd();
	}


	function createQueueRemove ( requestId ) {
		delete createQueue[ requestId ];

		if ( $.isEmptyObject( createQueue ) ) {
			eventQueueEmptied();
		};
	}


	function eventQueueFillStart () {
		jrt.ui.disableControls();
	}


	function eventQueueAdd () {
		// Do nothing
	}


	function eventQueueEmptied () {
		jrt.ui.enableControls();
		jrt.ui.issuesUnmarkAll();
	}
})( ( jrt.issue = jrt.issue || {} ) );
/**********************************
 * END: Issue module
**********************************/