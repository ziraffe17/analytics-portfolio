-- Task18: LAG/LEAD関数実践
-- 作成日: 2025-10-16
-- 学習内容: LAG/LEAD関数を使った時系列分析

-- ==========================================
-- 1. 基本: 前年比較
-- ==========================================

-- 前年比較と成長率
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
  LAG(total_count, 1) OVER (ORDER BY year) AS prev_year,
  total_count - LAG(total_count, 1) OVER (ORDER BY year) AS yoy_change,
  ROUND(
    (total_count - LAG(total_count, 1) OVER (ORDER BY year)) / 
    LAG(total_count, 1) OVER (ORDER BY year) * 100,
    1
  ) AS yoy_growth_pct
FROM yearly_data
ORDER BY year;

-- ==========================================
-- 2. 複数年前との比較
-- ==========================================

-- 1年前、2年前、3年前との比較
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
  LAG(total_count, 1) OVER (ORDER BY year) AS year_minus_1,
  LAG(total_count, 2) OVER (ORDER BY year) AS year_minus_2,
  LAG(total_count, 3) OVER (ORDER BY year) AS year_minus_3,
  total_count - LAG(total_count, 3) OVER (ORDER BY year) AS change_3years,
  ROUND(
    (total_count - LAG(total_count, 3) OVER (ORDER BY year)) / 
    LAG(total_count, 3) OVER (ORDER BY year) * 100,
    1
  ) AS growth_3years_pct
FROM yearly_data
ORDER BY year;

-- ==========================================
-- 3. トレンド判定
-- ==========================================

-- 3年連続の増減トレンドを判定
WITH yearly_data AS (
  SELECT 
    year,
    SUM(number) AS total_count
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  WHERE name = 'Emma' 
    AND gender = 'F'
    AND year BETWEEN 2010 AND 2020
  GROUP BY year
),
with_lags AS (
  SELECT 
    year,
    total_count,
    LAG(total_count, 1) OVER (ORDER BY year) AS prev_1,
    LAG(total_count, 2) OVER (ORDER BY year) AS prev_2
  FROM yearly_data
)
SELECT 
  year,
  total_count,
  prev_1,
  prev_2,
  CASE 
    WHEN total_count > prev_1 AND prev_1 > prev_2 THEN '上昇トレンド'
    WHEN total_count < prev_1 AND prev_1 < prev_2 THEN '下降トレンド'
    WHEN total_count > prev_1 AND prev_1 < prev_2 THEN '反転（上昇）'
    WHEN total_count < prev_1 AND prev_1 > prev_2 THEN '反転（下降）'
    ELSE '横ばい'
  END AS trend
FROM with_lags
WHERE prev_2 IS NOT NULL
ORDER BY year;

-- ==========================================
-- 4. LEAD: 次の年との比較
-- ==========================================

-- 次の年との比較（将来予測）
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
  LEAD(total_count, 1) OVER (ORDER BY year) AS next_year,
  LEAD(total_count, 1) OVER (ORDER BY year) - total_count AS next_year_change,
  CASE 
    WHEN LEAD(total_count, 1) OVER (ORDER BY year) > total_count THEN '増加予定'
    WHEN LEAD(total_count, 1) OVER (ORDER BY year) < total_count THEN '減少予定'
    ELSE NULL
  END AS forecast
FROM yearly_data
ORDER BY year;

-- ==========================================
-- 5. ピークからの変化率
-- ==========================================

-- 過去最高値からの変化率
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
  MAX(total_count) OVER () AS peak_count,
  MAX(total_count) OVER (ORDER BY year) AS peak_so_far,
  total_count - MAX(total_count) OVER () AS diff_from_peak,
  ROUND(
    (total_count / MAX(total_count) OVER () - 1) * 100,
    1
  ) AS pct_from_peak,
  CASE 
    WHEN total_count = MAX(total_count) OVER (ORDER BY year) THEN '新記録'
    ELSE ''
  END AS is_peak
FROM yearly_data
ORDER BY year;

-- ==========================================
-- 6. 複数の名前を比較（PARTITION BY使用）
-- ==========================================

-- トップ3の名前の前年比較
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
    AND year BETWEEN 2018 AND 2020
  GROUP BY name, year
)
SELECT 
  name,
  year,
  total_count,
  LAG(total_count, 1) OVER (PARTITION BY name ORDER BY year) AS prev_year,
  total_count - LAG(total_count, 1) OVER (PARTITION BY name ORDER BY year) AS yoy_change,
  ROUND(
    (total_count - LAG(total_count, 1) OVER (PARTITION BY name ORDER BY year)) / 
    LAG(total_count, 1) OVER (PARTITION BY name ORDER BY year) * 100,
    1
  ) AS yoy_growth_pct
FROM yearly_data
ORDER BY name, year;

-- ==========================================
-- まとめ: LAG/LEADの使い分け
-- ==========================================

/*
【LAG - 過去を見る】
- 前年比、前月比、前日比
- 成長率の計算
- トレンド分析

【LEAD - 未来を見る】
- 将来予測との比較
- 次期計画との差異分析

【実務でのポイント】
1. PARTITION BYで名前・商品・顧客ごとに独立して計算
2. オフセットで何年前/後を指定
3. デフォルト値でNULLを避ける
4. CTEで段階的に構築

【注意点】
- GROUP BYで集計してから使う
- ORDER BYで正しい順序を指定
- PARTITION BYで適切にグループ分け
*/