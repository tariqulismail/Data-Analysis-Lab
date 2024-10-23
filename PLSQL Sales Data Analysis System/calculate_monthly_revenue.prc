CREATE OR REPLACE PROCEDURE calculate_monthly_revenue AS
---calculate total revenue per month
  CURSOR sales_cursor IS 
    SELECT TO_CHAR(sale_date, 'YYYY-MM') AS sale_month, SUM(sale_amount) AS total_revenue
    FROM sales
    GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
    ORDER BY sale_month;
BEGIN
  FOR sale_rec IN sales_cursor LOOP
    DBMS_OUTPUT.PUT_LINE('Month: ' || sale_rec.sale_month || ', Revenue: ' || sale_rec.total_revenue);
  END LOOP;
END;
/
