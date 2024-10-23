CREATE OR REPLACE PROCEDURE product_sales_by_region IS
  CURSOR sales_cursor IS
    SELECT p.product_name, r.region_name, SUM(s.sale_amount) AS total_sales
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN regions r ON c.region = r.region_id
    GROUP BY p.product_name, r.region_name;
BEGIN
  FOR sales_rec IN sales_cursor LOOP
    DBMS_OUTPUT.PUT_LINE('Product: ' || sales_rec.product_name || ', Region: ' || sales_rec.region_name || ', Sales: ' || sales_rec.total_sales);
  END LOOP;
END;
/
