# Configure Python Environment -------------------------------------------

config_oracle_env <- function(envname = "oracledb") {
	# Set current directory as place to put venv files
	Sys.setenv(RETICULATE_VIRTUALENV_ROOT = here::here())

	# Check if environment exists
	if (reticulate::virtualenv_exists(envname = envname)) {
		reticulate::use_virtualenv(virtualenv = envname)
	} else if (!reticulate::virtualenv_exists(envname = envname)) {
		reticulate::virtualenv_create(
			envname = envname,
			packages = c("oracledb", "pandas")
		)
	}
}

config_oracle_env()

# Workhorse function ---------------------------------------------

fetch_data <- function(schema = "WORKSPACE") {
	# Connect to the DB
	oracle <- reticulate::import("oracledb")
	pandas <- reticulate::import("pandas")

	# Establish connection to the Oracle database
	connection <- oracle$connect(
		dsn = oracle$makedsn(
			host = Sys.getenv("DB_HOST"),
			port = Sys.getenv("DB_PORT"),
			sid = Sys.getenv("DB_SID")
		),
		user = Sys.getenv("DB_USERNAME"),
		password = Sys.getenv("DB_PASSWORD")
	)

	cursor <- connection$cursor()

	# Fetch Available Tables
	available_tables <- unlist(cursor$execute(
		"SELECT table_name FROM user_tables"
	)$fetchall())

	schema_id <- menu(
		available_tables,
		graphics = TRUE,
		title = "Select Database"
	)
	schema_table <- available_tables[schema_id]

	# Fetch data from specified table
	table_query <- cursor$execute(glue::glue(
		"SELECT * FROM {schema}.{schema_table}"
	))

	# Column names
	column_names <- purrr::map_vec(.x = table_query$description, .f = ~ .x[[0]])

	final_df <- pandas$DataFrame(
		data = table_query$fetchall(),
		columns = column_names
	)

	cursor$close()
	connection$close()

	return(final_df)
}

x <- fetch_data()
