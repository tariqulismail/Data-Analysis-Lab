CREATE OR REPLACE FUNCTION calculate_sales_growth(yearin varchar2) RETURN SYS_REFCURSOR IS
  sales_growth SYS_REFCURSOR;
BEGIN
  OPEN sales_growth FOR
    SELECT category, 
           (SUM(CASE WHEN TO_CHAR(sale_date, 'Q') = '4' THEN sale_amount ELSE 0 END) -
            SUM(CASE WHEN TO_CHAR(sale_date, 'Q') = '3' THEN sale_amount ELSE 0 END)) / 
            SUM(CASE WHEN TO_CHAR(sale_date, 'Q') = '3' THEN sale_amount ELSE 1 END) * 100 
            AS growth_percentage
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    WHERE TO_CHAR(sale_date, 'YYYY') = yearin 
    GROUP BY category;
  RETURN sales_growth;
END;
/
