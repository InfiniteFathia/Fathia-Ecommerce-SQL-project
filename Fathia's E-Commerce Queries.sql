USE ECOMMERCE;

/*
QUERIES THAT ANALYZE A SERIES OF E-CMOMERCE DATA
*/

   -- Q1. Write a query to calculate the total sales (in dollars) made by each employee, considering the quantity and unit price of products sold.
   
SELECT FIRSTNAME, LASTNAME, employees.EmployeeID, 
concat("$", ROUND(sum(QUANTITY * UNITPRICE * (1-discount)), 2))
 AS TOTAL_SALES_IN_DOLLARS FROM EMPLOYEES
JOIN ORDERS ON ORDERS.EmployeeID = EMPLOYEES.EmployeeID
JOIN ORDERDETAILS ON ORDERDETAILS.ORDERID = ORDERS.ORDERID
GROUP BY FIRSTNAME, LASTNAME, EmployeeID
order by total_sales_in_dollars desc;

   -- Q2. Identify the top 5 customers who have generated the most revenue. Show the customer’s name and the total amount they’ve spent.
  
  SELECT CUSTOMERNAME, ROUND (sum(quantity*unitprice * (1-discount)),2)
   as TOTAL_AMOUNT_SPENT FROM CUSTOMERS
   join orders on orders.customerid = customers.customerid
   join orderdetails on orderdetails.orderid = orders.orderid
   group by CUSTOMERNAME
   order by total_amount_spent desc 
   limit 5;
   
   -- Q3. Write a query to display the total sales amount for each month in the year 1997.
   
   select ROUND (sum(quantity*unitprice * (1-discount)),2) as Total_Sales_Amount,
   monthname(orderdate) as sale_month from orderdetails
   join orders on orders.orderid =  orderdetails.orderid
   where year(orderdate) = 1997
   group by sale_month
   order by sale_month ; 
   
   -- Q4. Calculate the average time (in days) taken to fulfil an order for each employee. Assuming shipping takes 3 or 5 days respectively
   -- depending on if the item was ordered in 1996 or 1997.
   
   
   select concat(firstname, "  ", lastname) as Full_Name_Of_Employees, 
   EMPLOYEES.employeeid,
   avg(
		case
			when year(orderdate) = 1996 then 3
			when year(orderdate) = 1997 then 5
        end)  as Average_Time_Taken_To_Fufill_An_Order
   from employees 
   join orders on orders.employeeid = employees.employeeid
   where year(orderdate) in (1996, 1997)
   group by employeeid, Full_Name_Of_Employees
   order by Average_Time_Taken_To_Fufill_An_Order
   ; 
   
   -- Q5. List the customers operating in London and total sales for each. 
   
   select city,customername,ROUND (sum(quantity*unitprice * (1-discount)),2)
   as total_sales from customers
   join orders on customers.customerid = orders.customerid
   join orderdetails on orders.orderid = orderdetails.orderid
   where city = "London" 
   group by customername, city
   order by total_sales desc;
   
   -- Q6.  Write a query to find customers who have placed more than one order on the same date.
   
   select customername, customers.customerid, orderdate, count(*)
   as Number_Of_Orders from customers
   join orders on orders.customerid = customers.customerid
   group by customerid, customername, orderdate
   having count(*) > 1
   order by customerid, orderdate;
   
   -- Q7. Calculate the average discount given per product across all orders. Round to 2 decimal places.
   
   select productname,round(avg(discount), 2) 
   as Average_Discount_Per_Product from orderdetails
   join products on products.productid = orderdetails.productid
   group by productname
   ;
   
   -- Q8. For each customer, list the products they have ordered along with the total quantity of each product ordered.
   
   select customername, customers.customerid,productname, 
   orderdetails.productid, sum(quantity) as total_quantity from customers
   join orders on customers.customerid = orders.customerid
   join orderdetails on orders.orderid = orderdetails.orderid
   join products on products.productid = orderdetails.productid
   group by customername,customerid,productname,productid
   order by customername,customerid,productname,productid;
   
   -- Q9. Rank employees based on their total sales. Show the employeename, total sales, and their rank.
   
   with Employee_Sales_Rank as (
   select concat(firstname, "  ", lastname) as Employees_Name, 
  round(sum(unitprice*quantity * (1-discount)), 2) as Total_Sales  from employees
    join orders on orders.employeeid = employees.employeeid
   join orderdetails on orderdetails.orderid = orders.orderid
  group by Employees_Name
  )
  select Employees_Name, Total_Sales,  row_number() over (order by Total_Sales desc) 
  as Sales_Rank from Employee_Sales_Rank;
   ;
   
   -- Q10. Write a query to display the total sales amount for each product category, grouped by country.
   
   SELECT categoryname, country,ROUND (SUM(quantity * unitprice * (1 -discount)), 2)
   AS total_sales FROM orderdetails 
JOIN orders ON orderdetails.orderid = orders.orderid
JOIN customers  ON orders.customerid = customers.customerid
JOIN products ON orderdetails.productid = products.productid
JOIN categories  ON products.categoryid = categories.categoryid
GROUP BY categoryname, country
ORDER BY categoryname, total_sales DESC;
   
   -- Q11. Calculate the percentage growth in sales from one year to the next for each product.
   
   
   /*
  I AM NOT SURE OF HOW TO WRITE A QUERY FOR THIS QUESTION YET
  I AM STUCK ON HOW TO CALCULATE YEARLY GROWTH FOR EACH PRODUCT
  */
   
   
   with 
   Yearly_Sales as (
   select productid, sum(unitprice*quantity * (1-discount)) as Total_Sales, 
   year(orderdate) as Sale_Year from orderdetails
   join orders on orders.orderid = orderdetails.orderid
	group by productid, Sale_Year 
    ),
    Growth_In_Sales as (
    select current.productid, products.productname, current.Sale_year,
    round (((current.Total_sales - previous.Total_Sales) / previous.Total_Sales) * 100, 2)
    as Percentage_Growth from current Yearly_Sales
   
   ;
   
   
   
   -- Q12. Calculate the percentile rank of each order based on the total quantity of products in the order. 
   
   with Quantities_Of_Orders as (
   select orderid, sum(quantity) as Total_Quantities from orderdetails
   group by orderid),
   Ranked_Orders as (
   select orderid, total_quantities,ROUND(percent_rank() over (order by Total_Quantities),2)
   as Percentile_Rank from Quantities_Of_Orders)
   select * from Ranked_Orders order by Percentile_Rank Asc;
   
   -- Q13. Identify products that have been sold but have never been reordered (ordered only once). 
   
   select orderdetails.productid, productname, 
   count(orderid) as orders from products 
   join orderdetails on orderdetails.productid = products.productid
   group by productname, productid
   having count(orderid) = 1
   ;
   
   -- Q14. Write a query to find the product that has generated the most revenue in each category.
   
   select productname, PRODUCTS.productid, categoryname, 
   ROUND (sum(quantity*unitprice * (1-discount)), 2) as total_revenue from products
   join categories on categories.categoryid = products.categoryid
    join orderdetails on products.productid = orderdetails.productid
    group by productname, categoryname, productid
    ;
    
   -- Q15. Identify orders where the total price of all items exceeds $100 and contains at least one product with a discount of 5% or more.
   
   select productname, products.productid, orders.orderid,
  round(sum(quantity*unitprice * (1-discount)), 2) as Total_Price, discount from orderdetails
   join orders on orders.orderid = orderdetails.orderid  
   join products on products.productid = orderdetails.productid
   group by orderid, discount, productname, productid
   having sum(quantity*unitprice * (1-discount)) > 100 and max(discount) >= 0.05 
    order by Total_Price desc;
   
