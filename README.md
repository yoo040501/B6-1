# Cafe Order Management Database

## 1. 프로젝트 개요

카페 주문 관리 서비스를 주제로 MySQL 기반 데이터베이스를 설계하고, 테이블 간 관계를 구성한 뒤 SQL을 이용해 조회, 조인, 집계, 수정, 삭제, 인덱스 생성까지 실습한 프로젝트입니다.

백엔드 프레임워크는 사용하지 않았으며, MySQL CLI를 통해 직접 SQL을 실행했습니다.

---

## 2. 개발 환경

* Host OS: macOS
* Database: MySQL 8.4
* 실행 환경: Docker
* 접속 도구: MySQL CLI
* 문자셋: utf8mb4

MySQL은 Docker 컨테이너에서 실행했습니다.

```bash
docker run -d \
  --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=비밀번호 \
  -e MYSQL_DATABASE=cafe_db \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  mysql:8.4
```

MySQL 접속:

```bash
docker exec -it mysql-db bash
mysql -u root -p
```

---

## 3. 데이터베이스 주제

카페의 고객, 메뉴, 주문, 주문 상세 정보를 관리하는 데이터베이스입니다.

구성 테이블은 다음과 같습니다.

* `customer`: 고객 정보
* `menu`: 메뉴 정보
* `orders`: 주문 정보
* `order_item`: 주문에 포함된 메뉴와 수량

---

## 4. 테이블 관계

```text
customer 1 : N orders
orders   1 : N order_item
menu     1 : N order_item
```

### 관계 설명

* 한 명의 고객은 여러 번 주문할 수 있습니다.
* 하나의 주문에는 여러 메뉴가 포함될 수 있습니다.
* 하나의 메뉴는 여러 주문에 포함될 수 있습니다.
* `order_item` 테이블이 주문과 메뉴를 연결합니다.

---

## 5. PK / FK 구성

### customer

* `customer_id`: PK

### menu

* `menu_id`: PK

### orders

* `order_id`: PK
* `customer_id`: FK → `customer.customer_id`

### order_item

* `order_item_id`: PK
* `order_id`: FK → `orders.order_id`
* `menu_id`: FK → `menu.menu_id`

FK를 통해 존재하지 않는 고객, 주문, 메뉴를 참조하는 데이터가 입력되지 않도록 데이터 무결성을 유지합니다.

---

## 6. 제약조건

다음 제약조건을 적용했습니다.

* `PRIMARY KEY`: 각 행을 고유하게 식별
* `FOREIGN KEY`: 테이블 간 관계 유지
* `NOT NULL`: 필수 값 누락 방지
* `UNIQUE`: 고객 이메일 중복 방지
* `AUTO_INCREMENT`: PK 자동 증가

예:

```sql
customer_id INT AUTO_INCREMENT PRIMARY KEY,
email VARCHAR(100) NOT NULL UNIQUE
```

---

## 7. 샘플 데이터

각 테이블에 최소 10개 이상의 데이터를 입력했습니다.

* customer: 10행
* menu: 10행
* orders: 10행
* order_item: 12행

FK 관계를 만족시키기 위해 부모 테이블부터 데이터를 입력했습니다.

```text
customer
menu
↓
orders
↓
order_item
```

---

## 8. 주요 SQL 실습

총 15개의 핵심 SQL 쿼리를 작성했습니다.

### 기본 조회

* 전체 메뉴 조회
* 5000원 이상 메뉴 조회
* 가격 내림차순 정렬
* 가장 비싼 메뉴 TOP 3

사용 기능:

```sql
SELECT
WHERE
ORDER BY
LIMIT
```

### JOIN

다음 관계를 JOIN으로 조회했습니다.

* 주문 + 고객
* 주문 상세 + 메뉴
* 고객 + 주문 + 주문 상세 + 메뉴
* 주문하지 않은 고객까지 포함한 조회

사용 기능:

```sql
INNER JOIN
LEFT JOIN
```

### 집계

다음 데이터를 집계했습니다.

* 고객별 주문 횟수
* 메뉴별 총 판매 수량
* 카테고리별 평균 메뉴 가격

사용 함수:

```sql
COUNT()
SUM()
AVG()
GROUP BY
```

### 서브쿼리

전체 메뉴 평균 가격을 구한 뒤, 평균보다 비싼 메뉴를 조회했습니다.

```sql
SELECT name, price
FROM menu
WHERE price > (
    SELECT AVG(price)
    FROM menu
);
```

### 데이터 수정

`UPDATE`를 사용해 아메리카노 가격을 수정했습니다.

```sql
UPDATE menu
SET price = 4700
WHERE name = '아메리카노';
```

### 데이터 삭제

`DELETE`를 이용해 특정 주문 상세 데이터를 삭제했습니다.

```sql
DELETE FROM order_item
WHERE order_item_id = 12;
```

---

## 9. 인덱스

주문 시간을 기준으로 기간 검색이나 정렬을 자주 수행한다고 가정하여 `ordered_at` 컬럼에 인덱스를 생성했습니다.

```sql
CREATE INDEX idx_orders_ordered_at
ON orders(ordered_at);
```

인덱스가 없으면 조건에 맞는 데이터를 찾기 위해 테이블의 여러 행을 직접 확인할 수 있습니다.

인덱스를 사용하면 `ordered_at` 값을 별도의 정렬된 검색 구조로 관리하기 때문에 특정 날짜나 기간의 데이터를 더 빠르게 찾을 수 있습니다.

원본 데이터 자체가 정렬되는 것은 아니며, 실제 출력 순서를 보장하려면 `ORDER BY`를 사용해야 합니다.

---

## 10. 파일 구성

```text
database-mission/
├── schema.sql
├── sample_data.sql
├── queries.sql
├── results/
└── README.md
```

### schema.sql

데이터베이스와 테이블을 생성합니다.

### sample_data.sql

각 테이블의 테스트 데이터를 입력합니다.

### queries.sql

조회, 조인, 집계, 서브쿼리, 수정, 삭제, 인덱스 쿼리를 포함합니다.

### results/

각 SQL 실행 결과의 캡처 이미지 또는 결과 텍스트를 저장합니다.

---

## 11. SQL 파일 실행 방법

Docker에서 실행 중인 MySQL에 SQL 파일을 전달하여 실행할 수 있습니다.

```bash
docker exec -i mysql-db mysql -u root -p비밀번호 < schema.sql
```

샘플 데이터 입력:

```bash
docker exec -i mysql-db mysql -u root -p비밀번호 < sample_data.sql
```

쿼리 실행:

```bash
docker exec -i mysql-db mysql -u root -p비밀번호 < queries.sql
```

쿼리 실행 결과를 파일로 저장:

```bash
docker exec -i mysql-db mysql -u root -p비밀번호 < queries.sql > results.txt
```

---

## 12. 학습 내용

이번 실습을 통해 다음 내용을 학습했습니다.

* 데이터베이스에서 테이블을 여러 개로 나누는 이유
* PK와 FK의 역할
* 1:N 관계의 의미
* 테이블 간 데이터를 JOIN하는 방법
* GROUP BY를 이용한 데이터 집계
* 서브쿼리를 이용한 조건 조회
* UPDATE와 DELETE를 이용한 데이터 변경
* FK를 이용한 데이터 무결성 유지
* 인덱스를 이용한 조회 성능 개선 원리

특히 SQL에서 데이터를 단순히 저장하는 것뿐만 아니라, PK와 FK를 이용해 테이블 간 관계를 구성하고 JOIN을 통해 다시 필요한 형태로 조회하는 과정을 이해하는 것을 목표로 했습니다.
