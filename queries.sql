USE cafe_db;


-- =====================================================
-- 1. 전체 메뉴 조회
-- 모든 메뉴 정보를 확인한다.
-- =====================================================

SELECT *
FROM menu;


-- =====================================================
-- 2. 5000원 이상 메뉴 조회
-- WHERE를 사용하여 가격 조건으로 메뉴를 검색한다.
-- =====================================================

SELECT *
FROM menu
WHERE price >= 5000;


-- =====================================================
-- 3. 가격이 높은 순서대로 메뉴 조회
-- ORDER BY를 사용하여 메뉴를 가격 내림차순으로 정렬한다.
-- =====================================================

SELECT *
FROM menu
ORDER BY price DESC;


-- =====================================================
-- 4. 가장 비싼 메뉴 TOP 3
-- ORDER BY와 LIMIT를 이용해 상위 3개 메뉴를 조회한다.
-- =====================================================

SELECT *
FROM menu
ORDER BY price DESC
LIMIT 3;


-- =====================================================
-- 5. 주문과 고객 정보 조회
-- orders와 customer를 INNER JOIN하여
-- 각 주문을 누가 했는지 확인한다.
-- =====================================================

SELECT
    o.order_id,
    c.name AS customer_name,
    o.ordered_at
FROM orders o
INNER JOIN customer c
    ON o.customer_id = c.customer_id
ORDER BY o.order_id ASC;


-- =====================================================
-- 6. 주문 상세와 메뉴 정보 조회
-- order_item과 menu를 INNER JOIN하여
-- 주문에 포함된 메뉴와 수량을 조회한다.
-- =====================================================

SELECT
    oi.order_id,
    m.name AS menu_name,
    oi.quantity
FROM order_item oi
INNER JOIN menu m
    ON oi.menu_id = m.menu_id
ORDER BY oi.order_id ASC;


-- =====================================================
-- 7. 고객별 주문 메뉴와 수량 조회
-- customer, orders, order_item, menu 테이블을 연결하여
-- 누가 어떤 메뉴를 몇 개 주문했는지 조회한다.
-- =====================================================

SELECT
    o.order_id,
    c.name AS customer_name,
    m.name AS menu_name,
    oi.quantity
FROM orders o
INNER JOIN customer c
    ON o.customer_id = c.customer_id
INNER JOIN order_item oi
    ON o.order_id = oi.order_id
INNER JOIN menu m
    ON oi.menu_id = m.menu_id
ORDER BY o.order_id ASC;


-- =====================================================
-- 8. 주문하지 않은 고객까지 포함해서 조회
-- LEFT JOIN을 사용하여 주문 기록이 없는 고객도 조회한다.
-- =====================================================

SELECT
    o.order_id,
    c.name AS customer_name,
    m.name AS menu_name,
    oi.quantity
FROM customer c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
LEFT JOIN order_item oi
    ON o.order_id = oi.order_id
LEFT JOIN menu m
    ON oi.menu_id = m.menu_id
ORDER BY o.order_id ASC;


-- =====================================================
-- 9. 고객별 주문 횟수
-- GROUP BY와 COUNT를 이용하여
-- 고객마다 몇 번 주문했는지 계산한다.
-- =====================================================

SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS order_count
FROM customer c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY order_count DESC;


-- =====================================================
-- 10. 메뉴별 총 판매 수량
-- GROUP BY와 SUM을 이용하여
-- 각 메뉴가 총 몇 개 판매됐는지 계산한다.
-- =====================================================

SELECT
    m.name AS menu_name,
    SUM(oi.quantity) AS total_quantity
FROM menu m
LEFT JOIN order_item oi
    ON m.menu_id = oi.menu_id
GROUP BY m.menu_id, m.name
ORDER BY total_quantity DESC;


-- =====================================================
-- 11. 카테고리별 평균 메뉴 가격
-- GROUP BY와 AVG를 이용하여
-- 카테고리별 평균 가격을 계산한다.
-- =====================================================

SELECT
    category,
    AVG(price) AS avg_price
FROM menu
GROUP BY category;


-- =====================================================
-- 12. 평균 가격보다 비싼 메뉴 조회
-- 서브쿼리에서 전체 메뉴 평균 가격을 구한 뒤
-- 평균보다 비싼 메뉴를 조회한다.
-- =====================================================

SELECT
    name,
    price
FROM menu
WHERE price > (
    SELECT AVG(price)
    FROM menu
);


-- =====================================================
-- 13. 아메리카노 가격 수정
-- UPDATE를 이용하여 아메리카노 가격을
-- 4500원에서 4700원으로 변경한다.
-- =====================================================

UPDATE menu
SET price = 4700
WHERE name = '아메리카노';

-- 수정 결과 확인
SELECT *
FROM menu
WHERE name = '아메리카노';


-- =====================================================
-- 14. 주문 상세 데이터 삭제
-- DELETE를 이용하여 특정 주문 상세 데이터를 삭제한다.
-- order_item은 처음에 12개이므로 삭제 후에도 11개가 남는다.
-- =====================================================

DELETE FROM order_item
WHERE order_item_id = 12;

-- 삭제 결과 확인
SELECT *
FROM order_item
ORDER BY order_item_id;


-- =====================================================
-- 15. 주문 시간 인덱스 생성
-- 기간별 주문 조회 및 주문 시간 정렬에 ordered_at을
-- 자주 사용한다고 가정하여 인덱스를 생성한다.
-- MySQL CREATE INDEX 문법 사용.
-- =====================================================

CREATE INDEX idx_orders_ordered_at
ON orders(ordered_at);

-- 인덱스 생성 결과 확인
SHOW INDEX FROM orders;
