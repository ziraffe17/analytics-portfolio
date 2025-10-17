-- Task17: ウィンドウ関数基礎実践
-- 作成日: 2025-10-15
-- 更新日: 2025-10-17（データの粒度問題を修正）
-- 学習内容: BigQueryでウィンドウ関数を実際に実行

-- ==========================================
-- 重要: データの粒度に注意
-- ==========================================
-- usa_names テーブルは州ごとのデータ
-- 年ごとの分析をする場合は、まずGROUP BYで集計が必要

/*
テーブル構造:
state | year | name   | gender | number
AK    | 2020 | Emma   | F      | 100
AL    | 2020 | Emma   | F      | 200
...

年ごとの集計が必要な理由:
- 同じ年に複数の州のデータがある
- 全米での合計を見るにはGROUP BYが必要
*/

-- ==========================================
-- 1. ランキング系の実践
-- ==========================================

-- 性別ごとのトップ5（CTE使用）
WITH ranked_names AS (
  SELECT 
    name,
    gender,
    SUM(number) AS total_count,
    RANK() OVER (
      PARTITION BY gender
      ORDER BY SUM(number) DESC
    ) AS gender_rank
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  WHERE year = 2020
  GROUP BY name, gender
)
SELECT 
  name,
  gender,
  total_count,
  gender_rank
FROM ranked_names
WHERE gender_rank <= 5
ORDER BY gender, gender_rank;

-- ==========================================
-- 2. 累積合計と移動平均
-- ==========================================

-- 年次累積人数（正しい方法）
WITH yearly_totals AS (
  SELECT 
    year,
    SUM(number) AS total_count
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  WHERE name = 'Emma' 
    AND gender = 'F'
    AND year >= 2000
  GROUP BY year
)
SELECT 
  year,
  total_count,
  SUM(total_count) OVER (ORDER BY year) AS cumulative_total
FROM yearly_totals
ORDER BY year;

-- 3年移動平均（修正版）
WITH yearly_totals AS (
  SELECT 
    year,
    SUM(number) AS total_count
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  WHERE name = 'Emma' 
    AND gender = 'F'
    AND year BETWEEN 2010 AND 2020
  GROUP BY year
)
SELECT 
  year,
  total_count,
  ROUND(AVG(total_count) OVER (
    ORDER BY year
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ), 0) AS moving_avg_3years
FROM yearly_totals
ORDER BY year;

-- ==========================================
-- 3. 前年比較（LAG関数 - 修正版）
-- ==========================================

-- 前年比較と成長率
WITH yearly_totals AS (
  SELECT 
    year,
    SUM(number) AS total_count
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  WHERE name = 'Emma' 
    AND gender = 'F'
    AND year BETWEEN 2015 AND 2020
  GROUP BY year
)
SELECT 
  year,
  total_count AS current_year,
  LAG(total_count, 1) OVER (ORDER BY year) AS prev_year,
  total_count - LAG(total_count, 1) OVER (ORDER BY year) AS yoy_change,
  ROUND(
    (total_count - LAG(total_count, 1) OVER (ORDER BY year)) / 
    LAG(total_count, 1) OVER (ORDER BY year) * 100,
    1
  ) AS yoy_growth_rate
FROM yearly_totals
ORDER BY year;

-- ==========================================
-- 4. 実務パターン - 顧客分析
-- ==========================================

-- 顧客の購買履歴分析（サンプルデータ）
WITH orders AS (
  SELECT 1 AS customer_id, DATE('2025-01-05') AS order_date, 100 AS amount
  UNION ALL SELECT 1, DATE('2025-02-10'), 150
  UNION ALL SELECT 1, DATE('2025-03-15'), 200
  UNION ALL SELECT 2, DATE('2025-01-20'), 80
  UNION ALL SELECT 2, DATE('2025-02-25'), 120
  UNION ALL SELECT 3, DATE('2025-01-10'), 300
)
SELECT 
  customer_id,
  order_date,
  amount,
  -- 購買回数
  ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY order_date
  ) AS purchase_number,
  -- 累積購買額（LTV）
  SUM(amount) OVER (
    PARTITION BY customer_id
    ORDER BY order_date
  ) AS lifetime_value,
  -- 前回からの日数
  DATE_DIFF(
    order_date,
    LAG(order_date, 1) OVER (
      PARTITION BY customer_id
      ORDER BY order_date
    ),
    DAY
  ) AS days_since_last_order,
  -- 購買額の変化
  amount - LAG(amount, 1) OVER (
    PARTITION BY customer_id
    ORDER BY order_date
  ) AS amount_change
FROM orders
ORDER BY customer_id, order_date;

-- ==========================================
-- 5. 複雑な分析（年ごとの集計 + ランキング）
-- ==========================================

-- トップ5の名前の推移分析（修正版）
WITH top5_2020 AS (
  -- 2020年のトップ5を特定（州ごとを集計）
  SELECT name
  FROM (
    SELECT 
      name,
      SUM(number) AS total_count
    FROM `bigquery-public-data.usa_names.usa_1910_current`
    WHERE year = 2020 AND gender = 'F'
    GROUP BY name
  )
  ORDER BY total_count DESC
  LIMIT 5
),
yearly_data AS (
  -- 年ごとに集計（これが重要！）
  SELECT 
    name,
    year,
    SUM(number) AS total_count
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  WHERE year BETWEEN 2010 AND 2020
    AND gender = 'F'
    AND name IN (SELECT name FROM top5_2020)
  GROUP BY name, year
)
SELECT 
  name,
  year,
  total_count,
  -- 前年比較
  LAG(total_count, 1) OVER (
    PARTITION BY name
    ORDER BY year
  ) AS prev_year_count,
  total_count - LAG(total_count, 1) OVER (
    PARTITION BY name
    ORDER BY year
  ) AS yoy_change,
  -- その年の全体ランキング
  RANK() OVER (
    PARTITION BY year
    ORDER BY total_count DESC
  ) AS year_rank
FROM yearly_data
ORDER BY name, year;

-- ==========================================
-- 6. 比較: ランキング関数の違い
-- ==========================================

-- ROW_NUMBER vs RANK vs DENSE_RANK の違いを確認
WITH sample_data AS (
  SELECT 'Alice' AS name, 95 AS score
  UNION ALL SELECT 'Bob', 90
  UNION ALL SELECT 'Carol', 90
  UNION ALL SELECT 'David', 85
  UNION ALL SELECT 'Eve', 85
  UNION ALL SELECT 'Frank', 80
)
SELECT 
  name,
  score,
  ROW_NUMBER() OVER (ORDER BY score DESC) AS row_number,
  RANK() OVER (ORDER BY score DESC) AS rank,
  DENSE_RANK() OVER (ORDER BY score DESC) AS dense_rank
FROM sample_data
ORDER BY score DESC;

/*
結果:
name  | score | row_number | rank | dense_rank
Alice | 95    | 1          | 1    | 1
Bob   | 90    | 2          | 2    | 2
Carol | 90    | 3          | 2    | 2
David | 85    | 4          | 4    | 3  ← RANKは順位が飛ぶ
Eve   | 85    | 5          | 4    | 3
Frank | 80    | 6          | 6    | 4
*/

-- ==========================================
-- 7. 実務パターン: 部門ごとの分析
-- ==========================================

-- サンプルデータで部門別分析
WITH employees AS (
  SELECT 'Alice' AS name, '営業部' AS dept, 500000 AS salary
  UNION ALL SELECT 'Bob', '営業部', 450000
  UNION ALL SELECT 'Carol', '営業部', 400000
  UNION ALL SELECT 'David', '開発部', 600000
  UNION ALL SELECT 'Eve', '開発部', 550000
  UNION ALL SELECT 'Frank', '開発部', 500000
)
SELECT 
  name,
  dept,
  salary,
  -- 部門内ランキング
  RANK() OVER (
    PARTITION BY dept
    ORDER BY salary DESC
  ) AS dept_rank,
  -- 部門平均との差
  salary - AVG(salary) OVER (PARTITION BY dept) AS diff_from_avg,
  -- 部門内の給与比率
  ROUND(
    salary / SUM(salary) OVER (PARTITION BY dept) * 100,
    1
  ) AS pct_of_dept_total
FROM employees
ORDER BY dept, salary DESC;

-- ==========================================
-- 学んだ教訓
-- ==========================================

/*
1. データの粒度を必ず確認する
   - テーブルの構造を理解してから分析
   - usa_names は州ごとのデータだった

2. ウィンドウ関数の前に適切な集計
   - 年ごとの分析なら、まずGROUP BY year
   - CTEを使うと見やすい

3. 間違った結果の見分け方
   - 同じ年に複数行 → 粒度が間違っている
   - 同じ累積値が続く → GROUP BYが必要

4. 実務での注意点
   - データソースのドキュメントを読む
   - サンプルデータで確認してから本番クエリ
   - 予想と違う結果が出たら粒度を疑う

5. ウィンドウ関数のベストプラクティス
   - PARTITION BYで適切にグループ分け
   - ORDER BYで正しい順序を指定
   - LAG/LEADは前年比較に便利
   - CTEで段階的にクエリを構築

6. パフォーマンス
   - ウィンドウ関数はサブクエリより高速
   - GROUP BYを先に実行してからウィンドウ関数
   - 不要な列はSELECTしない
*/