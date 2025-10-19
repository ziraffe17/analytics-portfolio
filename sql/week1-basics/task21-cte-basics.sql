-- Task21: CTE基本構文学習（実データ版）
-- 作成日: 2025-10-18
-- データ: mystic-now-474722-r4.education_analytics.raw_student_performance

-- =============================================================================
-- 例1: 数学の平均点以上の学生を抽出
-- =============================================================================

-- CTEなし（サブクエリ版 - 読みにくい）
SELECT 
    gender,
    math_score,
    reading_score,
    (SELECT AVG(math_score) 
     FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`) AS average_math
FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
WHERE math_score >= (
    SELECT AVG(math_score) 
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
)
LIMIT 10;

-- CTEあり（読みやすい）
WITH avg_math AS (
    SELECT AVG(math_score) AS average_math
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
)
SELECT 
    s.gender,
    s.math_score,
    s.reading_score,
    a.average_math,
    s.math_score - a.average_math AS difference_from_avg
FROM `mystic-now-474722-r4.education_analytics.raw_student_performance` s
CROSS JOIN avg_math a
WHERE s.math_score >= a.average_math
ORDER BY s.math_score DESC
LIMIT 10;

-- 学習ポイント:
-- - CTEは WITH句で定義する一時テーブル
-- - CROSS JOINで全学生に平均点を追加
-- - 同じ計算を何度も書かなくて良い


-- =============================================================================
-- 例2: テスト準備コースを受けた学生の成績分析
-- =============================================================================

-- CTEで対象を絞り込む
WITH prep_course_students AS (
    SELECT 
        gender,
        math_score,
        reading_score,
        writing_score
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
    WHERE test_preparation_course = 'completed'
)
SELECT 
    gender,
    COUNT(*) AS student_count,
    ROUND(AVG(math_score), 2) AS avg_math,
    ROUND(AVG(reading_score), 2) AS avg_reading,
    ROUND(AVG(writing_score), 2) AS avg_writing,
    ROUND((AVG(math_score) + AVG(reading_score) + AVG(writing_score)) / 3, 2) AS avg_total
FROM prep_course_students
GROUP BY gender
ORDER BY avg_total DESC;

-- 学習ポイント:
-- - CTEでデータを絞り込んでから集計
-- - メインクエリがシンプルになる


-- =============================================================================
-- 例3: 性別ごとの平均と個人スコアを比較
-- =============================================================================

WITH gender_averages AS (
    SELECT 
        gender,
        ROUND(AVG(math_score), 2) AS avg_math,
        ROUND(AVG(reading_score), 2) AS avg_reading,
        ROUND(AVG(writing_score), 2) AS avg_writing
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
    GROUP BY gender
)
SELECT 
    s.gender,
    s.math_score,
    s.reading_score,
    s.writing_score,
    g.avg_math AS gender_avg_math,
    g.avg_reading AS gender_avg_reading,
    s.math_score - g.avg_math AS math_diff,
    s.reading_score - g.avg_reading AS reading_diff
FROM `mystic-now-474722-r4.education_analytics.raw_student_performance` s
INNER JOIN gender_averages g ON s.gender = g.gender
WHERE s.math_score > g.avg_math
  AND s.reading_score > g.avg_reading
ORDER BY math_diff DESC
LIMIT 10;

-- 学習ポイント:
-- - CTEで集約した結果を元テーブルとJOIN
-- - 個人スコアとグループ平均を比較できる


-- =============================================================================
-- 例4: 親の学歴別の成績ランキング
-- =============================================================================

WITH education_stats AS (
    SELECT 
        parental_level_of_education,
        COUNT(*) AS student_count,
        ROUND(AVG(math_score), 2) AS avg_math,
        ROUND(AVG(reading_score), 2) AS avg_reading,
        ROUND(AVG(writing_score), 2) AS avg_writing
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
    GROUP BY parental_level_of_education
)
SELECT 
    parental_level_of_education,
    student_count,
    avg_math,
    avg_reading,
    avg_writing,
    ROUND((avg_math + avg_reading + avg_writing) / 3, 2) AS avg_total,
    RANK() OVER (ORDER BY (avg_math + avg_reading + avg_writing) / 3 DESC) AS rank_by_total
FROM education_stats
ORDER BY rank_by_total;

-- 学習ポイント:
-- - CTEで集約してからランキング
-- - ウィンドウ関数と組み合わせて使える


-- =============================================================================
-- 練習問題
-- =============================================================================

-- Q1: 読解スコアが80点以上の学生の人種別分布を調べる
-- ヒント: CTEで reading_score >= 80 で絞り込んでから GROUP BY race_ethnicity

WITH high_readers AS (
  SELECT
      gender,
      race_ethnicity,
      reading_score
FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
WHERE reading_score >= 80
)
SELECT
    race_ethnicity,
    COUNT(*) AS student_count,
    ROUND(AVG(reading_score), 2) AS avg_reading
FROM high_readers
GROUP BY race_ethnicity
ORDER BY student_count DESC;

-- Q2: 昼食タイプ別の平均スコアを計算し、全体平均と比較する
-- ヒント: 2つのCTEを作る（lunch別の平均 + 全体平均）

WITH lunch_averages AS (
  SELECT
      lunch,
      ROUND(AVG(math_score), 2) AS avg_math,
      ROUND(AVG(reading_score), 2) AS avg_reading,
      ROUND(AVG(writing_score), 2) AS avg_writing
  FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
  GROUP BY lunch
),
overall_averages AS (
  SELECT
      ROUND(AVG(math_score), 2) AS avg_math,
      ROUND(AVG(reading_score), 2) AS avg_reading,
      ROUND(AVG(writing_score), 2) AS avg_writing
  FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
)
SELECT
    l.lunch,
    l.avg_math,
    l.avg_reading,
    l.avg_writing,
    o.avg_math AS overall_avg_math,
    o.avg_reading AS overall_avg_reading,
    o.avg_writing AS overall_avg_writing
FROM lunch_averages l
CROSS JOIN overall_averages o;

-- Q3: 3科目すべてで70点以上の学生を抽出し、性別ごとに集計する
-- ヒント: CTEのWHERE句で3つの条件をANDで結合
WITH high_achievers AS (
    SELECT 
        gender,
        math_score,
        reading_score,
        writing_score
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
    WHERE math_score >= 70
      AND reading_score >= 70
      AND writing_score >= 70
)
SELECT 
    gender,
    COUNT(*) AS student_count,
    ROUND(AVG(math_score), 2) AS avg_math,
    ROUND(AVG(reading_score), 2) AS avg_reading,
    ROUND(AVG(writing_score), 2) AS avg_writing
FROM high_achievers
GROUP BY gender
ORDER BY student_count DESC;