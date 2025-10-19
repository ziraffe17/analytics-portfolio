-- =============================================================================
-- Task23: LeetCode Easy 3問
-- 作成日: 2025-10-18
-- テーマ: JOIN応用（LEFT JOIN + NULL、DELETE、Self JOIN + 日付）
-- =============================================================================


-- =============================================================================
-- 問題183: Customers Who Never Order
-- テーマ: LEFT JOIN + NULL判定
-- 難易度: Easy
-- =============================================================================

-- 問題: 注文をしたことがない顧客を見つける

-- テーブル構造:
-- Customers (id, name)
-- Orders (id, customerId)

-- 解答:
SELECT name AS Customers
FROM Customers c
LEFT JOIN Orders o ON c.id = o.customerId
WHERE o.id IS NULL;

-- 解説:
-- 1. LEFT JOINは左側のテーブル（Customers）のすべての行を保持
-- 2. エイリアス（c, o）で可読性向上
-- 3. WHERE o.id IS NULL で「注文がない」を判定
-- 4. このパターンは実務で頻出（欠損データの検出）

-- 動作の流れ:
-- Step 1: LEFT JOIN実行
--   Customers    Orders
--   id=1, Joe  → order exists
--   id=2, Henry → NULL (no order)
--   id=3, Sam  → order exists
--   id=4, Max  → NULL (no order)
--
-- Step 2: WHERE o.id IS NULL
--   id=2, Henry
--   id=4, Max
--
-- Step 3: SELECT name AS Customers
--   結果: Henry, Max

-- 別解1: NOT IN を使う方法（パフォーマンスは劣る）
-- SELECT name AS Customers
-- FROM Customers
-- WHERE id NOT IN (SELECT customerId FROM Orders WHERE customerId IS NOT NULL);

-- 別解2: NOT EXISTS を使う方法（パフォーマンス良好）
-- SELECT name AS Customers
-- FROM Customers c
-- WHERE NOT EXISTS (
--     SELECT 1 FROM Orders o WHERE o.customerId = c.id
-- );

-- 学習ポイント:
-- - LEFT JOINで「〜がない」を見つける
-- - IS NULLで欠損データを判定
-- - 実務でよく使うパターン
-- - NOT EXISTSも覚えておくと便利


-- =============================================================================
-- 問題196: Delete Duplicate Emails
-- テーマ: DELETE + Self JOIN（MySQL） / CREATE OR REPLACE（BigQuery）
-- 難易度: Easy
-- =============================================================================

-- 問題: 重複しているメールアドレスを削除し、最小のIDだけを残す

-- テーブル構造:
-- Person (id, email)
-- 例: id=1,3 で email='john@example.com' → id=3を削除

-- =============================================================================
-- MySQL版: DELETE文を使う（LeetCodeの標準解答）
-- =============================================================================

DELETE p1
FROM Person p1
INNER JOIN Person p2 
WHERE p1.email = p2.email 
  AND p1.id > p2.id;

-- 解説:
-- 1. Self JOINで同じメールアドレスを持つ行を結合
-- 2. p1.id > p2.id で「より大きいID」を特定
-- 3. DELETE p1 で大きいIDの行を削除
-- 4. 結果: 各メールアドレスで最小のIDだけが残る

-- 動作イメージ:
-- 元データ: 
--   id=1, email='john@example.com'
--   id=2, email='bob@example.com'
--   id=3, email='john@example.com'
--
-- Self JOIN結果:
--   p1(id=1) JOIN p2(id=1) → 1 = 1, skip
--   p1(id=1) JOIN p2(id=3) → 1 < 3, skip
--   p1(id=3) JOIN p2(id=1) → 3 > 1, DELETE id=3 ✓
--   p1(id=3) JOIN p2(id=3) → 3 = 3, skip
--
-- 削除後:
--   id=1, email='john@example.com'
--   id=2, email='bob@example.com'


-- =============================================================================
-- BigQuery版1: ROW_NUMBER()を使う（推奨）
-- =============================================================================

-- BigQueryではDELETE文が制限されているため、CREATE OR REPLACEを使用

CREATE OR REPLACE TABLE `mystic-now-474722-r4.education_analytics.Person` AS
SELECT id, email
FROM (
    SELECT 
        id,
        email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS row_num
    FROM `mystic-now-474722-r4.education_analytics.Person`
)
WHERE row_num = 1;

-- 解説:
-- 1. ROW_NUMBER()で各メールアドレス内でIDの昇順に番号を振る
-- 2. row_num = 1 の行だけを抽出（最小IDのみ）
-- 3. CREATE OR REPLACE でテーブルを上書き

-- 動作イメージ:
-- ROW_NUMBER()実行後:
--   id=1, email='john@example.com', row_num=1
--   id=3, email='john@example.com', row_num=2
--   id=2, email='bob@example.com', row_num=1
--
-- WHERE row_num = 1:
--   id=1, email='john@example.com'
--   id=2, email='bob@example.com'


-- =============================================================================
-- BigQuery版2: GROUP BY + MIN()を使う（シンプル）
-- =============================================================================

CREATE OR REPLACE TABLE `mystic-now-474722-r4.education_analytics.Person` AS
SELECT MIN(id) AS id, email
FROM `mystic-now-474722-r4.education_analytics.Person`
GROUP BY email;

-- 解説:
-- 1. GROUP BY email でメールアドレスごとにグループ化
-- 2. MIN(id) で各グループの最小IDを取得
-- 3. CREATE OR REPLACE でテーブルを上書き

-- メリット: コードが短くシンプル
-- デメリット: 他のカラムがある場合は使いにくい


-- =============================================================================
-- BigQuery版3: CTEを使う（最も読みやすい）
-- =============================================================================

WITH ranked_emails AS (
    -- Step 1: 各メールアドレス内で順位を付ける
    SELECT 
        id,
        email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS row_num
    FROM `mystic-now-474722-r4.education_analytics.Person`
),
unique_emails AS (
    -- Step 2: 最小IDだけを抽出
    SELECT id, email
    FROM ranked_emails
    WHERE row_num = 1
)
-- Step 3: 結果を取得（またはCREATE OR REPLACEで保存）
SELECT * FROM unique_emails;

-- 解説:
-- 1. CTEで段階的に処理
-- 2. 各ステップが理解しやすい
-- 3. デバッグも容易

-- 実務での使い分け:
-- - 一時的な確認: SELECT文で実行
-- - 永続的な変更: CREATE OR REPLACE で保存


-- =============================================================================
-- 学習ポイント: MySQLとBigQueryの違い
-- =============================================================================

/*
重複削除の方法比較:

MySQL:
- DELETE文が使える
- Self JOINでシンプルに書ける
- トランザクション処理が可能
- 小規模データに最適

BigQuery:
- DELETE文は制限されている（DML文の実行回数に制限あり）
- CREATE OR REPLACEでテーブル全体を置き換える
- ウィンドウ関数やCTEを活用
- 大量データの処理に最適化

実務での推奨:
- BigQueryでは「削除」ではなく「作り直し」の発想
- ROW_NUMBER()を使う方法が最も柔軟
- パフォーマンスはBigQueryの方が大規模データに強い
*/


-- =============================================================================
-- 実データで試してみよう（教育データセット）
-- =============================================================================

-- 例: 同じ性別・数学スコアの組み合わせで重複がある場合、
--     読解スコアが最も高い行だけ残す

WITH ranked_students AS (
    SELECT 
        gender,
        math_score,
        reading_score,
        writing_score,
        ROW_NUMBER() OVER (
            PARTITION BY gender, math_score 
            ORDER BY reading_score DESC
        ) AS row_num
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
)
SELECT 
    gender,
    math_score,
    reading_score,
    writing_score
FROM ranked_students
WHERE row_num = 1
ORDER BY gender, math_score DESC
LIMIT 20;

-- 解説:
-- - 性別と数学スコアの組み合わせで重複している場合
-- - 読解スコアが最も高い行だけを残す
-- - 実務でよく使うパターン（優先順位付きの重複削除）


-- =============================================================================
-- 問題197: Rising Temperature
-- テーマ: Self JOIN + 日付比較
-- 難易度: Easy
-- =============================================================================

-- 問題: 前日より気温が高い日のIDを見つける

-- テーブル構造:
-- Weather (id, recordDate, temperature)
-- 例: 2015-01-02の気温が2015-01-01より高い → id=2

-- =============================================================================
-- 解答: MySQL / BigQuery 共通
-- =============================================================================

SELECT w1.id
FROM Weather w1
INNER JOIN Weather w2 
    ON w1.recordDate = DATE_ADD(w2.recordDate, INTERVAL 1 DAY)
WHERE w1.temperature > w2.temperature;

-- 解説:
-- 1. Self JOIN: 同じテーブルを2回参照
--    - w1: 今日のデータ
--    - w2: 昨日のデータ
-- 2. ON条件: w1の日付 = w2の日付 + 1日
--    DATE_ADD(w2.recordDate, INTERVAL 1 DAY) で「翌日」を計算
-- 3. WHERE条件: 今日の気温 > 昨日の気温
-- 4. SELECT: 条件を満たす日のIDを返す

-- 動作イメージ:
-- 元データ:
--   id=1, 2015-01-01, 10度
--   id=2, 2015-01-02, 25度
--   id=3, 2015-01-03, 20度
--   id=4, 2015-01-04, 30度
--
-- Self JOIN結果（ON条件後）:
--   w1(id=2, 2015-01-02, 25) JOIN w2(id=1, 2015-01-01, 10) → 25 > 10 ✓
--   w1(id=3, 2015-01-03, 20) JOIN w2(id=2, 2015-01-02, 25) → 20 < 25 ✗
--   w1(id=4, 2015-01-04, 30) JOIN w2(id=3, 2015-01-03, 20) → 30 > 20 ✓
--
-- 結果: id=2, id=4


-- =============================================================================
-- 別解1: DATE_SUB を使う方法
-- =============================================================================

SELECT w1.id
FROM Weather w1
INNER JOIN Weather w2 
    ON w2.recordDate = DATE_SUB(w1.recordDate, INTERVAL 1 DAY)
WHERE w1.temperature > w2.temperature;

-- 解説:
-- - 発想を逆転: w2の日付 = w1の日付 - 1日
-- - 結果は同じだが、考え方が異なる
-- - どちらでもOK


-- =============================================================================
-- 別解2: DATEDIFF を使う方法（MySQL推奨）
-- =============================================================================

SELECT w1.id
FROM Weather w1
INNER JOIN Weather w2 
    ON DATEDIFF(w1.recordDate, w2.recordDate) = 1
WHERE w1.temperature > w2.temperature;

-- 解説:
-- - DATEDIFF(date1, date2): 2つの日付の差を日数で返す
-- - = 1 なら「1日後」を意味
-- - MySQLではこちらの方が直感的

-- 注意: BigQueryではDATEDIFFの引数が異なる
-- BigQuery版:
-- DATE_DIFF(w1.recordDate, w2.recordDate, DAY) = 1


-- =============================================================================
-- 別解3: ウィンドウ関数（LAG）を使う方法（最も現代的・推奨）
-- =============================================================================

SELECT id
FROM (
    SELECT 
        id,
        recordDate,
        temperature,
        LAG(temperature) OVER (ORDER BY recordDate) AS prev_temp,
        LAG(recordDate) OVER (ORDER BY recordDate) AS prev_date
    FROM Weather
) subquery
WHERE temperature > prev_temp
  AND DATE_DIFF(recordDate, prev_date, DAY) = 1;

-- 解説:
-- - LAG()で前の行の値を取得
-- - Self JOINより直感的
-- - パフォーマンスも良い
-- - BigQueryではこちらを推奨

-- メリット:
-- 1. コードが短い
-- 2. 読みやすい
-- 3. 大量データで高速

-- デメリット:
-- 1. LeetCodeでは使えない場合がある（古い問題）
-- 2. ウィンドウ関数の理解が必要


-- =============================================================================
-- BigQuery版: 実データで試す（教育データセット応用）
-- =============================================================================

-- 実データには日付がないので、スコアの「連続的な上昇」を検出する例

WITH ordered_students AS (
    -- Step 1: 数学スコアで順序付け
    SELECT 
        ROW_NUMBER() OVER (ORDER BY math_score) AS position,
        math_score,
        reading_score,
        writing_score
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
)
SELECT 
    s1.position,
    s1.math_score AS current_score,
    s2.math_score AS previous_score,
    s1.math_score - s2.math_score AS score_increase
FROM ordered_students s1
INNER JOIN ordered_students s2 
    ON s1.position = s2.position + 1
WHERE s1.math_score > s2.math_score
ORDER BY s1.position
LIMIT 10;

-- 解説:
-- - ROW_NUMBER()で「順序」を作る（日付の代わり）
-- - Self JOINで「次の学生」と「現在の学生」を比較
-- - スコアが上昇している箇所を検出
-- - 時系列データ分析のパターンを学習


-- =============================================================================
-- 実務での応用パターン
-- =============================================================================

/*
この問題のパターンは実務で頻出:

1. 売上の前日比較
   - 前日より売上が上がった日を検出
   - 前週比、前月比も同じパターン

2. ユーザーアクティビティ
   - 前日よりログイン数が増えた日
   - 連続してアクティブなユーザーの検出

3. 在庫管理
   - 前日より在庫が減った商品
   - 異常な変動の検出

4. センサーデータ
   - 温度、湿度などの前回比較
   - 異常値の検出

5. KPIモニタリング
   - 日次・週次・月次の変動分析
   - トレンドの検出

共通パターン:
- Self JOIN で時系列データを比較
- 日付計算（DATE_ADD, DATE_SUB, DATEDIFF）
- LAG/LEAD関数でも実装可能（より現代的）
*/


-- =============================================================================
-- 学習ポイントまとめ
-- =============================================================================

/*
Task23で学んだこと:

問題183: Customers Who Never Order
- LEFT JOIN + NULLで欠損データを検出
- 実務で最頻出のパターン
- NOT EXISTSという別解も有用

問題196: Delete Duplicate Emails
- MySQLとBigQueryの根本的な違い
- DELETE vs CREATE OR REPLACE
- ROW_NUMBER()による重複削除パターン
- 実務ではBigQueryパターンを使う

問題197: Rising Temperature
- Self JOINで時系列データを比較
- 日付計算の3つの方法（DATE_ADD, DATE_SUB, DATEDIFF）
- LAG関数という現代的な解法
- 実務では圧倒的にLAG/LEADを使う

総合:
- JOINパターンの実践
- MySQLとBigQueryの違いを理解
- 実務で使える具体的なパターンを習得
- ウィンドウ関数の威力を実感
*/


-- =============================================================================
-- 練習問題
-- =============================================================================

-- Q1: 問題183応用
-- 2回以上注文した顧客だけを抽出してください
-- ヒント: INNER JOIN + GROUP BY + HAVING COUNT(*) >= 2

-- Q2: 問題196応用
-- 性別と親の学歴の組み合わせで重複がある場合、
-- 数学スコアが最も高い学生だけを残してください
-- ヒント: ROW_NUMBER() OVER (PARTITION BY gender, parental_level_of_education ORDER BY math_score DESC)

-- Q3: 問題197応用
-- 前日より気温が5度以上上昇した日を見つけてください
-- ヒント: WHERE句を w1.temperature > w2.temperature + 5 に変更

-- Q4: LAG関数で問題197を解く
-- ヒント: LAG(temperature) OVER (ORDER BY recordDate)

-- Q5: 3日連続で気温が上昇した最初の日を見つける
-- ヒント: 2回Self JOINする（w1, w2, w3）または LAG を2回使う