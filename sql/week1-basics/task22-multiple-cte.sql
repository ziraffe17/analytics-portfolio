-- Task22: 複数CTEの組み合わせ（実データ版）
-- 作成日: 2025-10-18
-- データ: mystic-now-474722-r4.education_analytics.raw_student_performance

-- =============================================================================
-- 例1: 段階的にデータを絞り込む（3段階）
-- =============================================================================

WITH 
-- Step 1: テスト準備コースを受けた学生だけ
prep_students AS (
    SELECT *
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
    WHERE test_preparation_course = 'completed'
),
-- Step 2: 3科目の平均を計算
student_averages AS (
    SELECT 
        gender,
        race_ethnicity,
        parental_level_of_education,
        math_score,
        reading_score,
        writing_score,
        ROUND((math_score + reading_score + writing_score) / 3.0, 2) AS avg_score
    FROM prep_students
),
-- Step 3: 80点以上の高得点者だけ抽出
high_performers AS (
    SELECT *
    FROM student_averages
    WHERE avg_score >= 80
)
-- 最終結果: 親の学歴別に集計
SELECT 
    parental_level_of_education,
    COUNT(*) AS high_performer_count,
    ROUND(AVG(avg_score), 2) AS avg_total_score,
    ROUND(AVG(math_score), 2) AS avg_math,
    ROUND(AVG(reading_score), 2) AS avg_reading,
    ROUND(AVG(writing_score), 2) AS avg_writing
FROM high_performers
GROUP BY parental_level_of_education
ORDER BY avg_total_score DESC;

-- 学習ポイント:
-- - 複数のCTEをカンマで区切る
-- - 前のCTEの結果を次のCTEで使える
-- - 段階的に処理することで理解しやすい


-- =============================================================================
-- 例2: 複数の集約結果を統合する（UNION ALL）
-- =============================================================================

WITH 
-- 性別ごとの統計
gender_stats AS (
    SELECT 
        'Gender' AS category,
        gender AS subcategory,
        COUNT(*) AS student_count,
        ROUND(AVG(math_score), 2) AS avg_score
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
    GROUP BY gender
),
-- 人種ごとの統計
race_stats AS (
    SELECT 
        'Race/Ethnicity' AS category,
        race_ethnicity AS subcategory,
        COUNT(*) AS student_count,
        ROUND(AVG(math_score), 2) AS avg_score
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
    GROUP BY race_ethnicity
),
-- テスト準備コースごとの統計
prep_stats AS (
    SELECT 
        'Test Prep' AS category,
        test_preparation_course AS subcategory,
        COUNT(*) AS student_count,
        ROUND(AVG(math_score), 2) AS avg_score
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
    GROUP BY test_preparation_course
)
-- すべてを統合して1つのテーブルに
SELECT * FROM gender_stats
UNION ALL
SELECT * FROM race_stats
UNION ALL
SELECT * FROM prep_stats
ORDER BY category, avg_score DESC;

-- 学習ポイント:
-- - 複数のCTEを作って別々に集計
-- - UNION ALLで縦に結合
-- - カテゴリごとに比較できる


-- =============================================================================
-- 例3: ランキングを作成（前のCTEを参照）
-- =============================================================================

WITH 
-- Step 1: 3科目の平均を計算
student_scores AS (
    SELECT 
        gender,
        race_ethnicity,
        parental_level_of_education,
        math_score,
        reading_score,
        writing_score,
        ROUND((math_score + reading_score + writing_score) / 3.0, 2) AS avg_score
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
),
-- Step 2: 性別ごとにランク付け（student_scoresを参照）
ranked_by_gender AS (
    SELECT 
        gender,
        race_ethnicity,
        parental_level_of_education,
        avg_score,
        RANK() OVER (PARTITION BY gender ORDER BY avg_score DESC) AS rank_in_gender
    FROM student_scores
)
-- 最終結果: 各性別でトップ5
SELECT *
FROM ranked_by_gender
WHERE rank_in_gender <= 5
ORDER BY gender, rank_in_gender;

-- 学習ポイント:
-- - 前のCTE（student_scores）を次のCTE（ranked_by_gender）で使用
-- - ウィンドウ関数でランキング
-- - WHERE句で上位だけ抽出


-- =============================================================================
-- 例4: 全体平均と比較して優秀な学生を特定（4段階）
-- =============================================================================

WITH 
-- Step 1: 全体の平均を計算
overall_stats AS (
    SELECT 
        ROUND(AVG(math_score), 2) AS avg_math,
        ROUND(AVG(reading_score), 2) AS avg_reading,
        ROUND(AVG(writing_score), 2) AS avg_writing
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
),
-- Step 2: すべての学生に全体平均を追加
students_with_avg AS (
    SELECT 
        s.*,
        o.avg_math,
        o.avg_reading,
        o.avg_writing
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance` s
    CROSS JOIN overall_stats o
),
-- Step 3: 全科目で平均以上の学生を抽出
above_avg_students AS (
    SELECT 
        gender,
        race_ethnicity,
        math_score,
        reading_score,
        writing_score,
        avg_math,
        avg_reading,
        avg_writing
    FROM students_with_avg
    WHERE math_score >= avg_math
      AND reading_score >= avg_reading
      AND writing_score >= avg_writing
),
-- Step 4: さらに総合80点以上に絞る
top_performers AS (
    SELECT 
        gender,
        race_ethnicity,
        math_score,
        reading_score,
        writing_score,
        ROUND((math_score + reading_score + writing_score) / 3.0, 2) AS total_avg
    FROM above_avg_students
    WHERE (math_score + reading_score + writing_score) / 3.0 >= 80
)
-- 最終結果: 性別・人種別に集計
SELECT 
    gender,
    race_ethnicity,
    COUNT(*) AS top_performer_count,
    ROUND(AVG(total_avg), 2) AS avg_total_score
FROM top_performers
GROUP BY gender, race_ethnicity
ORDER BY avg_total_score DESC;

-- 学習ポイント:
-- - 4つのCTEを連鎖的に使用
-- - 各ステップで段階的に絞り込み
-- - 複雑な条件も分解すれば理解しやすい


-- =============================================================================
-- 例5: 比較分析（テスト準備コースあり vs なし）
-- =============================================================================

WITH 
-- テスト準備コースありの統計
with_prep AS (
    SELECT 
        'With Prep' AS prep_status,
        COUNT(*) AS student_count,
        ROUND(AVG(math_score), 2) AS avg_math,
        ROUND(AVG(reading_score), 2) AS avg_reading,
        ROUND(AVG(writing_score), 2) AS avg_writing
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
    WHERE test_preparation_course = 'completed'
),
-- テスト準備コースなしの統計
without_prep AS (
    SELECT 
        'Without Prep' AS prep_status,
        COUNT(*) AS student_count,
        ROUND(AVG(math_score), 2) AS avg_math,
        ROUND(AVG(reading_score), 2) AS avg_reading,
        ROUND(AVG(writing_score), 2) AS avg_writing
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
    WHERE test_preparation_course = 'none'
)
-- 2つのグループを縦に結合して比較
SELECT * FROM with_prep
UNION ALL
SELECT * FROM without_prep;

-- 学習ポイント:
-- - 2つのグループを別々に集計
-- - UNION ALLで並べて比較
-- - テスト準備コースの効果を測定できる


-- =============================================================================
-- 練習問題: 自分で試してみよう
-- =============================================================================

-- Q1: 昼食タイプ別（standard vs free/reduced）の成績を比較
-- ヒント: 例5と同じ構造で lunch カラムを使う

-- Q2: 各人種グループでトップ10%の学生の平均点を計算
-- ヒント: 例3と同じ構造で race_ethnicity でランキング

-- Q3: 性別×テスト準備コースの組み合わせごとに成績を集計
-- ヒント: GROUP BY gender, test_preparation_course