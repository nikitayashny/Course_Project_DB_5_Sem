begin
    create_new_user('TEST', 'test_surname', 'test@gmail.com', '+375234525342', 'Minsk', 123);
end;

drop user TEST;
select * from customers;
delete from customers where first_name = 'TEST';
commit;

create public synonym create_new_user for SYSTEM.create_new_user;

-- процедура создания нового пользователя
create or replace procedure create_new_user (
    p_username in varchar,
    p_usersurname in varchar,
    p_email in varchar,
    p_phone_number in varchar,
    p_address in varchar,
    p_password in number
) as
    p_count  number;
    p_id number;
begin
    IF p_email IS NOT NULL THEN
        IF REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$') = FALSE THEN
           dbms_output.put_line('Неправильный формат электронной почты');
           return;
        END IF;
    END IF;
    
    IF REGEXP_LIKE(p_phone_number, '^\+[0-9]{1,3}[0-9]{9}$') = FALSE THEN
        dbms_output.put_line('Неправильный формат телефона');
           return;
        end if;

    select count(*) into p_count from customers where first_name = p_username;
    
    if(p_count > 0) then
        dbms_output.put_line('имя занято');
        rollback;
        return;
    end if;
        

    select NVL(max(customer_id),0)
    into p_id
    from customers;
    
    insert into customers values (p_id + 1, p_username, p_usersurname, p_email, p_phone_number, p_address);
    
    execute immediate 'create user ' || p_username || ' identified by ' || p_password;
    execute immediate 'grant USER_DEFAULT to ' || p_username;
    commit;
    exception
        when others then
        dbms_output.put_line('Ошибка при выполнении процедуры');
        rollback;
        raise;
end;

