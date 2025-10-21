-- LeetCode Task26: Easy 3問
-- 作成日: 2025-10-21

-- ===================================
-- 577: Employee Bonus
-- ===================================
-- 問題: ボーナスが1000未満の従業員の名前とボーナス額を表示

SELECT e.name, b.bonus
FROM Employee e
LEFT JOIN Bonus b ON e.empId = b.empId
WHERE b.bonus < 1000 OR b.bonus IS NULL;

-- 実務への応用:
-- - 条件を満たす or データがないケースの抽出
-- - 例: プレミアム会員でない または 会員情報がない


-- ===================================
-- 584: Find Customer Referee
-- ===================================
-- 問題: referee_id が 2 でない顧客の名前を表示

-- ❌ 間違った例（NULLが除外される）
SELECT name
FROM Customer
WHERE referee_id != 2;

-- ✅ 正しい例1: OR IS NULL
SELECT name
FROM Customer
WHERE referee_id != 2 OR referee_id IS NULL;

-- ✅ 正しい例2: IFNULL
SELECT name
FROM Customer
WHERE IFNULL(referee_id, 0) != 2;

-- 重要な学び: NULL != 2 は NULL（不明）であり、FALSEではない


-- ===================================
-- 586: Customer Placing the Largest Number of Orders
-- ===================================
-- 問題: 最も多く注文した顧客番号を表示

-- 方法1: ORDER BY + LIMIT（シンプル）
SELECT customer_number
FROM Orders
GROUP BY customer_number
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 方法2: RANK()（同順位を全て取得）
SELECT customer_number
FROM (
    SELECT 
        customer_number,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM Orders
    GROUP BY customer_number
)
WHERE rnk = 1;

-- 実務への応用:
-- - トップ顧客の特定
-- - 売上ランキング
-- - アクティブユーザーの抽出