# Week 1 - LeetCode Easy SQL Problems

**期間**: 2025年10月14日 - 2025年10月20日  
**目標**: LeetCode Easy 15問を解き、JOIN/集約/CTEの基礎を固める

---

## 📊 概要

Week 1で取り組んだLeetCode Easy問題（6問完了）

### 進捗状況
- ✅ **Task20**: 3問完了（10/17）
- ✅ **Task23**: 3問完了（10/18）
- ⬜ **Task26**: 3問予定（10/19）
- ⬜ **Task29**: 3問予定（10/20）
- ⬜ **Task30**: 3問予定（10/21）

**合計**: 6/15問完了（40%）

---

## 🎯 学習テーマ

### 1. JOINパターン
- **LEFT JOIN**: 欠損データの検出
- **INNER JOIN**: 関連データの結合
- **Self JOIN**: 同じテーブルを2回参照（時系列比較）

### 2. 集約とグループ化
- **GROUP BY**: データのグループ化
- **HAVING**: 集約後の条件フィルタリング
- **集約関数**: COUNT, SUM, AVG, MIN, MAX

### 3. データ操作
- **DELETE**: 行の削除（MySQL）
- **CREATE OR REPLACE**: テーブルの置き換え（BigQuery）
- **ROW_NUMBER()**: 重複削除

### 4. 日付操作
- **DATE_ADD/DATE_SUB**: 日付の加減算
- **DATEDIFF**: 日付の差分計算

---

## 📋 問題一覧

### Task20: LeetCode Easy 3問（10/17完了）✅

#### 175: Combine Two Tables
- **難易度**: Easy
- **テーマ**: LEFT JOIN
- **学習ポイント**: 外部結合の基本、NULLの扱い
```sql
SELECT firstName, lastName, city, state
FROM Person
LEFT JOIN Address ON Person.personId = Address.personId;
```

**実務での応用**: 
- マスタテーブルと詳細テーブルの結合
- すべてのユーザーを表示し、注文履歴がない場合はNULL

---

#### 181: Employees Earning More Than Their Managers
- **難易度**: Easy
- **テーマ**: Self JOIN
- **学習ポイント**: 同じテーブルを異なる視点で見る
```sql
SELECT e1.name AS Employee
FROM Employee e1
LEFT JOIN Employee e2 ON e1.managerId = e2.id
WHERE e1.salary > e2.salary;
```

**実務での応用**:
- 階層データの比較（上司と部下、親と子）
- 組織構造の分析

---

#### 182: Duplicate Emails
- **難易度**: Easy
- **テーマ**: GROUP BY + HAVING
- **学習ポイント**: 重複データの検出
```sql
SELECT email AS Email
FROM Person
GROUP BY email
HAVING COUNT(*) >= 2;
```

**実務での応用**:
- データ品質チェック
- 重複レコードの検出

---

### Task23: LeetCode Easy 3問（10/18完了）✅

#### 183: Customers Who Never Order
- **難易度**: Easy
- **テーマ**: LEFT JOIN + NULL判定
- **学習ポイント**: 欠損データの検出
```sql
SELECT name AS Customers
FROM Customers c
LEFT JOIN Orders o ON c.id = o.customerId
WHERE o.id IS NULL;
```

**実務での応用**:
- 非アクティブユーザーの検出
- 未完了タスクの抽出
- データの欠損分析

---

#### 196: Delete Duplicate Emails
- **難易度**: Easy
- **テーマ**: DELETE（MySQL）/ CREATE OR REPLACE（BigQuery）
- **学習ポイント**: MySQLとBigQueryの違い

**MySQL版**:
```sql
DELETE p1
FROM Person p1
INNER JOIN Person p2 
WHERE p1.email = p2.email AND p1.id > p2.id;
```

**BigQuery版（推奨）**:
```sql
CREATE OR REPLACE TABLE Person AS
SELECT id, email
FROM (
    SELECT 
        id, email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS row_num
    FROM Person
)
WHERE row_num = 1;
```

**実務での応用**:
- データクレンジング
- 重複レコードの削除
- データ品質管理

**重要な学び**:
- BigQueryでは「削除」ではなく「作り直し」
- ROW_NUMBER()による重複削除パターン

---

#### 197: Rising Temperature
- **難易度**: Easy
- **テーマ**: Self JOIN + 日付比較
- **学習ポイント**: 時系列データの比較

**Self JOIN版**:
```sql
SELECT w1.id
FROM Weather w1
INNER JOIN Weather w2 
    ON w1.recordDate = DATE_ADD(w2.recordDate, INTERVAL 1 DAY)
WHERE w1.temperature > w2.temperature;
```

**LAG関数版（推奨）**:
```sql
SELECT id
FROM (
    SELECT 
        id, temperature,
        LAG(temperature) OVER (ORDER BY recordDate) AS prev_temp,
        LAG(recordDate) OVER (ORDER BY recordDate) AS prev_date
    FROM Weather
)
WHERE temperature > prev_temp
  AND DATE_DIFF(recordDate, prev_date, DAY) = 1;
```

**実務での応用**:
- 売上の前日比較
- KPIの日次変動分析
- 異常値の検出
- トレンド分析

**重要な学び**:
- Self JOINよりLAG/LEAD関数の方が直感的
- 実務では圧倒的にウィンドウ関数を使う

---

### Task26: LeetCode Easy 3問（10/19予定）

- **577**: 
- **584**: 
- **586**: 

---

### Task29: LeetCode Easy 3問（10/20予定）

- **595**: 
- **596**: 
- **607**: 

---

### Task30: LeetCode Easy 3問（10/21予定）

- **608**: 
- **610**: 
- **619**: 

---

## 🎓 学習ポイントまとめ

### JOINの使い分け

| JOINの種類 | 用途 | NULL扱い |
|-----------|------|---------|
| **INNER JOIN** | 両方にマッチする行のみ | NULLは除外 |
| **LEFT JOIN** | 左側のすべての行を保持 | 右側がNULLでも保持 |
| **Self JOIN** | 同じテーブルを2回参照 | 用途次第 |

### GROUP BY vs WHERE vs HAVING
```sql
SELECT カラム
FROM テーブル
WHERE 条件1           -- 集約前のフィルタ（行単位）
GROUP BY カラム       -- グループ化
HAVING 条件2          -- 集約後のフィルタ（グループ単位）
```

**違い**:
- **WHERE**: 集約**前**に行をフィルタ
- **HAVING**: 集約**後**にグループをフィルタ

### MySQLとBigQueryの主な違い

| 項目 | MySQL | BigQuery |
|------|-------|----------|
| DELETE文 | ✅ 自由に使える | ⚠️ 制限あり |
| 重複削除 | DELETE + Self JOIN | CREATE OR REPLACE |
| 日付関数 | DATEDIFF(d1, d2) | DATE_DIFF(d1, d2, DAY) |
| 用途 | トランザクション処理 | 大規模データ分析 |

### ウィンドウ関数 vs Self JOIN

**Self JOIN**:
- 古典的な方法
- LeetCodeでよく使われる
- やや複雑

**ウィンドウ関数（LAG/LEAD）**:
- 現代的な方法
- 直感的で読みやすい
- パフォーマンスが良い
- **実務では圧倒的にこちらを使う**

---

## 💡 実務への応用

### パターン1: 欠損データの検出
```sql
-- LEFT JOIN + NULL で「〜がない」を見つける
SELECT a.*
FROM TableA a
LEFT JOIN TableB b ON a.id = b.foreign_id
WHERE b.id IS NULL;
```

**用途**:
- 注文していない顧客
- ログインしていないユーザー
- 未完了のタスク

---

### パターン2: 重複の検出と削除
```sql
-- BigQuery版: ROW_NUMBER()で重複削除
CREATE OR REPLACE TABLE table_name AS
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY key ORDER BY id) AS rn
    FROM table_name
)
WHERE rn = 1;
```

**用途**:
- データクレンジング
- マスタデータの整理
- データ品質管理

---

### パターン3: 時系列データの比較
```sql
-- LAG関数で前日比較
SELECT 
    date,
    value,
    value - LAG(value) OVER (ORDER BY date) AS daily_change
FROM metrics;
```

**用途**:
- 売上の前日比
- KPIの変動分析
- トレンド検出

---

## 📂 ファイル構成
```
week1-leetcode/
├── README.md                        # このファイル
├── task20-easy-175-181-182.sql     # Task20の3問
└── task23-easy-183-196-197.sql     # Task23の3問（完全版）
```

---

## 🎯 次のステップ

### Week 1残りのタスク
- [ ] Task26: LeetCode Easy 3問（10/19）
- [ ] Task29: LeetCode Easy 3問（10/20）
- [ ] Task30: LeetCode Easy 3問（10/21）

### Week 2以降
- dbt実装（データモデリング）
- Looker Studio可視化
- ポートフォリオ完成

---

## 📚 参考リソース

### LeetCode
- [Database Problems](https://leetcode.com/problemset/database/)
- [SQL Study Plan](https://leetcode.com/study-plan/sql/)

### 学習ドキュメント
- [BigQuery公式ドキュメント](https://cloud.google.com/bigquery/docs)
- [MySQL公式ドキュメント](https://dev.mysql.com/doc/)

### 関連ファイル
- `sql/sql-learning-notes.md` - 詳細な学習ノート
- `sql/week1-basics/` - SQL基礎学習（CTE、ウィンドウ関数）

---

**最終更新**: 2025年10月18日  
**次回更新予定**: Task26完了後（2025年10月19日）