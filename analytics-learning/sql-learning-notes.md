# SQL学習ノート - 完全版

作成日: 2025-10-14  
最終更新: 2025-10-18

---

## 📋 目次

1. Week 0: 基本構文復習（LeetCode Easy）
2. Task14: MySQLとBigQueryの違い
3. Task15: BigQueryで簡単なクエリ実行
4. Task16: ウィンドウ関数基礎理論
5. Task17: ウィンドウ関数実践
6. Task18: LAG/LEAD関数
7. Task19: ウィンドウ関数応用（集約）
8. Task20: LeetCode Easy 3問（JOIN特訓）
9. Task21: CTE基本構文
10. Task22: 複数CTEの組み合わせ

---

## Week 0: 基本構文復習（LeetCode Easy）

### 595. Big Countries
**学習日**: 2025-10-14

**テーマ**: OR条件の使い方
```sql
SELECT name, population, area
FROM World
WHERE area >= 3000000 OR population >= 25000000;
```

**学習ポイント**:
- OR条件で複数条件のいずれかを満たす行を抽出
- カラム名は正確に指定する

---

### 1757. Recyclable and Low Fat Products
**学習日**: 2025-10-14

**テーマ**: AND条件
```sql
SELECT product_id
FROM Products
WHERE low_fats = 'Y' AND recyclable = 'Y';
```

**学習ポイント**:
- AND条件で複数条件をすべて満たす行を抽出
- 文字列の比較はシングルクォート `'Y'` を使用

---

### 584. Find Customer Referee
**学習日**: 2025-10-14

**テーマ**: NULL値の扱い
```sql
SELECT name
FROM Customer
WHERE referee_id IS NULL OR referee_id != 2;
```

**重要な落とし穴**:
- `referee_id != 2` だけでは**NULLを除外してしまう**
- NULLは `IS NULL` で明示的にチェックする必要がある
- `!= 2` はNULLに対して FALSE を返す（SQL の3値論理）

---

## Task14: MySQLとBigQueryの違い

**学習日**: 2025-10-16  
**所要時間**: 30分

### 主な違い

| 項目 | MySQL | BigQuery |
|------|-------|----------|
| 用途 | OLTP（トランザクション処理） | OLAP（分析処理） |
| データ量 | GB〜TB | TB〜PB |
| クエリ速度 | 小規模データで高速 | 大規模データで超高速 |
| 料金体系 | サーバー課金 | クエリ量課金 |
| インデックス | 必要 | 不要（カラムナストレージ） |

### 構文の違い

#### 1. 日付関数
```sql
-- MySQL
SELECT DATE_FORMAT(NOW(), '%Y-%m-%d');

-- BigQuery
SELECT FORMAT_DATE('%Y-%m-%d', CURRENT_DATE());
```

#### 2. 文字列結合
```sql
-- MySQL
SELECT CONCAT(first_name, ' ', last_name);

-- BigQuery
SELECT CONCAT(first_name, ' ', last_name);  -- 同じ
-- または
SELECT first_name || ' ' || last_name;
```

#### 3. LIMIT句
```sql
-- MySQL
SELECT * FROM table LIMIT 10 OFFSET 20;

-- BigQuery
SELECT * FROM table LIMIT 10 OFFSET 20;  -- 同じ
```

### 学習ポイント
- BigQueryは大規模データ分析に特化
- 基本的なSQLはほぼ同じ
- 日付関数が一番違う

---

## Task15: BigQueryで簡単なクエリ実行

**学習日**: 2025-10-16  
**所要時間**: 30分

### 実行したクエリ

#### 1. データ件数確認
```sql
SELECT COUNT(*) AS total_rows
FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`;
-- 結果: 1000行
```

#### 2. 基本的なSELECT
```sql
SELECT 
    gender,
    math_score,
    reading_score,
    writing_score
FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
LIMIT 10;
```

#### 3. 集約関数
```sql
SELECT 
    gender,
    COUNT(*) AS student_count,
    ROUND(AVG(math_score), 2) AS avg_math,
    ROUND(AVG(reading_score), 2) AS avg_reading
FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
GROUP BY gender;
```

**結果**:
| gender | student_count | avg_math | avg_reading |
|--------|--------------|----------|-------------|
| female | 518 | 63.63 | 72.61 |
| male | 482 | 68.73 | 65.47 |

### 学習ポイント
- BigQueryのテーブル指定は `` `project.dataset.table` ``
- 集約関数とGROUP BYの基本
- ROUNDで小数点を制御

---

## Task16: ウィンドウ関数基礎理論

**学習日**: 2025-10-16  
**所要時間**: 30分

### ウィンドウ関数とは？
- 集約関数と違い、**行を減らさない**
- 各行に対して計算結果を追加する
- `OVER()` 句を使う

### 基本構文
```sql
SELECT 
    カラム,
    集約関数() OVER (
        PARTITION BY グループ化カラム
        ORDER BY 並び替えカラム
    ) AS 結果カラム
FROM テーブル;
```

### 主要なウィンドウ関数

#### 1. ROW_NUMBER()
```sql
SELECT 
    gender,
    math_score,
    ROW_NUMBER() OVER (PARTITION BY gender ORDER BY math_score DESC) AS row_num
FROM raw_student_performance
LIMIT 10;
```
**用途**: 各グループ内で連番を振る

---

#### 2. RANK()
```sql
SELECT 
    gender,
    math_score,
    RANK() OVER (PARTITION BY gender ORDER BY math_score DESC) AS rank
FROM raw_student_performance
LIMIT 10;
```
**用途**: 順位付け（同点は同じ順位、次は飛ばす）

---

#### 3. DENSE_RANK()
```sql
SELECT 
    gender,
    math_score,
    DENSE_RANK() OVER (PARTITION BY gender ORDER BY math_score DESC) AS dense_rank
FROM raw_student_performance
LIMIT 10;
```
**用途**: 順位付け（同点は同じ順位、次は続く）

---

### ROW_NUMBER vs RANK vs DENSE_RANK の違い

**例**: 数学スコアが 100, 95, 95, 90 の場合

| スコア | ROW_NUMBER | RANK | DENSE_RANK |
|--------|-----------|------|------------|
| 100 | 1 | 1 | 1 |
| 95 | 2 | 2 | 2 |
| 95 | 3 | 2 | 2 |
| 90 | 4 | 4 | 3 |

### 学習ポイント
- PARTITION BY: グループ化
- ORDER BY: 並び替え
- ウィンドウ関数は行を減らさない

---

## Task17: ウィンドウ関数実践

**学習日**: 2025-10-16  
**所要時間**: 30分

### 実践例1: 性別ごとのトップ5
```sql
WITH ranked_students AS (
    SELECT 
        gender,
        math_score,
        reading_score,
        RANK() OVER (PARTITION BY gender ORDER BY math_score DESC) AS rank_in_gender
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
)
SELECT *
FROM ranked_students
WHERE rank_in_gender <= 5
ORDER BY gender, rank_in_gender;
```

### 実践例2: 累積カウント
```sql
SELECT 
    gender,
    math_score,
    COUNT(*) OVER (PARTITION BY gender ORDER BY math_score) AS cumulative_count
FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
ORDER BY gender, math_score
LIMIT 20;
```

### 学習ポイント
- CTEとウィンドウ関数の組み合わせ
- WHERE句でランクをフィルタリング
- 実用的なトップN抽出パターン

---

## Task18: LAG/LEAD関数

**学習日**: 2025-10-16  
**所要時間**: 30分

### LAG()関数
**用途**: 前の行の値を取得
```sql
SELECT 
    gender,
    math_score,
    LAG(math_score) OVER (PARTITION BY gender ORDER BY math_score) AS prev_score,
    math_score - LAG(math_score) OVER (PARTITION BY gender ORDER BY math_score) AS diff
FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
ORDER BY gender, math_score
LIMIT 20;
```

**結果イメージ**:
| gender | math_score | prev_score | diff |
|--------|-----------|-----------|------|
| female | 50 | NULL | NULL |
| female | 52 | 50 | 2 |
| female | 55 | 52 | 3 |

---

### LEAD()関数
**用途**: 次の行の値を取得
```sql
SELECT 
    gender,
    math_score,
    LEAD(math_score) OVER (PARTITION BY gender ORDER BY math_score) AS next_score
FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
ORDER BY gender, math_score
LIMIT 20;
```

### デフォルト値の指定
```sql
SELECT 
    gender,
    math_score,
    LAG(math_score, 1, 0) OVER (PARTITION BY gender ORDER BY math_score) AS prev_score
FROM raw_student_performance;
```
- 第2引数: 何行前/後か（デフォルト1）
- 第3引数: NULLの代わりに使う値

### 学習ポイント
- 時系列データの変化を計算
- 前後の行との比較
- NULLの扱いに注意

---

## Task19: ウィンドウ関数応用（集約）

**学習日**: 2025-10-16  
**所要時間**: 30分

### SUM() OVER()
**用途**: 累積合計
```sql
SELECT 
    gender,
    math_score,
    SUM(math_score) OVER (PARTITION BY gender ORDER BY math_score) AS cumulative_sum
FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
ORDER BY gender, math_score
LIMIT 20;
```

---

### AVG() OVER()
**用途**: 移動平均
```sql
SELECT 
    gender,
    math_score,
    AVG(math_score) OVER (
        PARTITION BY gender 
        ORDER BY math_score 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3
FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
ORDER BY gender, math_score
LIMIT 20;
```

**ROWS BETWEEN の意味**:
- `2 PRECEDING`: 2行前から
- `CURRENT ROW`: 現在の行まで
- つまり3行の移動平均

---

### COUNT() OVER()
**用途**: 累積カウント
```sql
SELECT 
    gender,
    math_score,
    COUNT(*) OVER (PARTITION BY gender ORDER BY math_score) AS count_up_to_here
FROM raw_student_performance
ORDER BY gender, math_score
LIMIT 20;
```

### 学習ポイント
- ウィンドウ関数で累積計算
- ROWS BETWEEN でフレームを指定
- 移動平均などの時系列分析に有用

---

## Task20: LeetCode Easy 3問（JOIN特訓）

**学習日**: 2025-10-17  
**所要時間**: 45分

### 問題175: Combine Two Tables
**テーマ**: LEFT JOIN
```sql
SELECT firstName, lastName, city, state
FROM Person
LEFT JOIN Address ON Person.personId = Address.personId;
```

**学習ポイント**:
- LEFT JOINは左側のテーブル（Person）のすべての行を保持
- 右側（Address）にマッチがなければ NULL
- 住所がない人も結果に含まれる

---

### 問題181: Employees Earning More Than Their Managers
**テーマ**: Self JOIN
```sql
SELECT e1.name AS Employee
FROM Employee e1
LEFT JOIN Employee e2 ON e1.managerId = e2.id
WHERE e1.salary > e2.salary;
```

**学習ポイント**:
- Self JOIN: 同じテーブルを2回参照
- エイリアス（e1, e2）で区別
- 従業員と上司の関係を表現

---

### 問題182: Duplicate Emails
**テーマ**: GROUP BY + HAVING
```sql
SELECT email AS Email
FROM Person
GROUP BY email
HAVING COUNT(*) >= 2;
```

**学習ポイント**:
- GROUP BYでグループ化
- HAVINGは集約後の条件
- WHEREは集約前、HAVINGは集約後

---

## Task21: CTE基本構文（実データ版）

**学習日**: 2025-10-18  
**所要時間**: 30分

### CTEとは？
- Common Table Expression（共通テーブル式）
- WITH句で一時的なテーブルを定義
- クエリの可読性を大幅に向上

### 基本構文
```sql
WITH cte_name AS (
    SELECT ...
)
SELECT * FROM cte_name;
```

### メリット
1. **可読性**: 複雑なクエリを分解できる
2. **再利用**: 同じサブクエリを何度も書かない
3. **メンテナンス性**: 変更が1箇所で済む

### 実践例: 平均以上の学生を抽出
```sql
WITH avg_math AS (
    SELECT AVG(math_score) AS average_math
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
)
SELECT 
    s.gender,
    s.math_score,
    a.average_math,
    s.math_score - a.average_math AS difference
FROM `mystic-now-474722-r4.education_analytics.raw_student_performance` s
CROSS JOIN avg_math a
WHERE s.math_score >= a.average_math
LIMIT 10;
```

### CROSS JOINの役割
- すべての学生に平均点の情報を追加
- 1行のテーブル（平均点）を全学生にコピー

### 学習ポイント
- CTEはサブクエリの代替
- 名前をつけることで再利用可能
- CROSS JOINで全行に情報を追加

---

## Task22: 複数CTEの組み合わせ（実データ版）

**学習日**: 2025-10-18  
**所要時間**: 30分

### 複数CTEの構文
```sql
WITH 
cte1 AS (...),
cte2 AS (...),
cte3 AS (SELECT ... FROM cte1)
SELECT * FROM cte3;
```

### 重要ポイント
- 各CTEはカンマで区切る
- 前のCTEを後のCTEで参照できる
- 段階的な処理が可能

### 実践例: 3段階の絞り込み
```sql
WITH 
-- Step 1: テスト準備コースを受けた人
prep_students AS (
    SELECT *
    FROM `mystic-now-474722-r4.education_analytics.raw_student_performance`
    WHERE test_preparation_course = 'completed'
),
-- Step 2: 平均点を計算
student_averages AS (
    SELECT 
        gender,
        parental_level_of_education,
        ROUND((math_score + reading_score + writing_score) / 3.0, 2) AS avg_score
    FROM prep_students
),
-- Step 3: 80点以上
high_performers AS (
    SELECT *
    FROM student_averages
    WHERE avg_score >= 80
)
-- 最終結果
SELECT 
    parental_level_of_education,
    COUNT(*) AS count,
    ROUND(AVG(avg_score), 2) AS avg
FROM high_performers
GROUP BY parental_level_of_education
ORDER BY avg DESC;
```

### 学習ポイント
- 複雑なロジックを段階的に分解
- 各ステップが理解しやすい
- デバッグも容易（各CTEを個別に実行できる）

---

## 📊 週次まとめ

### Week 1で学んだこと
1. ✅ MySQLとBigQueryの違い
2. ✅ ウィンドウ関数（ROW_NUMBER, RANK, LAG, LEAD）
3. ✅ JOIN（LEFT JOIN, Self JOIN）
4. ✅ CTE（単一・複数）
5. ✅ GROUP BY + HAVING

### 次のステップ
- Week 2: dbt実装
- Week 3: Looker Studio可視化

---

最終更新: 2025-10-18