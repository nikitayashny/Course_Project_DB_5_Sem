-- add_product_to_cart('Джинсы', 1);
-- remove_from_cart('Джинсы',1);
-- get_cart();

begin
    add_product_to_cart('Джинсы', 1);
end;

begin 
    remove_from_cart('Джинсы',1);
end;

begin
    get_cart();
end;

-- + добавлены публичные синонимы
create public synonym add_product_to_cart for SYSTEM.add_product_to_cart;
create public synonym remove_from_cart for SYSTEM.remove_from_cart;
create public synonym get_cart for SYSTEM.get_cart;
                                                                            
-- процедура добавления товара в корзину
create or replace procedure add_product_to_cart (
    p_product_name      in varchar,
    p_quantity          in number
) as 
    p_current_quantity  number;
    p_customer_name     varchar(200);
    p_cart_item_id      number;
    p_cart_id           number;
    p_product_id        number;
    p_customer_id       number;
    p_count             number;
    p_quantity_in_cart  number;
begin
    select quantity 
    into p_current_quantity
    from products
    where product_name = p_product_name;
    
    if (p_quantity > p_current_quantity) then
        dbms_output.put_line('Количество не может превышать имеющееся');
        return;
    end if;

    select user into p_customer_name from dual;

    select customer_id 
    into p_customer_id
    from customers 
    where first_name = p_customer_name;
    
    select max(cart_item_id)
    into p_cart_item_id
    from cart_items; 

    select cart_id
    into p_cart_id
    from user_cart 
    where customer_id = p_customer_id;
    
    select product_id
    into p_product_id
    from products
    where product_name = p_product_name;
    
    select count(*)
    into p_count
    from cart_items
    where product_id = p_product_id and cart_id = p_cart_id;
    
    if (p_count > 0) then
        select quantity
        into p_quantity_in_cart
        from cart_items
        where product_id = p_product_id and cart_id = p_cart_id;
    
        update cart_items
        set quantity = quantity + p_quantity
        where product_id = p_product_id and cart_id = p_cart_id; 
        
        DBMS_SCHEDULER.SET_ATTRIBUTE(
        name        => 'remove_from_cart_' || p_product_id || '_' || p_cart_id,
        attribute   => 'job_action',
        value       => 'BEGIN remove_from_cart(''' || p_product_name || ''', ' || (p_quantity_in_cart + p_quantity) || '); END;'
        );
        
    else
        insert into cart_items values (p_cart_item_id + 1, p_cart_id, p_product_id, p_quantity);
        
        DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'remove_from_cart_' || p_product_id || '_' || p_cart_id,
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN remove_from_cart(''' || p_product_name || ''', ' || p_quantity || '); END;',
        start_date      => SYSTIMESTAMP + INTERVAL '1' HOUR,
        repeat_interval => '', 
        enabled         => TRUE,
        auto_drop       => TRUE
        );
    end if;
    
    update products
    set quantity = quantity - p_quantity
    where product_id = p_product_id;
    commit;
    
exception
    when others then 
        dbms_output.put_line('Ошибка при оформлении заказа.'); 
        rollback;
        raise;
end;

-- удаление из корзины
create or replace procedure remove_from_cart (
    p_product_name  in varchar,
    p_quantity     in number
) as 
    p_quantity_in_cart  number;
    p_product_id        number;
    p_cart_id           number;
    p_customer_name     varchar(200);
begin
    select user into p_customer_name from dual;
    
    select customer_id
    into p_cart_id
    from customers
    where first_name = p_customer_name;

    select product_id
    into p_product_id
    from products
    where product_name = p_product_name; 

    select quantity
    into p_quantity_in_cart
    from cart_items
    where cart_id = p_cart_id and product_id = p_product_id;

    if (p_quantity > p_quantity_in_cart) then
        dbms_output.put_line('Количество не может превышать имеющееся');
        return;
    end if;
    
    if (p_quantity = p_quantity_in_cart) then
        delete from cart_items 
        where cart_id = p_cart_id and product_id = p_product_id;
        commit;
        
        update products
        set quantity = quantity + p_quantity
        where product_id = p_product_id;
        commit;
        
         DBMS_SCHEDULER.DROP_JOB(
            job_name => 'remove_from_cart_' || p_product_id || '_' || p_cart_id
        );
        
        return;
    end if;
    
    update cart_items 
    set quantity = quantity - p_quantity
    where cart_id = p_cart_id and product_id = p_product_id;
    commit;
    
    update products
    set quantity = quantity + p_quantity
    where product_id = p_product_id;
    commit;
    
    DBMS_SCHEDULER.SET_ATTRIBUTE(
        name        => 'remove_from_cart_' || p_product_id || '_' || p_cart_id,
        attribute   => 'job_action',
        value       => 'BEGIN remove_from_cart(''' || p_product_name || ''', ' || (p_quantity_in_cart - p_quantity) || '); END;'
    );
    
    exception
        when no_data_found then
            rollback;
        when others then
            rollback;
            raise;
end;

-- выборка из корзины
create or replace procedure get_cart
as
    p_customer_id number;
    p_customer_name varchar(200);
begin
    select user into p_customer_name from dual;
    
    select customer_id
    into p_customer_id
    from customers
    where first_name = p_customer_name;

    for item in 
    (
        select p.product_name, ci.quantity, p.price, (ci.quantity * p.price) as total_price
        from cart_items ci
        inner join products p on ci.product_id = p.product_id
        where ci.cart_id = (select cart_id from user_cart where customer_id = p_customer_id)
    ) loop
    dbms_output.put_line('Product Name: ' || item.product_name);
    dbms_output.put_line('Quantity: ' || item.quantity);
    dbms_output.put_line('Price: ' || item.price);
    dbms_output.put_line('Total Price: ' || item.total_price);
    dbms_output.put_line('-----------------------');
  end loop;
  exception
    when others then
        dbms_output.put_line('Ошибка при выполнении процедуры');
        rollback;
        raise;
end;



