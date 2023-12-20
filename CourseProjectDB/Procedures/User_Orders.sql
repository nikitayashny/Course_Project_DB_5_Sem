-- make_order('Футболка с логотипом', 1);
-- undo_order('order_id');
-- undo_last_order();
-- change_order_status(1, 'В обработке');                                                    
-- getcustomerorders();


begin
    getcustomerorders();
end;
begin 
    make_order('Футболка с логотипом', 1);
end;
begin 
    make_order('qwerty', 1);
end;
begin 
    undo_last_order();
end;

begin
    change_order_status(1, 'qwerty');
end;

-- + добавлены публичные синонимы
-------------------------------------------------------- ЗАКАЗЫ ----------------------------------------------------------------

-- оформление заказа со стороны пользователя
create or replace procedure make_order (
    p_product_name      in varchar,
    p_quantity          in number
) as 
    p_order_id          number;
    p_customer_id       number;
    p_total_amount      number;
    p_product_id        number;
    p_customer_name     varchar(200);
    p_current_quantity  number;
begin
    select user into p_customer_name from dual;
    
    select quantity 
    into p_current_quantity
    from products
    where product_name = p_product_name;
    
    if (p_quantity > p_current_quantity) then
        dbms_output.put_line('Количество не может превышать имеющееся');
        return;
    end if;
    
    select customer_id 
    into p_customer_id
    from customers 
    where first_name = p_customer_name;
    
    select p_quantity * price
    into p_total_amount
    from products
    where product_name = p_product_name;
    
    select max(order_id)
    into p_order_id
    from orders; 
    
    select product_id 
    into p_product_id
    from products
    where product_name = p_product_name;
    
    add_order(p_customer_id, p_total_amount, 4);
    add_order_composition(p_order_id + 1, p_product_id, p_quantity); 
exception
    when no_data_found then
        dbms_output.put_line('Такого товара нет.'); 
    when others then 
        dbms_output.put_line('Ошибка при оформлении заказа.'); 
        rollback;
        raise;
end;

create public synonym make_order for SYSTEM.make_order;

-- отмена заказа со стороны пользователя
create or replace procedure undo_order (
    p_order_id in number
) as
    begin
        delete_order_composition(p_order_id);
        delete_order(p_order_id);    
    exception
        when no_data_found then
            dbms_output.put_line('Такого товара нет.'); 
        when others then
            rollback;
            raise;
    end;
    
create public synonym undo_order for SYSTEM.undo_order;
    
-- отмена последнего заказа
create or replace procedure undo_last_order
as
    p_customer_id   varchar(200);
    p_order_id      number;
    p_customer_name varchar(200);
begin
        select user 
        into p_customer_name 
        from dual;
        
        select customer_id
        into p_customer_id
        from customers
        where first_name = p_customer_name;
        
        select max(order_id)
        into p_order_id
        from orders
        where customer_id = p_customer_id;
        
        delete_order_composition(p_order_id);
        delete_order(p_order_id);
        
        exception
        when others then
            rollback;
            raise;
end;

create public synonym undo_last_order for SYSTEM.undo_last_order;
create public synonym change_order_status for SYSTEM.change_order_status;
-- изменение статуса заказа
CREATE OR REPLACE PROCEDURE change_order_status(
    p_order_id IN orders.order_id%TYPE,
    p_status_name IN order_statuses.status_name%TYPE
)
IS
    v_status_id order_statuses.status_id%TYPE;
BEGIN
    SELECT status_id INTO v_status_id
    FROM order_statuses
    WHERE status_name = p_status_name;
    
    IF v_status_id IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Указанный статус не найден.');
        RETURN;
    END IF;
    IF p_order_id IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Указанный заказ не найден.');
        RETURN;
    END IF;
    
    UPDATE orders
    SET status_id = v_status_id
    WHERE order_id = p_order_id;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Статус заказа успешно изменен.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('указанный статус не найден.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка. Изменение статуса заказа не выполнено.');
END;



-- просмотр своих заказов
create public synonym GetCustomerOrders for SYSTEM.GetCustomerOrders;

CREATE OR REPLACE PROCEDURE GetCustomerOrders
AS
    v_order_id      NUMBER;
    v_order_date    DATE;
    v_total_amount  NUMBER;
    v_status_name   VARCHAR2(50);
    v_product_name  VARCHAR2(200);
    v_product_qty   NUMBER;
    p_customer_id   number;
    p_customer_name varchar2(200);
BEGIN
 select user 
        into p_customer_name 
        from dual;
    
    select customer_id
        into p_customer_id
        from customers
        where first_name = p_customer_name;
    FOR order_rec IN (
    
        SELECT o.order_id, o.order_date, o.total_amount, os.status_name, p.product_name, co.quantity
        FROM orders o
        INNER JOIN order_statuses os ON o.status_id = os.status_id
        INNER JOIN composition_of_orders co ON o.order_id = co.order_id
        INNER JOIN products p ON co.product_id = p.product_id
        WHERE o.customer_id = p_customer_id
    ) LOOP
        v_order_id := order_rec.order_id;
        v_order_date := order_rec.order_date;
        v_total_amount := order_rec.total_amount;
        v_status_name := order_rec.status_name;
        v_product_name := order_rec.product_name;
        v_product_qty := order_rec.quantity;
      
        -- Обработка полученных данных, например, вывод на экран или сохранение в переменные
        DBMS_OUTPUT.PUT_LINE('Order ID: ' || v_order_id || ', Order Date: ' || v_order_date || ', Total Amount: ' || v_total_amount || ', Status: ' || v_status_name || ', Product: ' || v_product_name || ', Quantity: ' || v_product_qty);
    END LOOP;
END;


















