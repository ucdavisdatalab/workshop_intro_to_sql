# This script makes a SQLite database from the library checkouts dataset.
library("dplyr")
library("lubridate")
library("purrr")
library("readr")
library("stringr")
library("RSQLite")


#' Entry point to run the script.
#'
main = function() {
  dataset = read_library_dataset()
  do.call(make_library_database, dataset)
}


#' Read and clean the library dataset.
#'
read_library_dataset = function(
  path = "data/2024-03-14_loan-data_v2.csv"
) {
  loans = read_csv(path)

  # Fix column names.
  names(loans) = str_normalize(names(loans))
  loans = rename(loans,
    receiving_date = receiving_date_calendar,
    publication_years = publication_date)

  # Fix data types.
  # SQLite doesn't have a date type, so just use ISO format date strings.
  date_cols = c("loan_date", "due_date", "receiving_date")
  loans[date_cols] = map(
    loans[date_cols], \(col) format(mdy(col), "%Y-%m-%d"))

  # The `publication_years` column is usually a year, often with some garbage
  # characters.
  loans$first_publication_year =
    str_extract_all(loans$publication_years, "[0-9]{4}") |>
    map(get_earliest_year) |>
    unlist()

  items_cols = c("item_id", "barcode", "receiving_date",
    "title", "author", "description", "subjects",
    "material_type", "resource_type", "language_code",
    "publisher", "publication_years", "first_publication_year",
    "publication_place",
    "loans_in_house", "loans_not_in_house", "recalls", "lifecycle")
  items = distinct(loans[items_cols])

  z = count(items, item_id) |> filter(n > 1) |> arrange(desc(n))
  zz = left_join(z["item_id"], items, by = "item_id")

  users_cols = c("patron_id", "user_group", "creation_date")
  users = distinct(loans[users_cols])
  users = filter(users, patron_id != -1)

  checkouts_cols = c("item_id", "patron_id", "loan_date", "due_date",
    "location_code", "location_name", "library_code")
  checkouts = distinct(loans[checkouts_cols])

  #setdiff(names(loans), c(names(items), names(users), names(checkouts)))
  list(items = items, users = users, checkouts = checkouts)
}


#' Make a SQLite database from the library dataset.
#'
make_library_database = function(
  items, users, checkouts,
  path = "data/library.sqlite"
) {
  # Store in SQLite database.
  con = dbConnect(SQLite(), path)
  #create_table(con, "items", items, primary_key = "item_id")
  create_table(con, "items", items)
  create_table(con, "patrons", users, primary_key = "patron_id")
  create_table(con, "checkouts", checkouts)
  dbDisconnect(con)
}


#' Normalize column names by converting to lowercase, removing parentheses, and
#' replacing whitespace and punctuation with underscores.
#'
str_normalize = function(string) {
  string = str_to_lower(string)
  string = str_replace_all(string, "[()]", "")
  string = str_replace_all(string, "[ .,]+", "_")
  string
}


#' Get the chronologically first year in a vector of years.
#'
get_earliest_year = function(years) {
  if (length(years) == 0) return (NA)

  min(as.numeric(years))
}


#' Create a table with a primary key in a database.
#'
#' The `dbWriteTable` function can create tables, but it doesn't support
#' setting a primary key. This function solves that problem.
#'
create_table = function(con, name, value, primary_key = NULL) {
  if (!is.null(primary_key)) {
    col_names = paste(names(value), collapse = ", ")
    query <- sprintf(
      "CREATE TABLE %s(%s, PRIMARY KEY(%s))", name, col_names, primary_key)
    dbExecute(con, query)
  }

  dbWriteTable(con, name, value, append = TRUE)
}


# Exploratory/prototyping code
if (FALSE) {
  # CSV is broken at line 2686
  #is_change = which(loans$material_type != c(loans$material_type[-1], "hi"))
  #as.data.frame(loans[is_change[1], ])

  names(loans)
  # 152,714 items
  length(unique(loans$item_id))


  repeated_ids = filter(count(items, item_id), n > 1)$item_id
  z = arrange(mutate(filter(items, item_id %in% !!repeated_ids), item_id =
    as.character(item_id)), item_id)
  all.equal(z[1, ], z[2, ])

  zz = group_map(group_by(z, item_id), ~ names(.x)[(map_int(.x, function(a) {
    length(unique(a))
  }) > 1)])
  unique(unlist(zz))

  odd_items = filter(
    summarize(group_by(z, item_id), odd = length(unique(title)) > 1)
    , odd)$item_id

  filter(z, item_id %in% !!odd_items)[c("item_id", "title")]
}


# user_group (users)
# creation_date (users) -- user acount creation date
# barcode (items)
# loan_date (checkouts)
# due_date (checkouts)
# item_id (checkouts, items)
# location_code (items) -- which collection the item belonged to at checkout
# title (items)
# author (items)
# subjects (items)
# material_type (items)
# publisher (items)
# receiving_date (items) -- date item was added to collection
# publication_years (items)
# resource_type (items)
# language_code (items)
# publication_place (items)
# patron_id (checkouts, users)
# description (items)
# lifecycle (items) -- status of item in collection
# loans_not_in_house (items) -- ILL of item to others?
# recalls (items)
# loans_in_house (items) -- loans of item?
