# Intro to SQL for Querying Databases

**This workshop is under development. It should be complete before Nov. 6, 2019.**  The goal is to write a workshop that teaches the basics of (non-spatial) SQL using DB Browsesr and SQLite.

This workshop provides an overview of the utility and base SQL commands for working with data in a relational database. We’ll focus on querying data to get to know a database and answer questions, and combining data from separate tables. 

## Goals
After this workshop learners should be able to:
 * Perform common SQL commands including sorting, filtering, calculating values, aggregating, combining data, and basic data cleaning (i.e. replace missing values).
 * Combine commands to construct a query to answer a specific question.
 * Identify the benefits of working with SQL.
 * Access additional resources for using SQL in other software like R.

## Prerequisites
No prior programming experience is necessary. Bring your laptop with DB Browser installed (https://sqlitebrowser.org/) and running.


# Concepts

## What is a Relational Database?

A database is a set of data in tables that are related to each other in some way. That's it. It's just a collection of tables.

Ideally each table can be connected to another table by a column that both tables have that store the information to match up the rows. This column is called a **key**. A key commonly used on campus is your student or employee ID number.

Let's look at an example dataset of student data with data about courses, grades, and employment.  Can we say anything about the relationship between course grades and employment based on this data?

**Table: Student**

|ID|Name|
|--|--|
|123|Jane Smith|
|456|Maria Martinez|
|789|Paul Jones|

**Table: Courses**

|ID|Course|Grade|
|--|--|--|
|123|Calculus|A-|
|456|Calculus|A|
|789|Calculus|C+|
|123|Data Science|A-|
|456|Data Science|B|
|789|Data Science|B-|

**Table: Employment**

|ID|Position|Employer|HoursPerWeek|
|--|--|--|--|
|123|Student Assistant|University Research Lab|5|
|456|Customer Service|Alumni Center|5|
|456|Research Assistant|University Research Lab|15|
|789|Student Assistant|University Research Lab|10|
|789|Stock Room|Medical Supplier|20|
|789|Customer Service|Alumi Center|15|

## What is SQL?
SQL stands for "structured query language" and it's a language that allows you to ask questions of a database. 

In the above example, it would be much easier to understand the relationships if we build a table aggregating and reshaping our data.  SQL allows us to do that.

### You're Already Doing This!

Researchers typically are already thinking about querying data.  

Imagine you have a table about air quality data.  It contains columns with measurements about various environmental properties such as the temperature, the level of ozone, and perhaps measurements of various particulates.

If you've ever subsetted data in R, for example, you've already done something similar to writing an SQL query! The R code `subset(airquality, Temp > 80, select = c(Ozone, Temp))` becomes `SELECT Ozone, Temp FROM airquality WHERE Temp > 80` in SQL.

In Excel, you might sort your whole spreadsheet on the Temp column, then copy all of the rows that are greater than 80, and paste them into another tab.  You might remove all the other columns except for the Ozone and Temp columns.  You might have also used the cell highlighting tools to change the color of the cells based on the Temp column just to see which cells meet your criteria.

### Why do you want to learn to work with databases and SQL?
 * Efficient
    + Write a few lines of code rather than lots of manual data manipulation
    + SQL is meant for data manipulation
 * Reproducibility 
    + save queries as a record of your workflow
    + re-run code with updates
 * Work with large amounts of data
    + Typically faster to run a process in a database than in a spreadsheet
    + Store lots of data (compare with Excel's row limits)
 * Data management
    + One database file stores many, many tables
    + Write a query instead of making a new files or tabs

### What makes this challenging?
If you currently work in a graphical user interface (GUI), you might be used to being able to see your data, have tools with guided interfaces, and seeing the results of your processing immediately. These aren't things you get with a typical database manager tool, however, you will get used to the typical workflow and seeing everything won't be so necessary.




# Getting Setup

## Install the Software

We'll be using [DB Browser](https://sqlitebrowser.org/), a free, open source, graphical interface for working with SQL databases that works on all major computing operating systems. Installers are available on their [Downloads Page](https://sqlitebrowser.org/dl/).  If you do not have install permissions on your computer, the Portable App version may work without administrator permissions.

## Download the Workshop Data

1. The data is available on [Michele's Workshop Data Box Drive](https://ucdavis.box.com/s/j2paxajpmtsg1ule8zgndy5vckpboex5).  

1. Dismiss the banner that might pop-up at the top of the webpage directing you to log-in (you don't need to log-in or have an account).  

1. Click the *Download* button in the upper right corner to download all the data in one zip.  

1.  Save the data where you can find it easily, then unzip the folder.  You should have 8 files - 7 .csv files and 1 .txt

## Understanding the Data

For this workshop, we'll be working with some data from IMDB (Internet Movie Database). You can get updated data on the [IMDB Datasets Page](https://www.imdb.com/interfaces/#plain). The diagram below outlines the relationships between the data in the tables that make up the database.  Notice how information about the movie and TV show titles is all connected by the ```tconst``` column.  This is a **key**, a unique identifier for each title.  The cast and behind-the-scenes people also have a key - it's called ```nconst```.


![alt text](images/DataDiagram.png)


I've already pre-processed the data so that it's easier to import into your SQL database and small enough to work reasonably well in a workshop, so if you get new data, you'll have to unzip the downloaded data, and save it as a csv file before proceeding.  The full IMDB database is rather large and growing daily, so feel free to explore it, but know that some of the tables are over 2GB in their original state.

The data we'll be working with is an extract from the IMDB (dataset from Oct. 18, 2019.  Specifically, we'll be looking at the top 200 grossing movie titles and related data.  Here is a diagram of the data we'll be working with:

![alt text](images/DataDiagram_200TopGross.jpg)

Notice how all the tables can be connected with the ```tconst``` column.



# Hands On

## Start DB Browser

Start the **DB Browser for SQLite** program in the way you usually start new programs on your computer.  For example, on Windows 10, I typically search for the program name in the search box.

## Create a New Database

First, let's create a new database to store our data.  Remember that a database is like a container that holds related tables.

1. Click on the *New Database* button ![alt text](images/Button_NewDatabase.PNG)

1. Navigate to where you'd like to save your database.  I'd suggest putting it in the folder where you're keeping your workshop data.

1. In the *File name* box, call your database "imdb", and then click *Save*.  You can dismiss the window that pops up to *Edit table definition*.  We'll load data in a different way.

Now we have an empty database called *imdb.db*.


## Import the Data into a Database


Let's load the first data table:

1. From the *File* menu, select *Import*, and then *Table from CSV...*.

1. Navigate to where you saved your workshop data and select *name_basics.csv* and click the *Open* button.  A new dialog window should pop up now.

1. In the *Table name* field, you can change your table name. This is handy because if your data file is named something complicated, you can name it something easier to type here.

1. Check the box next to *Column names in first line* because our data has headers.

1. Notice that the preview of the table does not look right.  The column names are not what we would expect for a table of information about actors.  Change the *Field separator* drop-down menu to *Tab*.  Notice the change in the preview.  That looks better!

1. Change the *Quote character* to the blank space on the drop-down menu. The quotes that appear in the data do not indicate that something is text, but rather are used in a more literary sense.  If we don't change this, our data import will fail (your instructor learned this from personal experience).

1. We can leave the *Encoding* as UTF-8.  If you get odd characters in your preivew, check to see what your character encoding should be.  *Trim fields* removes extra spaces.

1. Click the *OK* button when everything looks as you would expect.

Repeat the process with the *title_basics.csv* and *title_principles.csv* files.  The rest of the tables in the data folder are not needed for this workshop, but you can import them to try queries with them on your own.

## Viewing Data

Select * from Table

Selecting Columns

Limiting Results... limit 10

Unique Values

Calculating Values

Aliasing... as

Filtering Results... where

Sorting... order by

## Aggretating Data

Count

AVG

SUM

Group By

Having

## Saving Queries

Create View

Create Table

## Joins

Basic Joins

Join/On vs. Where

Join types... left, right, inner, etc.... which are allowed with this tool?

## Data Management

Update Table Where...

Add column

Update column

Drop tables



# Resources

[Sofware Carpentry's SQL Novice Workshop](http://swcarpentry.github.io/sql-novice-survey/)

[Clark Fitzgeralds & Nick Ulle's SQL Workshop](https://github.com/clarkfitzg/SQLworkshop)

[Michele Tobias' Spatial SQL Workshop](https://github.com/MicheleTobias/Spatial_SQL)

[W3Schools SQL Materials](https://www.w3schools.com/sql/default.asp) - This is an excellent reference for SQL syntax with a fun "try it yourself" feature.
