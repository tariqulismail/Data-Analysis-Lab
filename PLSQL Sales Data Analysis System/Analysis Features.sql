PROCEDURE calculate_monthly_revenue 
FUNCTION get_best_selling_products
PROCEDURE customer_sales_by_region
FUNCTION calculate_sales_growth
    


DECLARE
  CURSOR customer_cursor IS
    SELECT c.customer_name, SUM(s.sale_amount) AS total_sales
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    GROUP BY c.customer_name
    ORDER BY total_sales DESC
    FETCH FIRST 5 ROWS ONLY;
BEGIN
  FOR customer_rec IN customer_cursor LOOP
    DBMS_OUTPUT.PUT_LINE('Customer: ' || customer_rec.customer_name || ', Total Sales: ' || customer_rec.total_sales);
  END LOOP;
END;
/

PROCEDURE product_sales_by_region
  

SET SERVEROUTPUT ON;
BEGIN
  sales_density_by_region;
END;
/

BEGIN
  sales_density_by_category;
END;
/

BEGIN
  sales_density_by_region_category;
END;
/



