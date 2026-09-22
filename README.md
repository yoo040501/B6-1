# Cafe Order Management Database

## 1. 프로젝트 개요

카페 주문 관리 서비스를 주제로 MySQL 기반 데이터베이스를 설계하고, 테이블 간 관계를 구성한 뒤 SQL을 이용해 조회, 조인, 집계, 수정, 삭제, 인덱스 생성까지 실습한 프로젝트입니다.

백엔드 프레임워크는 사용하지 않았으며, MySQL CLI를 통해 직접 SQL을 실행했습니다.

이번 실습의 주요 목표는 다음과 같습니다.

* PK/FK를 이용하여 테이블 간 관계를 설계한다.
* 1:N 관계를 이해한다.
* SELECT, INSERT, UPDATE, DELETE를 직접 사용한다.
* JOIN을 이용하여 여러 테이블의 데이터를 연결한다.
* GROUP BY와 집계 함수를 이용하여 데이터를 분석한다.
* 서브쿼리를 이용한 조건 조회를 수행한다.
* 인덱스가 조회 성능에 어떤 역할을 하는지 이해한다.

---

## 2. 개발 환경

* Host OS: macOS
* Database: MySQL 8.4
* 실행 환경: Docker
* SQL 실행 도구: MySQL CLI
* 문자셋: utf8mb4

MySQL은 Docker 컨테이너에서 실행했습니다.

```bash
docker run -d \
  --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=1234 \
  -e MYSQL_DATABASE=cafe_db \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  mysql:8.4
```

MySQL 컨테이너 내부로 접속:

```bash
docker exec -it mysql-db bash
```

MySQL CLI 실행:

```bash
mysql -u root -p
```

---

## 3. 데이터베이스와 엑셀의 차이

엑셀과 데이터베이스는 모두 데이터를 표 형태로 관리할 수 있지만, 데이터베이스는 **테이블 사이의 관계와 데이터 규칙을 시스템 차원에서 관리할 수 있다는 차이**가 있습니다.

예를 들어 엑셀 하나에 고객과 주문 정보를 같이 저장하면 동일한 고객 정보가 반복될 수 있습니다.

```text
고객명 | 이메일            | 주문번호 | 메뉴
김민수 | minsu@example.com | 1        | 아메리카노
김민수 | minsu@example.com | 2        | 콜드브루
```

이 구조에서는 김민수의 이메일을 수정하려면 여러 행을 수정해야 할 수 있습니다.

데이터베이스에서는 고객과 주문 정보를 분리합니다.

```text
customer

customer_id | name   | email
1           | 김민수 | minsu@example.com
```

```text
orders

order_id | customer_id
1        | 1
2        | 1
```

`customer_id`를 이용하여 두 테이블을 연결하기 때문에 동일한 고객 정보를 주문마다 반복해서 저장하지 않아도 됩니다.

| 항목        | 엑셀         | 관계형 데이터베이스   |
| --------- | ---------- | ------------ |
| 데이터 저장    | 셀과 시트 중심   | 테이블과 행 중심    |
| 데이터 관계    | 사용자가 직접 관리 | PK/FK로 관리    |
| 중복 데이터    | 발생하기 쉬움    | 테이블 분리로 감소   |
| 잘못된 값 입력  | 상대적으로 자유로움 | 제약조건으로 차단 가능 |
| 여러 데이터 연결 | 수식 등을 이용   | JOIN 사용      |
| 검색/집계     | 필터, 함수 사용  | SQL 사용       |
| 검색 최적화    | 제한적        | 인덱스 사용 가능    |

따라서 데이터베이스를 사용하는 이유는 단순히 데이터의 양이 많기 때문만이 아니라, **관련된 데이터를 관계와 규칙을 이용하여 일관성 있게 관리하기 위해서**입니다.

---

## 4. 데이터베이스 주제

카페에서 발생하는 고객, 메뉴, 주문, 주문 상세 정보를 관리하는 데이터베이스를 설계했습니다.

총 4개의 테이블을 사용합니다.

1. `customer`
2. `menu`
3. `orders`
4. `order_item`

각 테이블의 역할은 다음과 같습니다.

### customer

카페를 이용하는 고객 정보를 저장합니다.

### menu

판매하는 메뉴와 가격, 카테고리를 저장합니다.

### orders

고객이 수행한 주문 한 건에 대한 정보를 저장합니다.

### order_item

각 주문에 어떤 메뉴가 몇 개 포함되어 있는지 저장합니다.

---

## 5. 테이블 관계

테이블의 관계는 다음과 같습니다.

```text
customer 1 : N orders

orders   1 : N order_item

menu     1 : N order_item
```

### customer → orders

고객 한 명은 여러 번 주문할 수 있습니다.

예:

```text
김민수
 ├─ 주문 1
 └─ 주문 3
```

따라서:

```text
customer 1 : N orders
```

관계입니다.

### orders → order_item

한 주문에는 여러 메뉴가 포함될 수 있습니다.

예:

```text
주문 1
 ├─ 아메리카노 2개
 └─ 치즈케이크 1개
```

따라서:

```text
orders 1 : N order_item
```

관계입니다.

### menu → order_item

하나의 메뉴는 여러 주문에 포함될 수 있습니다.

따라서:

```text
menu 1 : N order_item
```

관계입니다.

---

## 6. PK와 FK

### PK (Primary Key)

각 테이블의 행을 고유하게 구분하기 위한 값입니다.

예:

```text
customer.customer_id
menu.menu_id
orders.order_id
order_item.order_item_id
```

PK는 중복될 수 없으며 NULL 값을 가질 수 없습니다.

### FK (Foreign Key)

다른 테이블의 PK를 참조하여 테이블 간 관계를 만드는 컬럼입니다.

현재 데이터베이스에서는 다음 FK를 사용합니다.

```text
orders.customer_id
→ customer.customer_id
```

```text
order_item.order_id
→ orders.order_id
```

```text
order_item.menu_id
→ menu.menu_id
```

---

## 7. 데이터 무결성

FK는 존재하지 않는 데이터를 참조하지 못하도록 막아 데이터 관계가 깨지는 것을 방지합니다.

예를 들어 `customer_id = 999`인 고객이 존재하지 않을 때 다음 SQL을 실행하면:

```sql
INSERT INTO orders (customer_id, ordered_at)
VALUES (999, '2026-09-22 15:00:00');
```

MySQL은 FK 제약조건 오류를 발생시키고 데이터를 저장하지 않습니다.

즉 다음과 같은 잘못된 데이터가 생기는 것을 막습니다.

```text
orders
customer_id = 999

하지만

customer
customer_id = 999 없음
```

이것이 FK를 이용한 **참조 무결성**입니다.

---

## 8. 컬럼 타입 선정

저장하려는 데이터의 성격에 맞게 타입을 선택했습니다.

| 컬럼            | 타입           | 선택 이유                 |
| ------------- | ------------ | --------------------- |
| customer_id   | INT          | 고객을 숫자 ID로 구분하기 위해 사용 |
| name          | VARCHAR(50)  | 이름은 길이가 달라질 수 있는 문자열  |
| email         | VARCHAR(100) | 이메일은 가변 길이 문자열        |
| created_at    | DATE         | 가입 날짜만 저장하면 되므로 DATE  |
| menu_id       | INT          | 메뉴를 숫자로 식별            |
| price         | INT          | 원 단위 가격은 소수점이 필요하지 않음 |
| category      | VARCHAR(50)  | 커피, 음료 등의 문자열 저장      |
| order_id      | INT          | 주문을 고유하게 식별           |
| ordered_at    | DATETIME     | 주문 날짜와 시간이 모두 필요      |
| order_item_id | INT          | 주문 상세 행을 고유하게 식별      |
| quantity      | INT          | 주문 수량은 정수 값           |

`NOT NULL`은 반드시 값이 필요한 컬럼에 적용했습니다.

예:

```sql
name VARCHAR(50) NOT NULL
```

고객 이메일에는 중복 가입을 방지하기 위해 `UNIQUE`를 적용했습니다.

```sql
email VARCHAR(100) NOT NULL UNIQUE
```

---

## 9. 사용한 제약조건

### PRIMARY KEY

행을 고유하게 식별합니다.

```sql
customer_id INT AUTO_INCREMENT PRIMARY KEY
```

### FOREIGN KEY

다른 테이블의 PK를 참조합니다.

```sql
FOREIGN KEY (customer_id)
    REFERENCES customer(customer_id)
```

### NOT NULL

필수 데이터가 비어있는 것을 방지합니다.

```sql
name VARCHAR(50) NOT NULL
```

### UNIQUE

같은 값의 중복 입력을 방지합니다.

```sql
email VARCHAR(100) UNIQUE
```

### AUTO_INCREMENT

PK 값을 직접 입력하지 않아도 자동으로 번호가 증가합니다.

```text
1
2
3
4
...
```

---

## 10. 샘플 데이터

각 테이블에 최소 10행 이상의 데이터를 입력했습니다.

| 테이블        | 데이터 수 |
| ---------- | ----: |
| customer   |    10 |
| menu       |    10 |
| orders     |    10 |
| order_item |    12 |

FK 관계가 있기 때문에 부모 테이블을 먼저 입력했습니다.

```text
customer
menu
 ↓
orders
 ↓
order_item
```

예를 들어 다음 `order_item` 데이터:

```text
order_id = 1
menu_id = 1
quantity = 2
```

는 다음 의미입니다.

```text
1번 주문에서
1번 메뉴인 아메리카노를
2개 주문했다.
```

---

## 11. SQL 쿼리 구성

총 15개의 핵심 SQL을 작성했습니다.

| 번호 | 유형         | 내용           |
| -- | ---------- | ------------ |
| 1  | SELECT     | 전체 메뉴 조회     |
| 2  | WHERE      | 5000원 이상 메뉴  |
| 3  | ORDER BY   | 가격 내림차순      |
| 4  | LIMIT      | 비싼 메뉴 TOP 3  |
| 5  | INNER JOIN | 주문 + 고객      |
| 6  | INNER JOIN | 주문 상세 + 메뉴   |
| 7  | INNER JOIN | 고객 + 주문 + 메뉴 |
| 8  | LEFT JOIN  | 주문 없는 고객 포함  |
| 9  | COUNT      | 고객별 주문 횟수    |
| 10 | SUM        | 메뉴별 판매량      |
| 11 | AVG        | 카테고리별 평균 가격  |
| 12 | SUBQUERY   | 평균보다 비싼 메뉴   |
| 13 | UPDATE     | 메뉴 가격 수정     |
| 14 | DELETE     | 주문 상세 삭제     |
| 15 | INDEX      | 주문 시간 인덱스    |

---

## 12. INNER JOIN과 LEFT JOIN

### INNER JOIN

두 테이블에서 조건이 일치하는 데이터만 조회합니다.

```sql
SELECT
    c.name,
    o.order_id
FROM customer c
INNER JOIN orders o
    ON c.customer_id = o.customer_id;
```

주문이 없는 고객은 결과에서 제외됩니다.

### LEFT JOIN

왼쪽 테이블의 데이터는 모두 유지합니다.

```sql
SELECT
    c.name,
    o.order_id
FROM customer c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;
```

현재 샘플 데이터에서는 `임다은`, `강민재`가 주문하지 않았기 때문에:

```text
name   | order_id
임다은 | NULL
강민재 | NULL
```

처럼 출력됩니다.

즉:

```text
INNER JOIN
→ 서로 연결되는 데이터만

LEFT JOIN
→ 왼쪽 데이터는 모두 유지
```

라는 차이가 있습니다.

---

## 13. GROUP BY와 집계 함수

고객별 주문 횟수는 `COUNT()`를 사용했습니다.

```sql
SELECT
    c.name,
    COUNT(o.order_id)
FROM customer c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;
```

메뉴별 판매 수량은 `SUM()`을 사용했습니다.

```sql
SUM(oi.quantity)
```

카테고리별 평균 가격은 `AVG()`를 사용했습니다.

```sql
AVG(price)
```

`GROUP BY`는 같은 값을 기준으로 여러 행을 하나의 그룹으로 묶어 집계할 때 사용합니다.

---

## 14. 서브쿼리

전체 메뉴의 평균 가격보다 비싼 메뉴를 조회하기 위해 서브쿼리를 사용했습니다.

```sql
SELECT
    name,
    price
FROM menu
WHERE price > (
    SELECT AVG(price)
    FROM menu
);
```

먼저 내부 쿼리가:

```sql
SELECT AVG(price)
FROM menu;
```

전체 평균 가격을 계산하고, 외부 쿼리가 그 결과보다 비싼 메뉴를 찾습니다.

---

## 15. UPDATE와 DELETE

### UPDATE

기존 데이터를 수정할 때 사용합니다.

```sql
UPDATE menu
SET price = 4700
WHERE name = '아메리카노';
```

### DELETE

기존 행을 삭제할 때 사용합니다.

```sql
DELETE FROM order_item
WHERE order_item_id = 12;
```

`WHERE`를 지정하지 않으면 여러 데이터가 한꺼번에 수정 또는 삭제될 수 있으므로 주의해야 합니다.

---

## 16. 인덱스

주문 시간인 `ordered_at` 컬럼에 인덱스를 생성했습니다.

```sql
CREATE INDEX idx_orders_ordered_at
ON orders(ordered_at);
```

`ordered_at`은 특정 기간의 주문을 검색하거나 최근 주문을 조회할 때 자주 사용될 수 있습니다.

예:

```sql
SELECT *
FROM orders
WHERE ordered_at >= '2026-09-21 00:00:00';
```

인덱스가 없다면 데이터가 많을 경우 테이블의 행을 순차적으로 확인하는 Full Table Scan이 발생할 수 있습니다.

인덱스가 있으면 `ordered_at` 값을 별도의 정렬된 검색 구조로 관리하여 원하는 위치를 빠르게 찾을 수 있습니다.

개념적으로:

```text
원본 orders

order_id | ordered_at
1        | 15:00
2        | 09:00
3        | 12:00
```

인덱스는 다음과 같이 관리될 수 있습니다.

```text
ordered_at index

09:00 → order 2
12:00 → order 3
15:00 → order 1
```

원본 데이터 자체를 정렬하는 것은 아닙니다.

출력 결과를 정렬하려면 별도로:

```sql
ORDER BY ordered_at ASC;
```

를 사용해야 합니다.

실제 인덱스 사용 여부는 `EXPLAIN`을 이용해 확인할 수 있습니다.

```sql
EXPLAIN
SELECT *
FROM orders
WHERE ordered_at >= '2026-09-21 00:00:00';
```

---

## 17. 실행 결과 확인

각 쿼리의 실행 결과는 `results/` 디렉토리에 저장합니다.

```text
results/
├── query01.png
├── query02.png
├── query03.png
├── ...
├── query15.png
└── query_results.txt
```

CLI 실행 결과 전체를 텍스트 파일로 저장할 수도 있습니다.

```bash
docker exec -i mysql-db \
mysql -u root -p1234 < queries.sql > results/query_results.txt 2>&1
```

최종 결과를 다시 만들 때는 데이터 상태를 초기화하기 위해 다음 순서로 실행합니다.

```bash
docker exec -i mysql-db mysql -u root -p1234 < schema.sql
```

```bash
docker exec -i mysql-db mysql -u root -p1234 < sample_data.sql
```

```bash
docker exec -i mysql-db \
mysql -u root -p1234 < queries.sql > results/query_results.txt 2>&1
```

---

## 18. SQL 파일 실행 방법

### 스키마 생성

```bash
docker exec -i mysql-db mysql -u root -p1234 < schema.sql
```

### 샘플 데이터 입력

```bash
docker exec -i mysql-db mysql -u root -p1234 < sample_data.sql
```

### 핵심 쿼리 실행

```bash
docker exec -i mysql-db mysql -u root -p1234 < queries.sql
```

---

## 19. 개발 중 발생한 문제와 해결 과정

### 문제 1. MySQL 설치 권한 문제

처음에는 Homebrew를 이용하여 macOS에 MySQL을 설치하려 했습니다.

하지만 다음 오류가 발생했습니다.

```text
Error: /usr/local/Cellar is not writable
```

현재 사용자에게 `/usr/local`에 대한 쓰기 권한이 없어서 설치할 수 없었습니다.

시스템 디렉토리 권한을 변경하는 대신 Docker를 사용하여 MySQL을 실행했습니다.

```text
macOS
  ↓
Docker
  ↓
MySQL 8.4
```

이를 통해 Host OS에 직접 MySQL을 설치하지 않고도 동일하게 SQL 실습을 진행할 수 있었습니다.

### 문제 2. 한글 데이터 입력 문제

처음 고객 데이터를 입력했을 때 이름의 한글이 정상적으로 저장되지 않았습니다.

컨테이너 내부에서 locale을 확인했습니다.

```bash
locale
```

결과:

```text
LANG=
LC_CTYPE="POSIX"
```

UTF-8 환경을 설정했습니다.

```bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
```

MySQL에서도 UTF-8 문자셋을 사용하도록 설정했습니다.

```sql
SET NAMES utf8mb4;
```

이후 한글 이름이 정상적으로 저장되었습니다.

### 문제 3. SQL 문법 오타

초기 테이블 생성 과정에서:

```text
ATUO_INCREMENT
```

라고 잘못 입력하여 SQL syntax error가 발생했습니다.

올바른 문법:

```text
AUTO_INCREMENT
```

으로 수정하여 해결했습니다.

또한:

```text
SHOW tabels;
decs customer;
```

등의 오타가 있었으며:

```sql
SHOW TABLES;
DESC customer;
```

로 수정했습니다.

### 문제 4. SQL 파일 실행 오류

처음 `schema.sql` 파일을 실행했을 때:

```text
ERROR 1064 (42000)
```

오류가 발생했습니다.

원인은 Markdown 코드 블록 표시인:

````text
```sql
````

문자열이 실제 `.sql` 파일 안에 포함되어 있었기 때문입니다.

SQL 파일에서는 Markdown 문법을 제거하고 SQL 문장과 SQL 주석만 남겨 해결했습니다.

### 문제 5. JOIN 결과의 정렬

여러 테이블을 JOIN한 결과가 `order_id` 순서대로 나오지 않았습니다.

SQL은 `ORDER BY`를 지정하지 않으면 조회 결과 순서를 보장하지 않는다는 것을 확인했습니다.

따라서:

```sql
ORDER BY o.order_id ASC;
```

를 추가하여 원하는 순서대로 출력했습니다.

### 문제 6. RIGHT JOIN 이후 데이터 누락

주문이 없는 고객까지 조회하기 위해 처음에는 `RIGHT JOIN`을 사용했습니다.

하지만 이후 `order_item`을 `INNER JOIN`하면서 주문이 없는 고객이 다시 결과에서 제외되었습니다.

기준 테이블을 `customer`로 두고 모든 연결에 `LEFT JOIN`을 사용했습니다.

```sql
FROM customer c

LEFT JOIN orders o
    ON c.customer_id = o.customer_id

LEFT JOIN order_item oi
    ON o.order_id = oi.order_id

LEFT JOIN menu m
    ON oi.menu_id = m.menu_id
```

그 결과 주문이 없는 고객도 유지되고 주문 정보는 `NULL`로 표시되었습니다.

---

## 20. 파일 구성

```text
database-mission/
├── sql/
│   ├── schema.sql
│   ├── sample_data.sql
│   └── queries.sql
│
├── results/
│   ├── query01.png
│   ├── query02.png
│   ├── ...
│   ├── query15.png
│   └── query_results.txt
│
├── erd/
│   └── cafe_erd.png
│
└── README.md
```

### schema.sql

데이터베이스와 4개 테이블의 구조를 생성합니다.

### sample_data.sql

각 테이블에 최소 10개의 샘플 데이터를 입력합니다.

### queries.sql

15개의 핵심 SQL 쿼리를 저장합니다.

### results/

각 SQL의 실행 결과를 저장합니다.

### erd/

테이블 관계를 나타내는 ERD 이미지를 저장합니다.

---

## 21. 학습 내용

이번 실습을 통해 단순히 SQL 문법을 사용하는 것뿐만 아니라, 데이터를 어떤 구조로 나누어 저장하고 서로 어떻게 연결하는지 이해할 수 있었습니다.

특히 다음 흐름을 직접 확인했습니다.

```text
테이블 설계
    ↓
PK 설정
    ↓
FK를 이용한 관계 구성
    ↓
샘플 데이터 입력
    ↓
JOIN을 이용한 관계 데이터 조회
    ↓
GROUP BY를 이용한 집계
    ↓
UPDATE / DELETE
    ↓
인덱스를 이용한 검색 최적화
```

PK는 각 데이터를 식별하고, FK는 서로 다른 테이블을 연결합니다.

이 관계를 기반으로 JOIN을 이용하면 분리되어 저장된 데이터를 필요한 형태로 다시 조회할 수 있으며, 제약조건을 이용하면 잘못된 데이터 입력도 방지할 수 있습니다.

또한 인덱스는 SQL 문법 자체를 변경하는 기능이 아니라, 특정 컬럼을 이용한 검색을 더 효율적으로 수행하기 위한 별도의 검색 구조라는 점을 확인했습니다.
