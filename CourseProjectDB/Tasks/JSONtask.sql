--select * from products
--delete from products where product_name like 'Product%';
commit;

begin
    ExportToJSON();
end;


create public synonym ExportToJSON for SYSTEM.ExportToJSON;

-- экспорт
create or replace procedure ExportToJSON
as
json_data CLOB;
   file_handle utl_file.file_type;
   cursor c_products is
      SELECT json_object('product_id'   VALUE p.product_id,
                         'product_name' VALUE p.product_name,
                         'category_id'  VALUE p.category_id,
                         'price'        VALUE p.price,
                         'description'  VALUE p.description,
                         'image_url'    VALUE p.image_url,
                         'quantity'     VALUE p.quantity) as json_row
      FROM products p;
BEGIN
   dbms_lob.createtemporary(json_data, TRUE);

   file_handle := utl_file.fopen('ORACLE_BASE', 'output.json', 'w', 32767);

   for product_row in c_products loop
      json_data := json_data || product_row.json_row || ',';
   end loop;
   
   json_data := rtrim(json_data, ',');

   utl_file.put_raw(file_handle, utl_raw.cast_to_raw(json_data));

   utl_file.fclose(file_handle);

   dbms_lob.freetemporary(json_data);

   dbms_output.put_line('Exporting data to JSON file completed.');
EXCEPTION
   WHEN OTHERS THEN
      IF utl_file.is_open(file_handle) THEN
         utl_file.fclose(file_handle);
      END IF;
      dbms_lob.freetemporary(json_data);
      RAISE;
END;

--------------------------------------------------------------------------------------------------------------------------------

-- импорт
-- js