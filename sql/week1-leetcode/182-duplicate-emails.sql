-- LeetCode 182: Duplicate Emails
-- テーマ: GROUP BY + HAVING
-- 難易度: Easy

-- 問題: 重複しているメールアドレスをすべて取得する

SELECT 
    email AS Email
FROM Person
GROUP BY email
HAVING COUNT(*) >= 2;

-- 学習ポイント:
-- - GROUP BYでemailごとにグループ化
-- - COUNT(*)で各グループの行数をカウント
-- - HAVINGで集約結果に条件を適用（WHERE は集約前の条件）
-- - 重複検出の基本パターン