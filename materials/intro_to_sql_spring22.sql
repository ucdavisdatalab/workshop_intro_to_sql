/***************************************************** 
Introduction to SQL for Querying Databases 
Spring 2022 Workshop: 4/11/2022
Created By/Instructor: Nicholas Alonzo (nicholas@diversifyds.org)
*****************************************************/

/************** The SQL Query Blueprint **************
Write commands in the order of the blueprint:
SELECT [DISTINCT] ...
FROM ...
[WHERE ...]
  [ [INNER | LEFT] JOIN ...]
[GROUP BY ... [HAVING ...]]
[ORDER BY ...] 
[LIMIT ...];
*****************************************************/


/************* Viewing Data *************/

-- SELECT & FROM




-- Selecting Columns




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




-- Renaming/Aliasing Columns




-- AGV() Function




-- SUM() Function




-- GROUP BY




-- HAVING




/************* Joining Data *************
Below are the steps for writing a JOIN:
1. We start in just the same way: SELECT the columns we want in the output (using column references)
NOTE: Column referencing helps you distinguish from what table the columns come from.
      Use the table name followed by a period to reference the column: table_name.column_name
2. Then we have the FROM statement to tell it which table to start with (this is our “left” table)
3. Then we need our JOIN statement to say which table should get joined (this is our “right” table)
4. Finally, we have to say which columns the join should be based on with ON
****************************************/

-- INNER JOIN 




-- LEFT JOIN 




/************* Subqueries *************/






/************* Challenge Queries *************
Keep in mind, there's no one "right" answer! If you'd like to go over these in more depth, 
visit DataLab's office hours: https://datalab.ucdavis.edu/office-hours/
*********************************************/

/* 1. Suppose the library is offering a prize to the person who read the most pages. 
Help the library find the person so they can claim their prize. */



/* 2. Suppose the library received complaints from people that not all books can be searched up by their information.
Help the library identify the books that need clean up. */



/* 3. Suppose the library wants to expand their book collection based off what people check out.
Help the library decide what types of books to purchase. */



