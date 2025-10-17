-- Task15: BigQueryで簡単なクエリ実行
-- 作成日: 2025-10-15
-- 更新日: 2025-10-15（州ごとのデータ問題を修正）
-- 学習内容: BigQueryの基本構文

-- ==========================================
-- 1. 基本的なSELECT
-- ==========================================

-- 現在の日時
SELECT 
  CURRENT_DATE() AS today,
  CURRENT_TIMESTAMP() AS now,
  CURRENT_TIME() AS current_time;

-- 計算
SELECT 
  100 AS original_price,
  100 * 1.08 AS price_with_tax,
  ROUND(100 * 1.08, 0) AS rounded_price;

-- 文字列操作
SELECT 
  CONCAT('Hello', ' ', 'BigQuery') AS combined,
  UPPER('Hello BigQuery') AS uppercase,
  LENGTH('Hello BigQuery') AS string_length;

-- 日付操作
SELECT 
  CURRENT_DATE() AS today,
  DATE_ADD(CURRENT_DATE(), INTERVAL 7 DAY) AS next_week,
  DATE_DIFF(CURRENT_DATE(), DATE('2025-01-01'), DAY) AS days_from_new_year;

-- ==========================================
-- 2. 公開データセットの利用
-- ==========================================

-- 人気の名前トップ10（2020年）
SELECT 
  name,
  gender,
  SUM(number) AS total_count
FROM `bigquery-public-data.usa_names.usa_1910_current`
WHERE year = 2020
GROUP BY name, gender
ORDER BY total_count DESC
LIMIT 10;

-- ==========================================
-- 3. WHERE句とフィルタリング
-- ==========================================

-- 複数条件でフィルタリング（修正版）
-- 注意: usa_namesテーブルは州ごとのデータなのでGROUP BYが必要
SELECT 
  name,
  SUM(number) AS total_count
FROM `bigquery-public-data.usa_names.usa_1910_current`
WHERE year = 2020
  AND gender = 'M'
GROUP BY name
HAVING SUM(number) >= 1000
ORDER BY total_count DESC
LIMIT 20;

-- LIKE句で前方一致検索（修正版）
SELECT 
  name,
  gender,
  SUM(number) AS total_count
FROM `bigquery-public-data.usa_names.usa_1910_current`
WHERE year = 2020
  AND name LIKE 'J%'
GROUP BY name, gender
HAVING SUM(number) >= 500
ORDER BY total_count DESC
LIMIT 15;

-- ==========================================
-- 4. GROUP BYと集約関数
-- ==========================================

-- 性別ごとの統計
SELECT 
  gender,
  COUNT(DISTINCT name) AS unique_names,
  SUM(number) AS total_births,
  AVG(number) AS avg_count
FROM `bigquery-public-data.usa_names.usa_1910_current`
WHERE year = 2020
GROUP BY gender;

-- 年代別の集計（CASE式）
SELECT 
  CASE 
    WHEN year BETWEEN 1910 AND 1959 THEN '1910-1959'
    WHEN year BETWEEN 1960 AND 1989 THEN '1960-1989'
    WHEN year BETWEEN 1990 AND 2009 THEN '1990-2009'
    ELSE '2010以降'
  END AS era,
  COUNT(DISTINCT name) AS unique_names,
  SUM(number) AS total_people
FROM `bigquery-public-data.usa_names.usa_1910_current`
GROUP BY era
ORDER BY era;

-- ==========================================
-- 参考: 州ごとのデータを確認したい場合
-- ==========================================

-- 州別のデータを見る例
SELECT 
  state,
  name,
  number
FROM `bigquery-public-data.usa_names.usa_1910_current`
WHERE year = 2020
  AND name = 'Liam'
  AND gender = 'M'
ORDER BY number DESC
LIMIT 10;

-- ==========================================
-- 学んだ教訓
-- ==========================================

/*
usa_namesテーブルは州ごとのデータ構造

テーブル構造:
state | year | name | gender | number
CA    | 2020 | Liam | M      | 2500
TX    | 2020 | Liam | M      | 1800
...

全米での集計を見る場合:
→ GROUP BY name が必要
→ SUM(number) で州ごとの合計を出す

この教訓は Task17 で詳しく学習
*/