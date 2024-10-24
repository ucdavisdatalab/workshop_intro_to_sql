# This script makes a SQLite database from the library checkouts dataset.
library("dplyr")
library("lubridate")
library("purrr")
library("readr")
library("stringr")
library("RSQLite")

set.seed(409)


#' Entry point to run the script.
#'
main = function() {
  dataset = read_library_dataset()
  dataset = do.call(subset_library_dataset, dataset)
  do.call(make_library_database, dataset)
}


#' Read and clean the library dataset.
#'
read_library_dataset = function(
  path = "data/2024-03-14_loan-data_v2.csv"
) {
  message("Reading '", path, "'")
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


#' Subset the library data set to get the file size down to about 35 MB.
#'
#' This function mostly operates on the `items` table. It removes the
#' `subjects` column and removes all items that aren't checked out except for a
#' sample of about 15,000.
#'
subset_library_dataset = function(items, users, checkouts, n = 15000) {
  # Active checkouts have a non-negative `patron_id`.
  active = filter(checkouts, patron_id != -1)

  # Get `item_id`s for active items as well as a sample of inactive items.
  keep = unique(active$item_id)
  inactive_items = setdiff(items$item_id, keep)
  keep = c(keep, sample(inactive_items, n, replace = FALSE))

  items = filter(items, item_id %in% keep)
  items = select(items, -subjects)

  # Filter out law school users and checkouts.
  is_law = str_starts(users$user_group, "Law ")
  users = users[!is_law, ]
  patron_ids = unique(users$patron_id)
  checkouts = filter(checkouts, patron_id %in% c(patron_ids, -1))

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
  message("Wrote '", path, "'")
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


  # ---
  active = filter(checkouts, patron_id != -1)
  active_items = filter(items, item_id %in% active$item_id)

  dup_item = filter(count(items, item_id), n > 1)$item_id

  by_year = split(checkouts, year(checkouts$loan_date))
  sapply(by_year, \(y) format(object.size(
        filter(items, item_id %in% y$item_id)), units = "Mb"))

  ix = sample(seq_len(nrow(items)), 15000)
  (10 / as.numeric(object.size(items) / nrow(items))) * nrow(items)
  format(object.size(items[ix, ]), units = "Mb")
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


# Size statistics:
# 157,964 items (103.4 MB)
#   * 4,123 of these have multiple entries
#       * 1,539 of these are checked out
#   * 152,714 unique items
#   * Items by year:
#     >      2019      2020      2021      2022      2023
#     > "43.9 Mb" "16.8 Mb" "16.5 Mb" "27.8 Mb"   "30 Mb"
#   * Items column sizes above 2 MB:
#     >     title                 author           subjects
#     > "17.5 Mb"               "8.5 Mb"          "54.4 Mb"
#     > publisher      publication_place
#     >    "4 Mb"               "2.4 Mb"
#   * Active items alone require 22 MB (or 10.5 MB without subjects).
# 2,595 unique users (0.1 MB), all with checkouts
# 240,424 checkouts (13.1 MB) spanning 2019-01-02 to 2023-12-28
#   * 152,714 unique items
#   * 31,464 active checkouts (i.e., associated with a user)
#       * 29,283 unique items
