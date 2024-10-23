CREATE OR REPLACE FUNCTION get_best_selling_products RETURN SYS_REFCURSOR IS
  top_products SYS_REFCURSOR;
BEGIN
  OPEN top_products FOR
    SELECT product_name, SUM(quantity) AS total_quantity
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    GROUP BY product_name
    ORDER BY total_quantity DESC;
  RETURN top_products;
END;
/
