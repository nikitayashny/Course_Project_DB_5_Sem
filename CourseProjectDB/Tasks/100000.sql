declare
  v_category_id number;
begin
  for i in 19..100019 loop
    insert into products 
    values (i, 'Product' || i, 1, 130, 'Description ' || i, 'Image URL ' || i, 1);
    if mod(i, 1000) = 0 then
      commit; 
    end if;
  end loop;
  commit;
end;

select * from products;
create index idx_product_name on products(product_name);