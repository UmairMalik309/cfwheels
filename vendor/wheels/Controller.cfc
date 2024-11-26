component output="false" displayName="Controller" extends="wheels.Global"{

	include "/wheels/controller/functions.cfm";
	include "/wheels/view/functions.cfm";
	include "/wheels/plugins/standalone/injection.cfm";
	if (
		IsDefined("application")
		&& StructKeyExists(application, "wheels")
		&& StructKeyExists(application.wheels, "viewPath")
	) {
		include "/wheels/tests/_assets/views/helpers.cfm";
	}

}
