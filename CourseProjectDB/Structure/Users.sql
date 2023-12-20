create role USER_DEFAULT;                   

grant create session to USER_DEFAULT;
grant alter session to USER_DEFAULT;
grant execute on make_order to USER_DEFAULT;
grant execute on undo_order to USER_DEFAULT;
grant execute on undo_last_order to USER_DEFAULT;
grant execute on add_product_to_cart to USER_DEFAULT;
grant execute on remove_from_cart to USER_DEFAULT;
grant execute on get_cart to USER_DEFAULT;
grant execute on view_sales_by_period to USER_DEFAULT;
grant execute on display_popular_products to USER_DEFAULT;
grant execute on display_total_amount_of_products to USER_DEFAULT;
grant execute on display_product_categories to USER_DEFAULT;
grant execute on GetCustomerOrders to USER_DEFAULT;

create user CP_YNS_USER_1 identified by 123;
create user CP_YNS_USER_2 identified by 123;
grant USER_DEFAULT to CP_YNS_USER_1;
grant USER_DEFAULT to CP_YNS_USER_2;



create role ADMIN_DEFAULT;
grant create session to ADMIN_DEFAULT;
grant alter session to ADMIN_DEFAULT;
grant execute on make_order to ADMIN_DEFAULT;
grant execute on undo_order to ADMIN_DEFAULT;
grant execute on undo_last_order to ADMIN_DEFAULT;
grant execute on add_product_to_cart to ADMIN_DEFAULT;
grant execute on remove_from_cart to ADMIN_DEFAULT;
grant execute on add_category to ADMIN_DEFAULT;
grant execute on delete_category to ADMIN_DEFAULT;
grant execute on add_product to ADMIN_DEFAULT;
grant execute on delete_product to ADMIN_DEFAULT;
grant execute on update_product to ADMIN_DEFAULT;
grant execute on add_quantity_product to ADMIN_DEFAULT;
grant execute on remove_quantity_product to ADMIN_DEFAULT;
grant execute on view_sales_by_period to ADMIN_DEFAULT;
grant execute on display_total_amount_of_products to ADMIN_DEFAULT;
grant execute on display_popular_products to ADMIN_DEFAULT;
grant execute on display_product_categories to ADMIN_DEFAULT;
grant execute on display_order_information to ADMIN_DEFAULT;
grant execute on display_customer_information to ADMIN_DEFAULT;
grant execute on GetCustomerOrders to ADMIN_DEFAULT;
grant execute on change_order_status to ADMIN_DEFAULT;


create user CP_YNS_ADMIN_1 identified by 123;
grant ADMIN_DEFAULT to CP_YNS_ADMIN_1;

create role GUEST_DEFAULT;
grant create session to GUEST_DEFAULT;
grant execute on create_new_user to GUEST_DEFAULT;

create user CP_YNS_GUEST identified by 123;
grant GUEST_DEFAULT to CP_YNS_GUEST;










