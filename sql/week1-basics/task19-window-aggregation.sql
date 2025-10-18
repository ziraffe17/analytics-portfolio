-- Task19: ウィンドウ関数応用集約
-- 作成日: 2025-10-16
-- 学習内容: ROWS BETWEEN句を使った高度な集約

-- ==========================================
-- 1. 移動平均（3年・5年・7年）
-- ==========================================

WITH yearly_data AS (
  SELECT 
    year,
    SUM(number) AS total_count
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  WHERE name = 'Emma' 
    AND gender = 'F'
    AND year BETWEEN 2000 AND 2020
  GROUP BY year
)
SELECT 
  year,
  total_count,
  ROUND(AVG(total_count) OVER (
    ORDER BY year
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ), 0) AS moving_avg_3years,
  ROUND(AVG(total_count) OVER (
    ORDER BY year
    ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
  ), 0) AS moving_avg_5years,
  ROUND(AVG(total_count) OVER (
    ORDER BY year
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ), 0) AS moving_avg_7years
FROM yearly_data
ORDER BY year;

-- ==========================================
-- 2. 中央値の移動平均
-- ==========================================

WITH yearly_data AS (
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
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
  ), 0) AS centered_moving_avg,
  ROUND(AVG(total_count) OVER (
    ORDER BY year
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ), 0) AS backward_moving_avg
FROM yearly_data
ORDER BY year;

-- ==========================================
-- 3. 累積統計
-- ==========================================

WITH yearly_data AS (
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
  total_count,
  SUM(total_count) OVER (
    ORDER BY year
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_sum,
  ROUND(AVG(total_count) OVER (
    ORDER BY year
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ), 0) AS cumulative_avg,
  MAX(total_count) OVER (
    ORDER BY year
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS max_so_far,
  MIN(total_count) OVER (
    ORDER BY year
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS min_so_far
FROM yearly_data
ORDER BY year;

-- ==========================================
-- 4. ランニングトータルとシェア
-- ==========================================

WITH yearly_data AS (
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
  total_count,
  SUM(total_count) OVER (ORDER BY year) AS running_total,
  SUM(total_count) OVER () AS grand_total,
  ROUND(
    SUM(total_count) OVER (ORDER BY year) / 
    SUM(total_count) OVER () * 100,
    1
  ) AS cumulative_share_pct,
  ROUND(
    total_count / SUM(total_count) OVER () * 100,
    1
  ) AS year_share_pct
FROM yearly_data
ORDER BY year;

-- ==========================================
-- 5. 変動係数（volatility）
-- ==========================================

WITH yearly_data AS (
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
  ), 0) AS moving_avg_3y,
  ROUND(STDDEV(total_count) OVER (
    ORDER BY year
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ), 0) AS stddev_3y,
  ROUND(
    STDDEV(total_count) OVER (
      ORDER BY year
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) / 
    AVG(total_count) OVER (
      ORDER BY year
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) * 100,
    1
  ) AS coefficient_of_variation
FROM yearly_data
ORDER BY year;

-- ==========================================
-- 6. 複数名前の比較（PARTITION BY）
-- ==========================================

WITH top3_names AS (
  SELECT name
  FROM (
    SELECT 
      name,
      SUM(number) AS total
    FROM `bigquery-public-data.usa_names.usa_1910_current`
    WHERE year = 2020 AND gender = 'F'
    GROUP BY name
  )
  ORDER BY total DESC
  LIMIT 3
),
yearly_data AS (
  SELECT 
    name,
    year,
    SUM(number) AS total_count
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  WHERE name IN (SELECT name FROM top3_names)
    AND gender = 'F'
    AND year BETWEEN 2015 AND 2020
  GROUP BY name, year
)
SELECT 
  name,
  year,
  total_count,
  ROUND(AVG(total_count) OVER (
    PARTITION BY name
    ORDER BY year
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ), 0) AS moving_avg_3y,
  SUM(total_count) OVER (
    PARTITION BY name
    ORDER BY year
  ) AS cumulative_total,
  RANK() OVER (
    PARTITION BY year
    ORDER BY total_count DESC
  ) AS rank_in_year
FROM yearly_data
ORDER BY name, year;

-- ==========================================
-- 7. 実務パターン - 目標達成率
-- ==========================================

WITH yearly_data AS (
  SELECT 
    year,
    SUM(number) AS actual_count
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  WHERE name = 'Emma' 
    AND gender = 'F'
    AND year BETWEEN 2015 AND 2020
  GROUP BY year
),
with_target AS (
  SELECT 
    year,
    actual_count,
    LAG(actual_count, 1) OVER (ORDER BY year) AS target,
    ROUND(AVG(actual_count) OVER (
      ORDER BY year
      ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
    ), 0) AS target_moving_avg
  FROM yearly_data
)
SELECT 
  year,
  actual_count,
  target,
  actual_count - target AS vs_target,
  ROUND((actual_count / target - 1) * 100, 1) AS vs_target_pct,
  target_moving_avg,
  actual_count - target_moving_avg AS vs_moving_avg,
  ROUND((actual_count / target_moving_avg - 1) * 100, 1) AS vs_moving_avg_pct
FROM with_target
WHERE target IS NOT NULL
ORDER BY year;

-- ==========================================
-- まとめ: ROWS BETWEEN句のパターン
-- ==========================================

/*
【ROWS BETWEENの指定方法】
- UNBOUNDED PRECEDING: 最初の行
- n PRECEDING: n行前
- CURRENT ROW: 現在の行
- n FOLLOWING: n行後
- UNBOUNDED FOLLOWING: 最後の行

【よく使うパターン】
1. 移動平均（3期）
   ROWS BETWEEN 2 PRECEDING AND CURRENT ROW

2. 中央移動平均（前後含む）
   ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING

3. 累積合計
   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

4. 将来を含む集計
   ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING

【実務での活用】
- トレンド分析（移動平均）
- KPIの累積進捗
- 目標達成率の計算
- ボラティリティ分析
- シェア分析
*/