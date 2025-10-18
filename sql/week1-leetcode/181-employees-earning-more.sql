-- LeetCode 181: Employees Earning More Than Their Managers
-- テーマ: Self JOIN
-- 難易度: Easy

-- 問題: 上司よりも給料が高い従業員の名前を取得する

SELECT 
    e1.name AS Employee
FROM Employee e1
LEFT JOIN Employee e2 ON e1.managerId = e2.id
WHERE e1.salary > e2.salary;

-- 学習ポイント:
-- - Self JOIN: 同じテーブルを2回参照
-- - e1を従業員、e2を上司として扱う
-- - managerIdでe1とe2を結合
-- - 給料比較にはWHERE句を使用