CREATE OR REPLACE PROCEDURE sales_density_by_category AS
BEGIN
  FOR sales_rec IN (
    SELECT p.category, TO_CHAR(s.sale_date, 'YYYY-Q') AS sale_quarter, SUM(s.sale_amount) AS total_sales
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    GROUP BY p.category, TO_CHAR(s.sale_date, 'YYYY-Q')
    ORDER BY sale_quarter, p.category
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Quarter: ' || sales_rec.sale_quarter || ', Category: ' || sales_rec.category || ', Total Sales: ' || sales_rec.total_sales);
  END LOOP;
END;
/
