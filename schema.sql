-- MySQL 8.4 기준
-- 카페 주문 관리 데이터베이스

CREATE DATABASE IF NOT EXISTS cafe_db
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE cafe_db;

-- 스크립트를 다시 실행할 수 있도록 자식 테이블부터 삭제
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS customer;


-- 1. 고객 테이블
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at DATE NOT NULL
);


-- 2. 메뉴 테이블
CREATE TABLE menu (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price INT NOT NULL,
    category VARCHAR(50) NOT NULL
);


-- 3. 주문 테이블
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    ordered_at DATETIME NOT NULL,

    FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
);


-- 4. 주문 상세 테이블
CREATE TABLE order_item (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    menu_id INT NOT NULL,
    quantity INT NOT NULL,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (menu_id)
        REFERENCES menu(menu_id)
);

