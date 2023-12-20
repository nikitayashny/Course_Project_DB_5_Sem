alter session set container = CP_YNS_PDB;

--------------- категории товаров ---------------
create table product_categories 
(
    category_id   number primary key,
    category_name varchar(200) not null
);

--------------- товары ---------------
create table products
(
    product_id   number primary key,
    product_name varchar(200) not null,
    category_id  number,
    price        decimal(10,2) not null,
    description  varchar(255),
    image_url    varchar(200),
    foreign key (category_id) references product_categories(category_id)
);

alter table products
add quantity number default 0;

alter table products modify price number(10,2);

--------------- покупатели ---------------
create table customers 
(
  customer_id  number primary key,
  first_name   varchar2(50),
  last_name    varchar2(50),
  email        varchar2(100),
  phone_number varchar2(20),
  address      varchar2(200)
);

alter table customers
add constraint uk_first_name unique (first_name);
--------------- заказы ---------------
create table orders 
(
  order_id     number primary key,
  customer_id  number,
  order_date   date,
  total_amount number,
  foreign key (customer_id) references customers(customer_id)
);

alter table orders
add status_id number;

alter table orders
add constraint fk_order_statuses foreign key (status_id) references order_statuses(status_id);

--------------- состав заказа ---------------
create table composition_of_orders
(
  order_id     number,
  product_id   number,
  quantity     number,
  foreign key (order_id) references orders(order_id),
  foreign key (product_id) references products(product_id)
);

alter table composition_of_orders
add composition_id number primary key;

--------------- статус заказа ---------------
create table order_statuses 
(
  status_id   number primary key,
  status_name varchar2(50) not null
);

--------------- корзина ---------------
create table user_cart
(
  cart_id     number primary key,
  customer_id number,
  foreign key (customer_id) references customers(customer_id)
);

--------------- товары в корзине ---------------
create table cart_items
(
  cart_item_id number primary key,
  cart_id      number,
  product_id   number,
  quantity     number,
  foreign key (cart_id) references user_cart(cart_id),
  foreign key (product_id) references products(product_id)
);









