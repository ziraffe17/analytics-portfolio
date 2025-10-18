-- LeetCode 175: Combine Two Tables
-- テーマ: LEFT JOIN
-- 難易度: Easy

-- 問題: PersonテーブルとAddressテーブルを結合し、
-- すべての人の名前と住所情報を取得する（住所がない人も含む）

SELECT 
    firstName, 
    lastName, 
    city, 
    state
FROM Person
LEFT JOIN Address ON Person.personId = Address.personId;

-- 学習ポイント:
-- - LEFT JOINは左側のテーブル（Person）のすべての行を保持
-- - 右側（Address）にマッチがない場合はNULLが返る
-- - 外部結合の基本パターン