/***************************************************** 
Introduction to SQL for Querying Databases 
Spring 2022 Workshop: 4/11/2022
Created By/Instructor: Nicholas Alonzo (nicholas@diversifyds.org)
*****************************************************/

/************** The SQL Query Blueprint **************
SELECT [DISTINCT] ...
FROM ...
[WHERE ...]
  [ [INNER | LEFT] JOIN ...]
[GROUP BY ... [HAVING ...]]
[ORDER BY ...] 
[LIMIT ...];

NOTE: 
  - Keywords in brackets "[ ]" is optional
  - Write queries in the order of the blueprint
  - End queries with a semicolon ";"
*****************************************************/


/************* Viewing Data *************/

-- SELECT & FROM




-- Selecting Columns




-- Column Referencing




-- Aliasing Columns & Tables 




-- Unique Values




-- Ordering Results




-- Limiting Number of Rows




/************* Filtering Data *************/

-- WHERE Clause




-- AND & OR Operators




-- IN Operator




-- BETWEEN Operator




-- LIKE Operator




-- IS NULL Operator




-- NOT Operator




/************* Agregating Data *************/

-- COUNT() Function




-- AGV() Function




-- SUM() Function




-- GROUP BY




-- HAVING




/************* Joining Data *************/

-- INNER JOIN 




-- LEFT JOIN 




/************* Subqueries *************/





/*********************************************************
Challenge Queries:
Keep in mind, there's no one "right" answer! If you'd like to go over these in
more depth, visit DataLab's office hours: https://datalab.ucdavis.edu/office-hours/

1. Suppose the library is offering a prize to the person who read the most pages. 
Help the library find the person so they can claim their prize.

2. Suppose the library received complaints from people that not all books can be searched up by their information.
Help the library identify the books that need clean up.

3. Suppose the library wants to expand their book collection based off what people check out.
Help the library decide what types of books to purchase.

4. Suppose the library has a policy that charges 10 cents each day a book is returned after the due date
and an additional 75 cents if a book is returned with damage.
Help the library find the people who will be charged. 

  There are different ways to get to the same result. Below are a list of helpful 
  SQL commands not covered in the workshop
    CASE: https://www.w3schools.com/sql/sql_case.asp
    COALESCE(): https://www.w3schools.com/SQL/func_sqlserver_coalesce.asp
    UNION: https://www.w3schools.com/SQL/sql_union.asp

*********************************************************/




