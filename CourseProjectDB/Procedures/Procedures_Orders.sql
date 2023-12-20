-- add_order(customer_id, total_amount, status_id);
-- delete_order(order_id);
-- add_order_composition(order_id, product_id, quantity);
-- delete_order_composition(order_id)

create public synonym add_order for SYSTEM.add_order;
create public synonym delete_order for SYSTEM.delete_order;
create public synonym add_order_composition for SYSTEM.add_order_composition;
create public synonym delete_order_composition for SYSTEM.delete_order_composition;

-------------------------------------------------------- ЗАКАЗЫ ----------------------------------------------------------------

-- процедура создания заказа
create or replace procedure add_order (
    p_customer_id  in number,
    p_total_amount in number,
    p_status_id    in number
) as
    p_order_id number;
begin
    select max(order_id)
    into p_order_id
    from orders;

    insert into orders
    values (p_order_id + 1, p_customer_id, sysdate, p_total_amount, p_status_id);
    commit;
exception
    when no_data_found then 
        insert into orders
        values (1, p_customer_id, sysdate, p_total_amount, p_status_id);
        commit; 
    when others then
        dbms_output.put_line('Ошибка при добавлении заказа.');
        rollback;
        raise;
end;

-- удаление заказа
create or replace procedure delete_order (
    p_order_id in number
) as
begin
    delete from orders
    where order_id = p_order_id;
    commit;
exception
    when others then 
        dbms_output.put_line('Заказ ' || p_order_id || ' не найден.'); 
        rollback;
        raise;
end;

-- добавление состава заказа
create or replace procedure add_order_composition (
    p_order_id      in number,
    p_product_id    in number,
    p_quantity        in number
) as
    p_composition_id number;
begin
    select max(composition_id)
    into p_composition_id
    from composition_of_orders;

    insert into composition_of_orders
    values (p_order_id, p_product_id, p_quantity, p_composition_id + 1);
    commit;
    
    update products
    set quantity = quantity - p_quantity
    where product_id = p_product_id;
    commit;
exception
    when no_data_found then 
        insert into composition_of_orders
        values (p_order_id, p_product_id, p_quantity, 1);
        commit;
        
    when others then
        dbms_output.put_line('Ошибка при добавлении композиции.');
        rollback;
        raise;
end;

-- удаление состава заказа
create or replace procedure delete_order_composition (
    p_order_id in number
) as
    p_quantity number;
    p_product_id number;
begin
    select quantity
    into p_quantity
    from composition_of_orders
    where order_id = p_order_id;
    
    select product_id
    into p_product_id
    from composition_of_orders
    where order_id = p_order_id;
    
    update products
    set quantity = quantity + p_quantity
    where product_id = p_product_id;
    commit;

    delete from composition_of_orders
    where order_id = p_order_id;
    commit;
exception
    when others then 
        dbms_output.put_line('Композиция ' || p_order_id || ' не найден.'); 
        rollback;
        raise;
end;

