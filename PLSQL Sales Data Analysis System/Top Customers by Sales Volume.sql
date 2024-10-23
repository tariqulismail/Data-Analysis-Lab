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
