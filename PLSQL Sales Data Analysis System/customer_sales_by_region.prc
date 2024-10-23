CREATE OR REPLACE PROCEDURE customer_sales_by_region AS
  CURSOR region_sales_cursor IS
    SELECT r.region_name, SUM(s.sale_amount) AS total_sales
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN regions r ON c.region = r.region_id
    GROUP BY r.region_name;
BEGIN
  FOR region_rec IN region_sales_cursor LOOP
    DBMS_OUTPUT.PUT_LINE('Region: ' || region_rec.region_name || ', Sales: ' || region_rec.total_sales);
  END LOOP;
END;
/
