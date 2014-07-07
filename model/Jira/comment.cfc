component name="comment" displayname="Jira Comment" extends="model.Jira" {
	property name="id"
		fieldtype=    "id"
		default=      0
		type=         "numeric"
		field=        "id"
		displayname=  "ID"
	;
	property name="body"
		default=      ""
		type=         "string"
		field=        "body"
		displayname=  "Body"
	;
	property name="author"
		default=      ""
		type=         "string"
		field=        "author"
		displayname=  "Created By"
	;
	property name="authorDisplay"
		default=      ""
		type=         "string"
		field=        "authorDisplay"
		displayname=  "Created By"
	;
	property name="updateAuthor"
		default=      ""
		type=         "string"
		field=        "updatedAuthor"
		displayname=  "Updated By"
	;
	property name="created"
		default=      ""
		type=         "date"
		field=        "created"
		displayname=  "Created At"
	;
	property name="updated"
		default=      ""
		type=         "date"
		field=        "updated"
		displayname=  "Updated At"
	;


	public model.Jira.comment function init () {
		SUPER.init();

		return THIS;
	}


}