component {
	/**
	 * Use this method to specify which properties can be set through mass assignment.
	 *
	 * [section: Model Configuration]
	 * [category: Miscellaneous Functions]
	 *
	 * @properties Property name (or list of property names) that are allowed to be altered through mass assignment.
	 */
	public void function accessibleProperties(string properties = "") {
		if (StructKeyExists(arguments, "property")) {
			arguments.properties = ListAppend(arguments.properties, arguments.property);
		}

		// see if any associations should be included in the white list
		for (local.association in variables.wheels.class.associations) {
			if (variables.wheels.class.associations[local.association].nested.allow) {
				arguments.properties = ListAppend(arguments.properties, local.association);
			}
		}
		variables.wheels.class.accessibleProperties.whiteList = $listToStruct(arguments.properties);
	}

	/**
	 * Use this method to specify which properties cannot be set through mass assignment.
	 *
	 * [section: Model Configuration]
	 * [category: Miscellaneous Functions]
	 *
	 * @properties Property name (or list of property names) that are not allowed to be altered through mass assignment.
	 */
	public void function protectedProperties(string properties = "") {
		if (StructKeyExists(arguments, "property")) {
			arguments.properties = ListAppend(arguments.properties, arguments.property);
		}
		variables.wheels.class.accessibleProperties.blackList = $listToStruct(arguments.properties);
	}

	/**
	 * Use this method to specify which columns cannot be used by the wheels ORM.
	 *
	 * [section: Model Configuration]
	 * [category: Miscellaneous Functions]
	 *
	 * @columns Array of columns names that will be ignored.
	 */
	public void function ignoredColumns(array columns = []) {
		local.rv = {};
		for (local.column in arguments.columns) {
			local.rv[local.column] = 1;
		}
		variables.wheels.class.ignoredColumns = local.rv;
	}

	/**
	 * Use this method to map an object property to either a table column with a different name than the property or to a SQL expression.
	 * You only need to use this method when you want to override the default object relational mapping that CFWheels performs.
	 *
	 * [section: Model Configuration]
	 * [category: Miscellaneous Functions]
	 *
	 * @name The name that you want to use for the column or SQL function result in the CFML code.
	 * @column The name of the column in the database table to map the property to.
	 * @sql An SQL expression to use to calculate the property value.
	 * @label A custom label for this property to be referenced in the interface and error messages.
	 * @defaultValue A default value for this property.
	 * @select Whether to include this property by default in SELECT statements
	 * @dataType Specify the column dataType for this property
	 * @automaticValidations Enable / disable automatic validations for this property.
	 */
	public void function property(
		required string name,
		string column = "",
		string sql = "",
		string label = "",
		string defaultValue,
		boolean select = "true",
		string dataType = "char",
		boolean automaticValidations
	) {
		// validate setup
		if (Len(arguments.column) && Len(arguments.sql)) {
			Throw(
				type = "Wheels",
				message = "Incorrect Arguments",
				extendedInfo = "You cannot specify both a column and a sql statement when setting up the mapping for this property."
			);
		}
		if (Len(arguments.sql) && StructKeyExists(arguments, "defaultValue")) {
			Throw(
				type = "Wheels",
				message = "Incorrect Arguments",
				extendedInfo = "You cannot specify a default value for calculated properties."
			);
		}

		// create the key
		if (!StructKeyExists(variables.wheels.class.mapping, arguments.name)) {
			variables.wheels.class.mapping[arguments.name] = {};
		}

		if (Len(arguments.column)) {
			variables.wheels.class.mapping[arguments.name].type = "column";
			variables.wheels.class.mapping[arguments.name].value = arguments.column;
		}
		if (Len(arguments.sql)) {
			variables.wheels.class.mapping[arguments.name].type = "sql";
			variables.wheels.class.mapping[arguments.name].value = arguments.sql;
			variables.wheels.class.mapping[arguments.name].select = arguments.select;
			variables.wheels.class.mapping[arguments.name].dataType = arguments.dataType;
		}
		if (Len(arguments.label)) {
			variables.wheels.class.mapping[arguments.name].label = arguments.label;
		}
		if (StructKeyExists(arguments, "defaultValue")) {
			variables.wheels.class.mapping[arguments.name].defaultValue = arguments.defaultValue;
		}
		if (StructKeyExists(arguments, "automaticValidations")) {
			variables.wheels.class.mapping[arguments.name].automaticValidations = arguments.automaticValidations;
		}
	}

	/**
	 * Returns a list of property names ordered by their respective column's ordinal position in the database table.
	 * Also includes calculated property names that will be generated by the CFWheels ORM.
	 *
	 * [section: Model Class]
	 * [category: Miscellaneous Functions]
	 */
	public string function propertyNames() {
		local.rv = variables.wheels.class.propertyList;
		if (ListLen(variables.wheels.class.calculatedPropertyList)) {
			local.rv = ListAppend(local.rv, variables.wheels.class.calculatedPropertyList);
		}
		return local.rv;
	}

	/**
	 * Returns an array of columns names for the table associated with this class.
	 * Does not include calculated properties that will be generated by the CFWheels ORM.
	 *
	 * [section: Model Class]
	 * [category: Miscellaneous Functions]
	 */
	public array function columns() {
		return ListToArray(variables.wheels.class.columnList);
	}

	/**
	 * Returns the column name mapped for the named model property.
	 *
	 * [section: Model Class]
	 * [category: Miscellaneous Functions]
	 *
	 * @property Name of property to inspect.
	 */
	public any function columnForProperty(required string property) {
		if (StructKeyExists(variables.wheels.class.properties, arguments.property)) {
			return variables.wheels.class.properties[arguments.property].column;
		} else {
			return false;
		}
	}

	/**
	 * Returns a struct with data for the named property.
	 *
	 * [section: Model Class]
	 * [category: Miscellaneous Functions]
	 *
	 * @property Name of property to inspect.
	 */
	public any function columnDataForProperty(required string property) {
		if (StructKeyExists(variables.wheels.class.properties, arguments.property)) {
			return variables.wheels.class.properties[arguments.property];
		} else {
			return false;
		}
	}

	/**
	 * Returns the validation type for the property.
	 *
	 * [section: Model Class]
	 * [category: Miscellaneous Functions]
	 *
	 * @property Name of column to retrieve data for.
	 */
	public any function validationTypeForProperty(required string property) {
		if (StructKeyExists(variables.wheels.class.properties, arguments.property)) {
			return variables.wheels.class.properties[arguments.property].validationtype;
		} else {
			return "string";
		}
	}

	/**
	 * Returns the value of the primary key for the object.
	 * If you have a single primary key named id, then `someObject.key()` is functionally equivalent to `someObject.id`.
	 * This method is more useful when you do dynamic programming and don't know the name of the primary key or when you use composite keys (in which case it's convenient to use this method to get a list of both key values returned).
	 *
	 * [section: Model Object]
	 * [category: Miscellaneous Functions]
	 */
	public string function key(boolean $persisted = false, boolean $returnTickCountWhenNew = false) {
		local.rv = "";
		local.iEnd = ListLen(primaryKeys());
		for (local.i = 1; local.i <= local.iEnd; local.i++) {
			local.property = primaryKeys(local.i);
			if (StructKeyExists(this, local.property)) {
				if (arguments.$persisted && hasChanged(local.property)) {
					local.rv = ListAppend(local.rv, changedFrom(local.property));
				} else {
					local.rv = ListAppend(local.rv, this[local.property]);
				}
			}
		}
		if (!Len(local.rv) && arguments.$returnTickCountWhenNew) {
			local.rv = variables.wheels.tickCountId;
		}

		/* To fix the bug below:
			https://github.com/cfwheels/cfwheels/issues/1029

			This will return a numeric value if the primary key is Numeric and a String otherwise.
		*/
		if(isNumeric(local.rv)){
			return JavaCast("int", local.rv);
		} else {
			return local.rv;
		}
	}

	/**
	 * Returns `true` if the specified property name exists on the model.
	 *
	 * [section: Model Object]
	 * [category: Miscellaneous Functions]
	 *
	 * @property Name of property to inspect.
	 */
	public boolean function hasProperty(required string property) {
		if (StructKeyExists(this, arguments.property) && !IsCustomFunction(this[arguments.property])) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Returns `true` if the specified property exists on the model and is not a blank string.
	 *
	 * [section: Model Object]
	 * [category: Miscellaneous Functions]
	 *
	 * @property Name of property to inspect.
	 */
	public boolean function propertyIsPresent(required string property) {
		if (this.hasProperty(arguments.property) && IsSimpleValue(this[arguments.property]) && Len(this[arguments.property])) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Returns `true` if the specified property doesn't exist on the model or is an empty string.
	 * This method is the inverse of `propertyIsPresent()`.
	 *
	 * [section: Model Object]
	 * [category: Miscellaneous Functions]
	 *
	 * @property Name of property to inspect.
	 */
	public boolean function propertyIsBlank(required string property) {
		return !this.propertyIsPresent(arguments.property);
	}

	/**
	 * Assigns to the property specified the opposite of the property's current boolean value.
	 * Throws an error if the property cannot be converted to a boolean value.
	 * Returns this object if save called internally is `false`.
	 *
	 * [section: Model Object]
	 * [category: CRUD Functions]
	 *
	 * @save Argument to decide whether save the property after it has been toggled.
	 */
	public boolean function toggle(required string property, boolean save) {
		$args(name = "toggle", args = arguments);
		if (!StructKeyExists(this, arguments.property)) {
			Throw(
				type = "Wheels.PropertyDoesNotExist",
				message = "Property Does Not Exist",
				extendedInfo = "You may only toggle a property that exists on this model."
			);
		}
		if (!IsBoolean(this[arguments.property])) {
			Throw(
				type = "Wheels.PropertyIsIncorrectType",
				message = "Incorrect Arguments",
				extendedInfo = "You may only toggle a property that evaluates to the boolean value."
			);
		}
		this[arguments.property] = !this[arguments.property];
		local.rv = true;
		if (arguments.save) {
			local.rv = updateProperty(property = arguments.property, value = this[arguments.property]);
		}
		return local.rv;
	}

	/**
	 * Returns a structure of all the properties with their names as keys and the values of the property as values.
	 *
	 * [section: Model Object]
	 * [category: Miscellaneous Functions]
	 *
	 * @returnIncluded Whether to return nested properties or not.
	 */
	public struct function properties(boolean returnIncluded = true) {
		local.rv = {};
		// loop through all properties and functions in the this scope
		for (local.key in this) {
			// don't return nested properties if returnIncluded is false
			if (!arguments.returnIncluded && !IsSimpleValue(this[local.key])) {
				continue;
			}
			// don't return functions
			if (IsCustomFunction(this[local.key])) {
				continue;
			}
			if ($get("resetPropertiesStructKeyCase")) {
				// try to get the property name from the list set on the object, this is just to avoid returning everything in ugly upper case which Adobe ColdFusion does by default
				local.listPosition = ListFindNoCase(propertyNames(), local.key);
				if (local.listPosition) {
					local.key = ListGetAt(propertyNames(), local.listPosition);
				}
			}
			// set property from the this scope in the struct that we will return
			local.rv[local.key] = this[local.key];
		}
		return local.rv;
	}

	/**
	 * Allows you to set all the properties of an object at once by passing in a structure with keys matching the property names.
	 *
	 * [section: Model Object]
	 * [category: Miscellaneous Functions]
	 *
	 * @properties The properties you want to set on the object (can also be passed in as named arguments).
	 */
	public void function setProperties(struct properties = {}) {
		$setProperties(argumentCollection = arguments);
	}

	/**
	 * Returns `true` if the specified property (or any if none was passed in) has been changed but not yet saved to the database.
	 * Will also return `true` if the object is new and no record for it exists in the database.
	 *
	 * [section: Model Object]
	 * [category: Change Functions]
	 *
	 * @property Name of property to check for change.
	 */
	public boolean function hasChanged(string property = "") {
		// always return true if $persistedProperties does not exists
		if (!StructKeyExists(variables, "$persistedProperties")) {
			return true;
		}

		if (!Len(arguments.property)) {
			// they haven't specified a particular property so loop through them all
			arguments.property = StructKeyList(variables.wheels.class.properties);
		}
		arguments.property = ListToArray(arguments.property);
		local.iEnd = ArrayLen(arguments.property);
		for (local.i = 1; local.i <= local.iEnd; local.i++) {
			local.key = arguments.property[local.i];
			if (StructKeyExists(this, local.key)) {
				if (!StructKeyExists(variables.$persistedProperties, local.key)) {
					return true;
				} else {
					// convert each datatype to a string for easier comparison
					local.type = validationTypeForProperty(local.key);
					local.a = $convertToString(this[local.key], local.type);
					local.b = $convertToString(variables.$persistedProperties[local.key], local.type);
					if (Compare(local.a, local.b) != 0) {
						return true;
					}
				}
			}
		}
		// if we get here, it means that all of the properties that were checked had a value in
		// $persistedProperties and it matched or some of the properties did not exist in the this scope
		return false;
	}

	/**
	 * Returns a list of the object properties that have been changed but not yet saved to the database.
	 *
	 * [section: Model Object]
	 * [category: Change Functions]
	 */
	public string function changedProperties() {
		local.rv = "";
		for (local.key in variables.wheels.class.properties) {
			if (hasChanged(local.key)) {
				local.rv = ListAppend(local.rv, local.key);
			}
		}
		return local.rv;
	}

	/**
	 * Returns the previous value of a property that has changed.
	 * Returns an empty string if no previous value exists.
	 * CFWheels will keep a note of the previous property value until the object is saved to the database.
	 *
	 * [section: Model Object]
	 * [category: Change Functions]
	 *
	 * @property Name of property to get the previous value for.
	 */
	public string function changedFrom(required string property) {
		if (
			StructKeyExists(variables, "$persistedProperties")
			&& StructKeyExists(variables.$persistedProperties, arguments.property)
		) {
			return variables.$persistedProperties[arguments.property];
		} else {
			return "";
		}
	}

	/**
	 * Returns a struct detailing all changes that have been made on the object but not yet saved to the database.
	 *
	 * [section: Model Object]
	 * [category: Change Functions]
	 */
	public struct function allChanges() {
		local.rv = {};
		if (hasChanged()) {
			local.changedProperties = changedProperties();
			local.iEnd = ListLen(local.changedProperties);
			for (local.i = 1; local.i <= local.iEnd; local.i++) {
				local.item = ListGetAt(local.changedProperties, local.i);
				local.rv[local.item] = {};
				local.rv[local.item].changedFrom = changedFrom(local.item);
				if (StructKeyExists(this, local.item)) {
					local.rv[local.item].changedTo = this[local.item];
				} else {
					local.rv[local.item].changedTo = "";
				}
			}
		}
		return local.rv;
	}

	/**
	 * Clears all internal knowledge of the current state of the object.
	 *
	 * [section: Model Object]
	 * [category: Change Functions]
	 *
	 * @property string false Name of property to clear information for.
	 */
	public void function clearChangeInformation(string property) {
		$updatePersistedProperties(argumentCollection = arguments);
	}

	/**
	 * Internal function.
	 */
	public any function $setProperties(
		required struct properties,
		string filterList = "",
		boolean setOnModel = "true",
		boolean $useFilterLists = "true"
	) {
		local.rv = {};
		arguments.filterList = ListAppend(arguments.filterList, "properties,filterList,setOnModel,$useFilterLists");

		// add eventual named arguments to properties struct (named arguments will take precedence)
		for (local.key in arguments) {
			if (!ListFindNoCase(arguments.filterList, local.key)) {
				arguments.properties[local.key] = arguments[local.key];
			}
		}

		// loop through the properties and see if they can be set based off of the accessible properties lists
		for (local.key in arguments.properties) {
			// required to ignore null keys
			if (StructKeyExists(arguments.properties, local.key)) {
				local.accessible = true;
				if (
					arguments.$useFilterLists &&
					StructKeyExists(variables.wheels.class.accessibleProperties, "whiteList")
					&& !StructKeyExists(variables.wheels.class.accessibleProperties.whiteList, local.key)
				) {
					local.accessible = false;
				}
				if (
					arguments.$useFilterLists
					&& StructKeyExists(variables.wheels.class.accessibleProperties, "blackList")
					&& StructKeyExists(variables.wheels.class.accessibleProperties.blackList, local.key)
				) {
					local.accessible = false;
				}
				if (local.accessible) {
					local.rv[local.key] = arguments.properties[local.key];
				}
				if (local.accessible && arguments.setOnModel) {
					$setProperty(property = local.key, value = local.rv[local.key]);
				}
			}
		}

		if (arguments.setOnModel) {
			return;
		}
		return local.rv;
	}

	/**
	 * Internal function.
	 */
	public void function $setProperty(
		required string property,
		required any value,
		struct associations = variables.wheels.class.associations
	) {
		if (IsObject(arguments.value)) {
			this[arguments.property] = arguments.value;
		} else if (
			IsStruct(arguments.value)
			&& StructKeyExists(arguments.associations, arguments.property)
			&& arguments.associations[arguments.property].nested.allow
			&& ListFindNoCase("belongsTo,hasOne", arguments.associations[arguments.property].type)
		) {
			$setOneToOneAssociationProperty(
				property = arguments.property,
				value = arguments.value,
				association = arguments.associations[arguments.property]
			);
		} else if (
			IsStruct(arguments.value)
			&& StructKeyExists(arguments.associations, arguments.property)
			&& arguments.associations[arguments.property].nested.allow
			&& arguments.associations[arguments.property].type == "hasMany"
		) {
			$setCollectionAssociationProperty(
				property = arguments.property,
				value = arguments.value,
				association = arguments.associations[arguments.property]
			);
		} else if (
			IsArray(arguments.value)
			&& ArrayLen(arguments.value)
			&& !IsObject(arguments.value[1])
			&& StructKeyExists(arguments.associations, arguments.property)
			&& arguments.associations[arguments.property].nested.allow
			&& arguments.associations[arguments.property].type == "hasMany"
		) {
			$setCollectionAssociationProperty(
				property = arguments.property,
				value = arguments.value,
				association = arguments.associations[arguments.property]
			);
		} else {
			this[arguments.property] = arguments.value;
		}
	}

	/**
	 * Internal function.
	 */
	public void function $updatePersistedProperties(string property) {
		variables.$persistedProperties = {};
		for (local.key in variables.wheels.class.properties) {
			if (StructKeyExists(this, local.key) && (!StructKeyExists(arguments, "property") || arguments.property == local.key)) {
				variables.$persistedProperties[local.key] = this[local.key];
			}
		}
	}

	/**
	 * Internal function.
	 */
	public any function $setDefaultValues() {
		// persisted properties
		for (local.key in variables.wheels.class.properties) {
			if (
				StructKeyExists(variables.wheels.class.properties[local.key], "defaultValue")
				&& (!StructKeyExists(this, local.key) || !Len(this[local.key]))
			) {
				// set the default value unless it is blank or a value already exists for that property on the object
				this[local.key] = variables.wheels.class.properties[local.key].defaultValue;
			}
		}
		// non-persisted properties
		for (local.key in variables.wheels.class.mapping) {
			if (
				StructKeyExists(variables.wheels.class.mapping[local.key], "defaultValue")
				&& (!StructKeyExists(this, local.key) || !Len(this[local.key]))
			) {
				// set the default value unless it is blank or a value already exists for that property on the object
				this[local.key] = variables.wheels.class.mapping[local.key].defaultValue;
			}
		}
	}

	/**
	 * Internal function.
	 */
	public struct function $propertyInfo(required string property) {
		if (StructKeyExists(variables.wheels.class.properties, arguments.property)) {
			return variables.wheels.class.properties[arguments.property];
		} else {
			return {};
		}
	}

	/**
	 * Internal function.
	 */
	public string function $label(required string property) {
		// Prefer label set via `properties` initializer if it exists.
		if (
			StructKeyExists(variables.wheels.class.properties, arguments.property)
			&& StructKeyExists(variables.wheels.class.properties[arguments.property], "label")
		) {
			local.rv = variables.wheels.class.properties[arguments.property].label;
			// Check to see if the mapping has a label to base the name on.
		} else if (
			StructKeyExists(variables.wheels.class.mapping, arguments.property)
			&& StructKeyExists(variables.wheels.class.mapping[arguments.property], "label")
		) {
			local.rv = variables.wheels.class.mapping[arguments.property].label;
			// Fall back on property name otherwise.
		} else {
			local.rv = humanize(arguments.property);
		}

		return local.rv;
	}
}
