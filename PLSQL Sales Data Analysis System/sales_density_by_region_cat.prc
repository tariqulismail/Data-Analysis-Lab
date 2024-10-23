CREATE OR REPLACE PROCEDURE sales_density_by_region_cat AS
BEGIN
  FOR sales_rec IN (
    SELECT r.region_name, p.category, TO_CHAR(s.sale_date, 'YYYY-MM') AS sale_month, SUM(s.sale_amount) AS total_sales
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN regions r ON c.region = r.region_id
    JOIN products p ON s.product_id = p.product_id
    GROUP BY r.region_name, p.category, TO_CHAR(s.sale_date, 'YYYY-MM')
    ORDER BY sale_month, r.region_name, p.category
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Month: ' || sales_rec.sale_month || ', Region: ' || sales_rec.region_name || ', Category: ' || sales_rec.category || ', Total Sales: ' || sales_rec.total_sales);
  END LOOP;
END;
/
