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
			setBaseUrl( data.baseUrl );
			callback ? callback( getBaseUrl() ) : null;
		});
	};


	function setBaseUrl ( url ) {
		urlJiraServiceBase = url ? url.toString() : null;
	};


	function setCreateTaskUrl ( path, callback ) {
		urlJiraCreateSubtasks = getBaseUrl() + ( path || "?method=createIssueSubtask" );

		callback ? callback( getCreateTaskUrl() ) : null;

		return jrt.getCreateTaskUrl();
	}


	function setSubtaskUrl ( path, callback ) {
		urlJiraGetSubtasks = getBaseUrl() + ( path || "?method=getSubTasksByIssue" );

		callback ? callback( getSubtaskUrl() ) : null;

		return jrt.getSubtaskUrl();
	}
	// END: Private methods
})( ( window.jrt = window.jrt || {} ), jQuery );



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
		$("nav").on("click",SELECTOR.BUTTON.CREATE_TASKS,createSubTask);
		$("nav").on("click",SELECTOR.BUTTON.CLEAR_SELECTED,clearChecked);
		$("nav").on("click",SELECTOR.BUTTON.SELECT_REQUIRED,checkreq);
		$("nav").on("click",SELECTOR.BUTTON.SELECT_ALL,checkall);
		$("nav").on("submit",SELECTOR.FORM.AUTHENTICATE,ui.loginEvent);
		$("nav").on("click",SELECTOR.BUTTON.LOGOUT,ui.logoutEvent);

		loginSuccess();

		$(SELECTOR.BUTTON.LOGOUT).hide().attr("disabled", true);
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

			getSubTasks( issue.id );
		} else {
			$("#issueSummary").html( $("<span>").addClass("label label-danger").text("ISSUE NOT FOUND") );
			$("#issueStatus").html("");
			ui.removeSubtasks();
			resetHighlighting();
		}
	}


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
		console ? console.log("loginError") : null;
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

	iss.find = function ( keyOrId, success, error ) {
		$.ajax( getBaseUrl()+"?method=getIssueByKey",{
			"data":   {
				"issueKey": keyOrId || ""
			},
			"dataType": "json",
			"error": error,
			"success": success
		});
	}


	iss.parseWebUrl = function ( issue ) {
		return issue.self.replace("rest/api/2/issue", "browse").replace(issue.id, issue.key);
	};
})( ( jrt.issue = jrt.issue || {} ) );
/**********************************
 * END: Issue module
**********************************/



function getSubTasks(id){
	data = 'issueid=' + id;
	JQajax(
		jrt.getSubtaskUrl(),
		data,
		handleSubTaskIssues
	);
}


function handleSubTaskIssues(data){
	jrt.ui.removeSubtasks();

	var issues = $.parseJSON(data);
	for ( var i in issues ) {
		issue = issues[i];

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
	}
}


function createSubTask(){
	var taskVal, data;

	if ($("#issueStatus").html() == '') {
		jrt.ui.notify( "You must find a valid Jira issue to create sub-tasks" );

		return false;
	}

	$("#subTasks input[type=checkbox]").each(function () {
		if($(this).is(':checked')){
			taskVal = $(this).val();

			data = {
				"parentKey": $("#parentKey").val(),
				"projectKey": $("#parentKey").val().split("-")[0],
				//"issueTypeId": $("#issueTypeVal_" + taskVal).val(),
				"issueTypeName": $("#taskrow_" + $("#issueTypeVal_" + taskVal).val() + " img").attr( "title" ),
				"summary": $("#summary_" + taskVal).val()/* ,
				"description": "" */
			};

			if(data.summary.length > 4){
				JQajax(jrt.getCreateTaskUrl(),data,createSubTaskCallback );
			}
		}
	});

	setTimeout(function(){
		jrt.issue.find( jrt.ui.getIssueSearchValue(), jrt.ui.issueSearchSuccess );
	},2000);
}


function createSubTaskCallback(data){
	try {
	var obj = jQuery.parseJSON(data);
} catch (e) {
	console.log("there was an error parsing create issue response");
	console.dir(data);
}

	//$(".issueType_" + obj.TYPEID).prop('checked', false);
}


function buildFormDataJQuery(form,incUnchecked) {
	var data, my_form;

	try {
		my_form = $("[name=" + form + "]");
		data = $(my_form).serialize();

		if (incUnchecked){
			data += unCheckedBoxes(form);
			data + emptyMultiSelect(form);
		}
	} catch(err) {
		data = buildFormData(form);
	}

	return data;
}


function JQajax( url, data, callback ) {
	var myCaller = arguments.callee.caller;

	$.ajax({
		data:data,
		error:function(jqXHR, textStatus, errorThrown){
			var message = "";

			message += "AJAX Request Failed!";
			message += "\nStatus: " + textStatus;
			message += "\nError: " + errorThrown.toString();
			message += "\nURL: " + url.toString();
			message += "\nData: " + JSON.stringify( data ).toString();
			if ( myCaller )
				message += "\nCalling function: " + myCaller.toString();

			console ? console.log( message ) : null;
		},
		success:function(data, textStatus, jqXHR){
			if (typeof(callback) === 'function') {
				callback(data);
			}
		},
		url:url.toString()
	});
}


function checkall() {
	$("#subTasks input[type=checkbox]").each(function () {
		$(this).prop("checked", true);
	});
}


function clearChecked(){
	$("#subTasks input[type=checkbox]").each(function () {
		$(this).prop("checked", false);
	});
}


function checkreq() {
	clearChecked();

	$(".required input[type=checkbox]").each(function () {
		$(this).prop("checked", true);
	});
}


function getIssueTypeIcons () {
	var type;

	$( ".taskrow" ).each(function(){
		type = $(this).attr("x-jira-issue-type");

		$(this).find(".task-type").prepend(
			$("<img>")
				.attr("src","nowhere")
				.attr("title","something")
		);
	});
}


$(document).ready(jrt.init);