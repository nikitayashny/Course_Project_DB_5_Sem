-- add_product('name', 'category', price, 'desc', 'url', quantity);
-- delete_product('name');
-- update_product('name', price, 'desc', 'url', quantity);
-- add_quantity_product('name', quantity);
-- remove_quantity_product('name', quantity);
begin
    add_product('Джинсы', '1', 30, 'desc', 'url', 10);
end;
begin
    remove_quantity_product('Джинсы', 300);
end;
create public synonym add_product for SYSTEM.add_product;
create public synonym delete_product for SYSTEM.delete_product;
create public synonym update_product for SYSTEM.update_product;
create public synonym add_quantity_product for SYSTEM.add_quantity_product;
create public synonym remove_quantity_product for SYSTEM.remove_quantity_product;

-------------------------------------------------------- ТОВАРЫ ----------------------------------------------------------------

-- процедура добавления нового товара
create or replace procedure add_product (
    p_product_name in varchar,
    p_category_id  in number,
    p_price        in number,
    p_description  in varchar,
    p_image_url    in varchar,
    p_quantity     in number
) as
    p_product_id number;
    p_count number;
begin
    select count(*) into p_count from products where product_name = p_product_name;
    
    if(p_count > 0) then
        dbms_output.put_line('имя занято');
        rollback;
        return;
    end if;

    select max(product_id)
    into p_product_id
    from products;
    
    insert into products 
    values (p_product_id + 1, p_product_name, p_category_id, p_price, p_description, p_image_url, p_quantity);
    commit; 
exception
    when no_data_found then 
        insert into products 
        values (1, p_product_name, p_category_id, p_price, p_description, p_image_url, p_quantity);
        commit; 
    when others then
        dbms_output.put_line('Неверные данные'); 
        rollback;
        raise;
end;

-- процедура удаления позиции товара
create or replace procedure delete_product (
    p_product_name in varchar2
) as
begin
    delete from products
    where product_name = p_product_name;
    commit;
exception
    when others then 
        dbms_output.put_line('Товар ' || p_product_name || ' не найден.'); 
        rollback;
        raise;
end;

-- процедура изменения товара
create or replace procedure update_product (
    p_product_name   in varchar,
    p_price          in number,
    p_description    in varchar,
    p_image_url      in varchar,
    p_quantity       in number
) as
begin
    update products
    set price = p_price,
        description = p_description,
        image_url = p_image_url,
        quantity = p_quantity
    where product_name = p_product_name;
    commit; 
exception
    when others then 
        dbms_output.put_line('Продукт ' || p_product_name || ' не найден.');
        rollback;
        raise;
end;

-- процедура привоза товара
create or replace procedure add_quantity_product (
    p_product_name   in varchar,
    p_quantity       in number
) as
begin
    update products
    set quantity = quantity + p_quantity
    where product_name = p_product_name;
    commit; 
exception
    when others then 
        dbms_output.put_line('Продукт ' || p_product_name || ' не найден.');
        rollback;
        raise;
end;

-- процедура уменьшения товара
create or replace procedure remove_quantity_product (
    p_product_name   in varchar,
    p_quantity       in number
) as
    current_quantity number;
begin
    select quantity 
    into current_quantity
    from products
    where product_name = p_product_name;
    
    if (p_quantity > current_quantity) then
        dbms_output.put_line('Количество не может превышать имеющееся');
        return;
    end if;  
    
    update products
    set quantity = quantity - p_quantity
    where product_name = p_product_name;
    commit; 
exception
    when others then 
        dbms_output.put_line('Продукт ' || p_product_name || ' не найден.');
        rollback;
        raise;
end;