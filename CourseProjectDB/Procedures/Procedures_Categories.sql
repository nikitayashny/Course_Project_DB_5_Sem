-- add_category('new category');
-- delete_category('new category);
begin
    add_category('�����');
end;

begin
   delete_category('new category');
end;

create public synonym add_category for SYSTEM.add_category;
create public synonym delete_category for SYSTEM.delete_category;

-------------------------------------------------------- ��������� ------------------------------------------------------------

-- ��������� ���������� ����� ��������� ������
create or replace procedure add_category (
    p_category_name in varchar2
) as
    p_category_id number;
    p_count number;
begin
    select count(*) into p_count from product_categories where category_name = p_category_name;
    
    if(p_count > 0) then
        dbms_output.put_line('��� ������');
        rollback;
        return;
    end if;

    select max(category_id)
    into p_category_id
    from product_categories;
    
    insert into product_categories (category_id, category_name)
    values (p_category_id + 1, p_category_name);
    commit; 
exception
    when no_data_found then 
        insert into product_categories (category_id, category_name)
        values (1, p_category_name);  
        commit; 
    when others then
        dbms_output.put_line('������ ��� ���������� ���������');
        rollback;
        raise;
end;

-- ��������� �������� ��������� ������
create or replace procedure delete_category (
    p_category_name in varchar2
) as
begin
    delete from product_categories
    where category_name = p_category_name;
    commit;
exception
    when no_data_found then 
        dbms_output.put_line('��������� ' || p_category_name || ' �� �������.'); 
        rollback;
    when others then
        dbms_output.put_line('������ ��� ���������� ���������');
        rollback;
        raise;
end;
