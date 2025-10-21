-- =====================================================
-- Task25: HAVING句の活用
-- =====================================================
-- 作成日: 2025-10-19
-- 学習時間: 30分
-- 目的: WHERE vs HAVINGの違いを理解し、実務で使えるパターンを習得
-- =====================================================

-- 📚 重要な概念
-- WHERE:  集約前のフィルタ（行単位）
-- HAVING: 集約後のフィルタ（グループ単位）

-- 処理順序:
-- 1. FROM
-- 2. WHERE  ← 集約前
-- 3. GROUP BY
-- 4. HAVING ← 集約後
-- 5. SELECT
-- 6. ORDER BY


-- =====================================================
-- Pattern 1: 件数によるフィルタ
-- =====================================================

WITH test_scores AS (
    SELECT 1 AS student_id, 'Math' AS subject, 85 AS score UNION ALL
    SELECT 1, 'English', 92 UNION ALL
    SELECT 1, 'Science', 78 UNION ALL
    SELECT 2, 'Math', 95 UNION ALL
    SELECT 2, 'English', 88 UNION ALL
    SELECT 2, 'Science', 91 UNION ALL
    SELECT 3, 'Math', 75 UNION ALL
    SELECT 3, 'English', 82 UNION ALL
    SELECT 3, 'Science', 79 UNION ALL
    SELECT 4, 'Math', 88 UNION ALL
    SELECT 5, 'English', 90
)

SELECT 
    student_id,
    COUNT(*) AS subjects_taken,
    ROUND(AVG(score), 2) AS avg_score
FROM test_scores
GROUP BY student_id
HAVING COUNT(*) >= 2  -- 2科目以上受験した学生のみ
ORDER BY avg_score DESC;


-- =====================================================
-- Pattern 2: 集約値によるフィルタ
-- =====================================================

WITH test_scores AS (
    SELECT 1 AS student_id, 'Math' AS subject, 85 AS score UNION ALL
    SELECT 1, 'English', 92 UNION ALL
    SELECT 1, 'Science', 78 UNION ALL
    SELECT 2, 'Math', 95 UNION ALL
    SELECT 2, 'English', 88 UNION ALL
    SELECT 2, 'Science', 91 UNION ALL
    SELECT 3, 'Math', 75 UNION ALL
    SELECT 3, 'English', 82 UNION ALL
    SELECT 3, 'Science', 79 UNION ALL
    SELECT 4, 'Math', 55 UNION ALL
    SELECT 4, 'English', 58 UNION ALL
    SELECT 4, 'Science', 52
)

SELECT 
    student_id,
    COUNT(*) AS subjects_taken,
    ROUND(AVG(score), 2) AS avg_score,
    MIN(score) AS min_score,
    MAX(score) AS max_score
FROM test_scores
GROUP BY student_id
HAVING AVG(score) >= 80  -- 平均点80点以上の学生のみ
ORDER BY avg_score DESC;


-- =====================================================
-- Pattern 3: WHEREとHAVINGの組み合わせ
-- =====================================================

WITH attendance_records AS (
    SELECT 1 AS user_id, DATE('2025-01-05') AS attendance_date, 'present' AS status UNION ALL
    SELECT 1, DATE('2025-01-06'), 'present' UNION ALL
    SELECT 1, DATE('2025-01-07'), 'late' UNION ALL
    SELECT 1, DATE('2025-01-08'), 'present' UNION ALL
    SELECT 1, DATE('2025-01-09'), 'absent' UNION ALL
    SELECT 1, DATE('2025-01-12'), 'present' UNION ALL
    SELECT 1, DATE('2025-01-13'), 'present' UNION ALL
    SELECT 1, DATE('2025-01-14'), 'present' UNION ALL
    SELECT 2, DATE('2025-01-05'), 'present' UNION ALL
    SELECT 2, DATE('2025-01-06'), 'late' UNION ALL
    SELECT 2, DATE('2025-01-07'), 'present' UNION ALL
    SELECT 2, DATE('2025-01-08'), 'present' UNION ALL
    SELECT 3, DATE('2025-01-05'), 'present' UNION ALL
    SELECT 3, DATE('2025-01-06'), 'present' UNION ALL
    SELECT 3, DATE('2025-01-07'), 'absent'
)

SELECT 
    user_id,
    COUNT(*) AS total_days,
    COUNTIF(status = 'present') AS present_days,
    ROUND(COUNTIF(status = 'present') * 100.0 / COUNT(*), 2) AS attendance_rate
FROM attendance_records
WHERE attendance_date >= '2025-01-01'     -- WHERE: 1月のデータのみ
  AND attendance_date < '2025-02-01'
GROUP BY user_id
HAVING COUNT(*) >= 3                       -- HAVING: 3日以上記録
   AND COUNTIF(status = 'present') * 100.0 / COUNT(*) >= 60  -- HAVING: 出席率60%以上
ORDER BY attendance_rate DESC;


-- =====================================================
-- Pattern 4: 重複データの検出
-- =====================================================

WITH users AS (
    SELECT 1 AS user_id, 'alice@example.com' AS email UNION ALL
    SELECT 2, 'bob@example.com' UNION ALL
    SELECT 3, 'alice@example.com' UNION ALL
    SELECT 4, 'charlie@example.com' UNION ALL
    SELECT 5, 'bob@example.com' UNION ALL
    SELECT 6, 'david@example.com'
)

SELECT 
    email,
    COUNT(*) AS user_count,
    STRING_AGG(CAST(user_id AS STRING), ', ') AS duplicate_user_ids
FROM users
GROUP BY email
HAVING COUNT(*) >= 2  -- 2人以上で使われているメールアドレス
ORDER BY user_count DESC;


-- =====================================================
-- Pattern 5: トップNグループの抽出
-- =====================================================

WITH orders AS (
    SELECT 1 AS customer_id, DATE('2025-01-05') AS order_date, 1000 AS amount UNION ALL
    SELECT 1, DATE('2025-01-12'), 1500 UNION ALL
    SELECT 1, DATE('2025-01-20'), 2000 UNION ALL
    SELECT 2, DATE('2025-01-08'), 500 UNION ALL
    SELECT 2, DATE('2025-01-15'), 800 UNION ALL
    SELECT 3, DATE('2025-01-10'), 3000 UNION ALL
    SELECT 3, DATE('2025-01-18'), 2500 UNION ALL
    SELECT 3, DATE('2025-01-25'), 4000 UNION ALL
    SELECT 4, DATE('2025-01-07'), 300 UNION ALL
    SELECT 5, DATE('2025-01-14'), 1200
)

SELECT 
    customer_id,
    COUNT(*) AS order_count,
    SUM(amount) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order
FROM orders
GROUP BY customer_id
HAVING COUNT(*) >= 2           -- 2回以上購入
   AND SUM(amount) >= 5000     -- 総額5000円以上
ORDER BY total_amount DESC;


-- =====================================================
-- Pattern 6: サブクエリとの組み合わせ
-- =====================================================

WITH test_scores AS (
    SELECT 1 AS student_id, 'Math' AS subject, 85 AS score UNION ALL
    SELECT 1, 'English', 92 UNION ALL
    SELECT 1, 'Science', 78 UNION ALL
    SELECT 2, 'Math', 95 UNION ALL
    SELECT 2, 'English', 88 UNION ALL
    SELECT 2, 'Science', 91 UNION ALL
    SELECT 3, 'Math', 75 UNION ALL
    SELECT 3, 'English', 82 UNION ALL
    SELECT 3, 'Science', 79
)

SELECT 
    student_id,
    COUNT(*) AS subjects_taken,
    ROUND(AVG(score), 2) AS avg_score
FROM test_scores
GROUP BY student_id
HAVING AVG(score) > (
    SELECT AVG(score)
    FROM test_scores
)
ORDER BY avg_score DESC;


-- =====================================================
-- 総合演習: 月次レポート（あゆみSaaS風）
-- =====================================================

WITH training_data AS (
    SELECT 1 AS user_id, DATE('2025-01-05') AS report_date, 120 AS training_minutes UNION ALL
    SELECT 1, DATE('2025-01-06'), 90 UNION ALL
    SELECT 1, DATE('2025-01-07'), 150 UNION ALL
    SELECT 1, DATE('2025-01-08'), 60 UNION ALL
    SELECT 1, DATE('2025-01-09'), 180 UNION ALL
    SELECT 1, DATE('2025-01-12'), 110 UNION ALL
    SELECT 1, DATE('2025-01-13'), 140 UNION ALL
    SELECT 1, DATE('2025-01-14'), 130 UNION ALL
    SELECT 2, DATE('2025-01-05'), 90 UNION ALL
    SELECT 2, DATE('2025-01-06'), 70 UNION ALL
    SELECT 2, DATE('2025-01-07'), 80 UNION ALL
    SELECT 2, DATE('2025-01-08'), 75 UNION ALL
    SELECT 2, DATE('2025-01-12'), 95 UNION ALL
    SELECT 2, DATE('2025-01-13'), 70 UNION ALL
    SELECT 3, DATE('2025-01-05'), 30 UNION ALL
    SELECT 3, DATE('2025-01-10'), 50 UNION ALL
    SELECT 3, DATE('2025-01-15'), 40
)

SELECT 
    user_id,
    DATE_TRUNC(report_date, MONTH) AS month,
    COUNT(*) AS report_days,
    SUM(training_minutes) AS total_minutes,
    ROUND(SUM(training_minutes) / 60.0, 2) AS total_hours,
    ROUND(AVG(training_minutes), 2) AS avg_minutes_per_day,
    MIN(training_minutes) AS min_minutes,
    MAX(training_minutes) AS max_minutes,
    CASE 
        WHEN AVG(training_minutes) >= 100 THEN '優秀'
        WHEN AVG(training_minutes) >= 60 THEN '良好'
        ELSE '要改善'
    END AS performance
FROM training_data
WHERE report_date >= '2025-01-01'
  AND report_date < '2025-02-01'
GROUP BY user_id, month
HAVING COUNT(*) >= 5                 -- 5日以上
   AND AVG(training_minutes) >= 60   -- 平均60分以上
ORDER BY avg_minutes_per_day DESC;


-- =====================================================
-- 📝 学習ポイントまとめ
-- =====================================================

-- 1. WHERE vs HAVING
--    - WHERE:  集約前のフィルタ（行を減らす）
--    - HAVING: 集約後のフィルタ（グループを減らす）

-- 2. 処理順序を理解する
--    FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

-- 3. HAVINGでできること
--    - COUNT(*) >= n: 件数によるフィルタ
--    - AVG() >= n:    平均値によるフィルタ
--    - SUM() >= n:    合計値によるフィルタ
--    - 複数条件の組み合わせ（AND, OR）
--    - サブクエリとの比較

-- 4. 実務での活用
--    - 優良顧客の抽出（購入回数・金額）
--    - データ品質チェック（重複検出）
--    - パフォーマンス分析（平均以上）
--    - KPIレポート（目標達成者の抽出）

-- 5. ポートフォリオへの応用
--    - プロジェクト1（教育データ）: 優秀な学生の抽出
--    - プロジェクト2（あゆみSaaS）: 目標達成者のレポート

-- =====================================================
-- ✅ Task25 完了
-- =====================================================