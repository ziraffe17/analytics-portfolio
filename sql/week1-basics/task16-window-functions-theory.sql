-- Task16: ウィンドウ関数基礎理論
-- 作成日: 2025-10-15
-- 学習内容: ウィンドウ関数の基本概念と構文

-- ==========================================
-- ウィンドウ関数 vs 通常の集約
-- ==========================================

-- 通常のGROUP BY（行が減る）
SELECT 
  department,
  AVG(salary) AS avg_salary
FROM employees
GROUP BY department;

-- ウィンドウ関数（行数は変わらない）
SELECT 
  name,
  department,
  salary,
  AVG(salary) OVER (PARTITION BY department) AS dept_avg_salary
FROM employees;

-- ==========================================
-- 1. ランキング系関数
-- ==========================================

-- ROW_NUMBER: 連番を付与（同点でも異なる番号）
SELECT 
  name,
  score,
  ROW_NUMBER() OVER (ORDER BY score DESC) AS row_num
FROM students;

-- RANK: 同順位を考慮（順位が飛ぶ）
-- 結果例: 1, 2, 2, 4（3がない）
SELECT 
  name,
  score,
  RANK() OVER (ORDER BY score DESC) AS rank
FROM students;

-- DENSE_RANK: 同順位を考慮（順位が飛ばない）
-- 結果例: 1, 2, 2, 3（3がある）
SELECT 
  name,
  score,
  DENSE_RANK() OVER (ORDER BY score DESC) AS dense_rank
FROM students;

-- ==========================================
-- 2. 集約系ウィンドウ関数
-- ==========================================

-- 累積合計
SELECT 
  date,
  sales,
  SUM(sales) OVER (ORDER BY date) AS cumulative_sales
FROM daily_sales;

-- 移動平均（3日間）
SELECT 
  date,
  sales,
  AVG(sales) OVER (
    ORDER BY date 
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS moving_avg_3days
FROM daily_sales;

-- 累積カウント
SELECT 
  date,
  customer_id,
  COUNT(*) OVER (ORDER BY date) AS cumulative_customers
FROM orders;

-- ==========================================
-- 3. 位置参照系関数
-- ==========================================

-- LAG: 前の行を参照
SELECT 
  date,
  sales,
  LAG(sales, 1) OVER (ORDER BY date) AS prev_day_sales,
  sales - LAG(sales, 1) OVER (ORDER BY date) AS daily_change
FROM daily_sales;

-- LEAD: 次の行を参照
SELECT 
  date,
  sales,
  LEAD(sales, 1) OVER (ORDER BY date) AS next_day_sales,
  LEAD(sales, 1) OVER (ORDER BY date) - sales AS next_day_change
FROM daily_sales;

-- 複数行前を参照（1週間前との比較）
SELECT 
  date,
  sales,
  LAG(sales, 7) OVER (ORDER BY date) AS sales_week_ago,
  sales - LAG(sales, 7) OVER (ORDER BY date) AS week_over_week_change
FROM daily_sales;

-- ==========================================
-- 4. PARTITION BY の使い方
-- ==========================================

-- 部門ごとにランキング
SELECT 
  name,
  department,
  salary,
  RANK() OVER (
    PARTITION BY department
    ORDER BY salary DESC
  ) AS dept_rank
FROM employees;

-- 部門ごとの累積合計
SELECT 
  date,
  department,
  sales,
  SUM(sales) OVER (
    PARTITION BY department
    ORDER BY date
  ) AS dept_cumulative_sales
FROM daily_sales;

-- 部門ごとの前日比較
SELECT 
  date,
  department,
  sales,
  LAG(sales, 1) OVER (
    PARTITION BY department
    ORDER BY date
  ) AS prev_day_sales_in_dept
FROM daily_sales;

-- ==========================================
-- 5. 実務での活用例
-- ==========================================

-- 例1: 売上トップ3を抽出
WITH ranked_sales AS (
  SELECT 
    product_name,
    sales,
    RANK() OVER (ORDER BY sales DESC) AS rank
  FROM products
)
SELECT 
  product_name,
  sales,
  rank
FROM ranked_sales
WHERE rank <= 3;

-- 例2: 前年同月比較
SELECT 
  year_month,
  sales,
  LAG(sales, 12) OVER (ORDER BY year_month) AS sales_last_year,
  sales - LAG(sales, 12) OVER (ORDER BY year_month) AS yoy_diff,
  ROUND(
    (sales / LAG(sales, 12) OVER (ORDER BY year_month) - 1) * 100, 
    1
  ) AS yoy_growth_rate
FROM monthly_sales;

-- 例3: 部門内の給与偏差
SELECT 
  name,
  department,
  salary,
  AVG(salary) OVER (PARTITION BY department) AS dept_avg,
  salary - AVG(salary) OVER (PARTITION BY department) AS diff_from_avg,
  ROUND(
    (salary / AVG(salary) OVER (PARTITION BY department) - 1) * 100,
    1
  ) AS pct_diff_from_avg
FROM employees;

-- 例4: 顧客の購買履歴分析
SELECT 
  customer_id,
  order_date,
  order_amount,
  ROW_NUMBER() OVER (
    PARTITION BY customer_id 
    ORDER BY order_date
  ) AS purchase_number,
  SUM(order_amount) OVER (
    PARTITION BY customer_id 
    ORDER BY order_date
  ) AS lifetime_value,
  LAG(order_date, 1) OVER (
    PARTITION BY customer_id 
    ORDER BY order_date
  ) AS prev_order_date,
  DATE_DIFF(
    order_date,
    LAG(order_date, 1) OVER (
      PARTITION BY customer_id 
      ORDER BY order_date
    ),
    DAY
  ) AS days_since_last_order
FROM orders;

-- 例5: 在庫の移動平均（30日間）
SELECT 
  date,
  product_id,
  stock_quantity,
  AVG(stock_quantity) OVER (
    PARTITION BY product_id
    ORDER BY date
    ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
  ) AS moving_avg_30days,
  MAX(stock_quantity) OVER (
    PARTITION BY product_id
    ORDER BY date
    ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
  ) AS max_stock_30days,
  MIN(stock_quantity) OVER (
    PARTITION BY product_id
    ORDER BY date
    ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
  ) AS min_stock_30days
FROM inventory;

-- ==========================================
-- 6. ROWS BETWEEN 句の詳細
-- ==========================================

-- 直前2行から現在行まで（3行の範囲）
SELECT 
  date,
  sales,
  AVG(sales) OVER (
    ORDER BY date
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS avg_3rows
FROM daily_sales;

-- 現在行から次の2行まで（3行の範囲）
SELECT 
  date,
  sales,
  AVG(sales) OVER (
    ORDER BY date
    ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING
  ) AS avg_next_3rows
FROM daily_sales;

-- 前後1行ずつ（3行の範囲）
SELECT 
  date,
  sales,
  AVG(sales) OVER (
    ORDER BY date
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
  ) AS avg_surrounding_3rows
FROM daily_sales;

-- 最初から現在行まで（累積）
SELECT 
  date,
  sales,
  SUM(sales) OVER (
    ORDER BY date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_sum
FROM daily_sales;

-- ==========================================
-- まとめ: ウィンドウ関数の使い分け
-- ==========================================

/*
【ランキング系】
- ROW_NUMBER: 必ず一意の番号が必要な場合
- RANK: 同順位を認め、次の順位を飛ばしたい場合
- DENSE_RANK: 同順位を認め、次の順位を飛ばしたくない場合

【集約系】
- SUM() OVER: 累積合計、部門別合計
- AVG() OVER: 移動平均、部門別平均
- COUNT() OVER: 累積カウント

【位置参照系】
- LAG: 前日比較、前年比較
- LEAD: 翌日予測、将来予測

【PARTITION BY】
- グループごとに独立して計算
- 部門別、商品別、顧客別など

【ORDER BY】
- 計算の順序を決める
- 日付順、金額順など

【ROWS BETWEEN】
- 計算範囲を指定
- 移動平均、累積合計など
*/