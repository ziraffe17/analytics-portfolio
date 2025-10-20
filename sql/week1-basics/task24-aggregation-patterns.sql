-- =====================================================
-- Task24: 集約関数の応用パターン（5パターン統合版）
-- =====================================================
-- 作成日: 2025-10-21
-- 学習時間: 30分
-- 目的: 実務で使える集約関数のパターンを習得
-- =====================================================

-- 📚 目次
-- Pattern 1: 条件付き集約（COUNTIF / CASE WHEN）
-- Pattern 2: 統計量の計算（AVG, STDDEV, QUANTILES）
-- Pattern 3: 割合・パーセンテージ（ウィンドウ関数）
-- Pattern 4: 複数軸グループ化（DATE_TRUNC + GROUP BY）
-- Pattern 5: ビジネスKPI計算（達成率、前月比）


-- =====================================================
-- Pattern 1: 条件付き集約
-- =====================================================
-- 目的: カテゴリ別集計を1クエリで実現
-- ビジネス価値: ダッシュボード用データの効率的な作成
-- =====================================================

-- ■ 1-1: COUNTIFの基本
WITH test_scores AS (
    SELECT 1 AS student_id, 'Math' AS subject, 85 AS score UNION ALL
    SELECT 1, 'English', 92 UNION ALL
    SELECT 1, 'Science', 78 UNION ALL
    SELECT 2, 'Math', 95 UNION ALL
    SELECT 2, 'English', 88 UNION ALL
    SELECT 2, 'Science', 91 UNION ALL
    SELECT 3, 'Math', NULL UNION ALL
    SELECT 3, 'English', 75 UNION ALL
    SELECT 3, 'Science', 82
)

SELECT 
    subject,
    COUNT(*) AS total_students,
    COUNTIF(score >= 80) AS excellent_count,
    COUNTIF(score >= 60 AND score < 80) AS good_count,
    COUNTIF(score < 60) AS needs_improvement,
    COUNTIF(score IS NULL) AS not_taken,
    ROUND(AVG(score), 2) AS avg_score
FROM test_scores
GROUP BY subject
ORDER BY subject;


-- ■ 1-2: 実務パターン - 出席状況の詳細集計
WITH attendance_records AS (
    SELECT 1 AS user_id, DATE('2025-01-05') AS attendance_date, 'present' AS status UNION ALL
    SELECT 1, DATE('2025-01-06'), 'present' UNION ALL
    SELECT 1, DATE('2025-01-07'), 'late' UNION ALL
    SELECT 1, DATE('2025-01-08'), 'present' UNION ALL
    SELECT 1, DATE('2025-01-09'), 'absent' UNION ALL
    SELECT 2, DATE('2025-01-05'), 'present' UNION ALL
    SELECT 2, DATE('2025-01-06'), 'late' UNION ALL
    SELECT 2, DATE('2025-01-07'), 'present' UNION ALL
    SELECT 2, DATE('2025-01-08'), 'present' UNION ALL
    SELECT 2, DATE('2025-01-09'), 'present'
)

SELECT 
    user_id,
    COUNT(*) AS total_days,
    COUNTIF(status = 'present') AS present_days,
    COUNTIF(status = 'absent') AS absent_days,
    COUNTIF(status = 'late') AS late_days,
    ROUND(COUNTIF(status = 'present') * 100.0 / COUNT(*), 2) AS attendance_rate,
    CASE 
        WHEN COUNTIF(status = 'present') * 100.0 / COUNT(*) >= 90 THEN '優良'
        WHEN COUNTIF(status = 'present') * 100.0 / COUNT(*) >= 70 THEN '良好'
        ELSE '要注意'
    END AS category
FROM attendance_records
GROUP BY user_id
ORDER BY attendance_rate DESC;


-- =====================================================
-- Pattern 2: 統計量の計算
-- =====================================================
-- 目的: データの分布・ばらつきを可視化
-- ビジネス価値: データ品質チェック、異常値検出
-- =====================================================

-- ■ 2-1: 記述統計量の一括計算
WITH test_scores AS (
    SELECT 1 AS student_id, 'Math' AS subject, 85 AS score UNION ALL
    SELECT 1, 'English', 92 UNION ALL
    SELECT 1, 'Science', 78 UNION ALL
    SELECT 2, 'Math', 95 UNION ALL
    SELECT 2, 'English', 88 UNION ALL
    SELECT 2, 'Science', 91 UNION ALL
    SELECT 3, 'English', 75 UNION ALL
    SELECT 3, 'Science', 82
)

SELECT 
    subject,
    COUNT(score) AS n,
    ROUND(AVG(score), 2) AS mean,
    ROUND(STDDEV(score), 2) AS std_dev,
    MIN(score) AS min_val,
    APPROX_QUANTILES(score, 4)[OFFSET(1)] AS q1,      -- 25%点
    APPROX_QUANTILES(score, 4)[OFFSET(2)] AS median,  -- 中央値
    APPROX_QUANTILES(score, 4)[OFFSET(3)] AS q3,      -- 75%点
    MAX(score) AS max_val,
    MAX(score) - MIN(score) AS range_val
FROM test_scores
WHERE score IS NOT NULL
GROUP BY subject
ORDER BY subject;


-- =====================================================
-- Pattern 3: 割合・パーセンテージ計算
-- =====================================================
-- 目的: 構成比・達成率の可視化
-- ビジネス価値: 市場シェア分析、目標達成率レポート
-- =====================================================

-- ■ 3-1: ウィンドウ関数で全体に対する割合
WITH test_scores AS (
    SELECT 1 AS student_id, 'Math' AS subject, 85 AS score UNION ALL
    SELECT 1, 'English', 92 UNION ALL
    SELECT 1, 'Science', 78 UNION ALL
    SELECT 2, 'Math', 95 UNION ALL
    SELECT 2, 'English', 88 UNION ALL
    SELECT 2, 'Science', 91 UNION ALL
    SELECT 3, 'English', 75 UNION ALL
    SELECT 3, 'Science', 82
),
score_categories AS (
    SELECT 
        CASE 
            WHEN score >= 80 THEN 'High Performer'
            WHEN score >= 60 THEN 'Medium Performer'
            WHEN score < 60 THEN 'Low Performer'
            ELSE 'Not Taken'
        END AS performance_category
    FROM test_scores
)

SELECT 
    performance_category,
    COUNT(*) AS count,
    SUM(COUNT(*)) OVER () AS total,  -- ★ ウィンドウ関数で全体合計
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM score_categories
GROUP BY performance_category
ORDER BY percentage DESC;


-- =====================================================
-- Pattern 4: 複数軸でのグループ化
-- =====================================================
-- 目的: 多次元分析（時系列×カテゴリ）
-- ビジネス価値: 月次レポート、トレンド分析
-- =====================================================

-- ■ 4-1: 月×科目でグループ化 + 前月比
WITH test_scores AS (
    -- 1月のテスト
    SELECT 1 AS student_id, 'Math' AS subject, 85 AS score, DATE('2025-01-15') AS test_date UNION ALL
    SELECT 1, 'English', 92, DATE('2025-01-15') UNION ALL
    SELECT 2, 'Math', 95, DATE('2025-01-15') UNION ALL
    SELECT 2, 'English', 88, DATE('2025-01-15') UNION ALL
    -- 2月のテスト
    SELECT 1, 'Math', 88, DATE('2025-02-15') UNION ALL
    SELECT 1, 'English', 95, DATE('2025-02-15') UNION ALL
    SELECT 2, 'Math', 98, DATE('2025-02-15') UNION ALL
    SELECT 2, 'English', 90, DATE('2025-02-15')
)

SELECT 
    DATE_TRUNC(test_date, MONTH) AS month,
    subject,
    COUNT(*) AS student_count,
    ROUND(AVG(score), 2) AS avg_score,
    -- 前月の平均点（科目ごと）
    LAG(ROUND(AVG(score), 2)) OVER (
        PARTITION BY subject 
        ORDER BY DATE_TRUNC(test_date, MONTH)
    ) AS prev_month_avg,
    -- 前月比
    ROUND(AVG(score) - LAG(ROUND(AVG(score), 2)) OVER (
        PARTITION BY subject 
        ORDER BY DATE_TRUNC(test_date, MONTH)
    ), 2) AS score_change
FROM test_scores
GROUP BY month, subject
ORDER BY subject, month;


-- =====================================================
-- Pattern 5: ビジネスKPIの計算
-- =====================================================
-- 目的: 経営判断に使える指標を自動算出
-- ビジネス価値: KPIダッシュボード、自動アラート
-- =====================================================

-- ■ 5-1: 月次訓練レポート（達成率・評価含む）
WITH training_data AS (
    SELECT 1 AS user_id, DATE('2025-01-05') AS report_date, 120 AS training_minutes, 4 AS self_evaluation UNION ALL
    SELECT 1, DATE('2025-01-06'), 90, 3 UNION ALL
    SELECT 1, DATE('2025-01-07'), 150, 5 UNION ALL
    SELECT 1, DATE('2025-01-08'), 60, 3 UNION ALL
    SELECT 1, DATE('2025-01-09'), 180, 5
)

SELECT 
    user_id,
    DATE_TRUNC(report_date, MONTH) AS month,
    
    -- 基本集計
    COUNT(*) AS report_days,
    SUM(training_minutes) AS total_minutes,
    ROUND(SUM(training_minutes) / 60.0, 2) AS total_hours,
    
    -- 平均・最大・最小
    ROUND(AVG(training_minutes), 2) AS avg_minutes_per_day,
    MIN(training_minutes) AS min_minutes,
    MAX(training_minutes) AS max_minutes,
    
    -- 目標達成日数（60分以上）
    COUNTIF(training_minutes >= 60) AS days_over_1hour,
    COUNTIF(training_minutes >= 120) AS days_over_2hours,
    
    -- 達成率
    ROUND(COUNTIF(training_minutes >= 60) * 100.0 / COUNT(*), 2) AS achievement_rate,
    
    -- 自己評価
    ROUND(AVG(self_evaluation), 2) AS avg_self_eval,
    
    -- KPI判定
    CASE 
        WHEN SUM(training_minutes) / 60.0 >= 60 
             AND COUNTIF(training_minutes >= 60) * 100.0 / COUNT(*) >= 80
        THEN '目標達成 🎉'
        WHEN SUM(training_minutes) / 60.0 >= 40
        THEN '要努力 💪'
        ELSE '要支援 📢'
    END AS performance_status

FROM training_data
GROUP BY user_id, month;


-- =====================================================
-- 📝 学習ポイントまとめ
-- =====================================================

-- 1. BigQuery特有の関数
--    - COUNTIF(): 条件付きカウント
--    - SAFE_DIVIDE(): 0除算エラー回避
--    - APPROX_QUANTILES(): パーセンタイル計算

-- 2. ベストプラクティス
--    - NULLに注意: COUNT(*) vs COUNT(column)
--    - 0除算対策: SAFE_DIVIDE(numerator, denominator)
--    - ウィンドウ関数: SUM() OVER ()で全体集計

-- 3. 実務での応用
--    - パターン1: ステータス別レポート
--    - パターン2: データ品質チェック
--    - パターン3: 構成比・達成率
--    - パターン4: 月次レポート・前月比
--    - パターン5: KPIダッシュボード

-- 4. ポートフォリオへの応用
--    - プロジェクト1（教育データ）: 成績カテゴリ別分析
--    - プロジェクト2（あゆみSaaS）: 月次KPIレポート

-- ==========================================