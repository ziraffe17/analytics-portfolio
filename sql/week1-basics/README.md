# Week 1: SQL基礎学習

## 概要
BigQueryを使ったSQL基礎学習の記録

## 学習期間
2025年10月15日 〜 2025年10月22日（予定）

## 実行環境
- **プラットフォーム**: Google Cloud Platform
- **プロジェクト**: mystic-now-474722-r4
- **データセット**: sql_learning
- **SQL方言**: BigQuery標準SQL
- **使用データ**: `bigquery-public-data.usa_names.usa_1910_current`

---

## 📊 進捗状況（2025-10-19時点）

### 完了タスク
- ✅ Task15: MySQLとBigQueryの違い理解（10/15）
- ✅ Task16: ウィンドウ関数基礎理論（10/15）
- ✅ Task17: ウィンドウ関数基礎実践（10/16）
- ✅ Task18: LAG/LEAD関数（10/16）
- ✅ Task19: ウィンドウ関数応用集約（10/17）
- ✅ Task21: CTE基本構文学習（10/18）
- ✅ Task22: 複数CTEの組み合わせ（10/18）
- ✅ Task24: 集約関数の応用学習（10/19）★NEW

### 進行中タスク
- ⬜ Task25: HAVING句の活用（10/19）
- ⬜ Task26: LeetCode Easy 3問（10/19）
- ⬜ Task27-29: ウィンドウ関数総仕上げ（10/20）

---

## ファイル一覧

### task15-bigquery-basics.sql
**学習内容:**
- BigQueryの基本的なクエリ
- SELECT、WHERE、GROUP BY等の基本構文
- 日付関数、文字列関数
- 公開データセットの活用

**主なクエリ:**
- 現在の日時取得
- 文字列操作（CONCAT、UPPER、LENGTH）
- 日付操作（DATE_ADD、DATE_DIFF）
- 人気の名前トップ10（2020年）
- LIKE句で前方一致検索
- CASE式で年代別集計

**学んだこと:**
- BigQueryの基本構文
- データの粒度に注意（州ごとのデータ）
- GROUP BYの重要性

---

### task16-window-functions-theory.sql
**学習内容:**
- ウィンドウ関数の基本概念と構文
- ランキング系関数（ROW_NUMBER、RANK、DENSE_RANK）
- 集約系関数（SUM、AVG、COUNT）
- 位置参照系関数（LAG、LEAD）
- PARTITION BY の使い方
- ROWS BETWEEN 句の詳細

**主なパターン:**
```sql
-- 基本構文
関数名() OVER (
  PARTITION BY 列名
  ORDER BY 列名
  ROWS BETWEEN ...
)
```

**学んだこと:**
- ウィンドウ関数は行数を減らさない
- PARTITION BYでグループごとに独立計算
- LAGで前年比較、LEADで将来予測
- 実務での活用パターン

---

### task17-window-functions-practice.sql
**学習内容:**
- BigQueryでウィンドウ関数を実際に実行
- データの粒度問題の発見と修正
- 実務パターンの実装

**実装したクエリ:**
1. 性別ごとのトップ5の名前
2. 年次累積合計
3. 3年移動平均
4. 前年比較と成長率
5. 顧客購買履歴分析（LTV計算）
6. トップ5の名前の10年間の推移
7. ランキング関数の比較

**重要な発見:**
`usa_names` テーブルは州ごとのデータであることに気づき、すべてのクエリを修正

**修正前（誤り）:**
```sql
SELECT year, name, number
FROM usa_names
WHERE name = 'Emma'
ORDER BY year;
-- 結果: 同じ年に複数行（州ごと）
```

**修正後（正しい）:**
```sql
WITH yearly_totals AS (
  SELECT year, SUM(number) AS total_count
  FROM usa_names
  WHERE name = 'Emma'
  GROUP BY year
)
SELECT year, total_count
FROM yearly_totals;
-- 結果: 各年1行（全米合計）
```

**学んだこと:**
- データの粒度を必ず確認
- 間違った結果の見分け方
- GROUP BYで集計してからウィンドウ関数
- CTEで段階的にクエリを構築

---

### task18-lag-lead.sql
**学習内容:**
- LAG/LEAD関数の実践
- 前年比・前月比の計算
- トレンド分析

**実装したパターン:**

#### 1. 基本的な前年比較
```sql
LAG(total_count, 1) OVER (ORDER BY year)
```

#### 2. 複数年前との比較
```sql
LAG(total_count, 3) OVER (ORDER BY year)  -- 3年前
```

#### 3. トレンド判定
- 3期連続の増減を判定
- CASE式でトレンドを分類

#### 4. LEAD（将来予測）
```sql
LEAD(total_count, 1) OVER (ORDER BY year)
```

#### 5. ピークからの変化率
```sql
MAX(total_count) OVER ()  -- 全期間の最大値
```

#### 6. PARTITION BYで複数エンティティ比較
```sql
LAG(...) OVER (PARTITION BY name ORDER BY year)
```

**実務での活用:**
- 売上の前年比分析
- 在庫トレンドの把握
- KPIの推移分析
- 目標との差異分析

**完了日**: 2025-10-16

---

### task19-window-aggregation.sql
**学習内容:**
- ROWS BETWEEN句の詳細
- 移動平均・累積統計
- シェア分析

**ROWS BETWEEN句の基本:**

#### 指定方法
- `UNBOUNDED PRECEDING`: 最初の行
- `n PRECEDING`: n行前
- `CURRENT ROW`: 現在の行
- `n FOLLOWING`: n行後
- `UNBOUNDED FOLLOWING`: 最後の行

**実装したパターン:**

#### 1. 移動平均
- 3年、5年、7年移動平均
- 中央移動平均（前後含む）

#### 2. 累積統計
- 累積合計
- 累積平均
- これまでの最大・最小値

#### 3. シェア分析
- 累積シェア
- 単年シェア

#### 4. 変動分析
- 標準偏差
- 変動係数

#### 5. 目標達成率
- 前年実績との比較
- 移動平均との比較

**実務での活用:**
- 売上トレンド分析
- KPI累積進捗管理
- ボラティリティ分析
- 目標達成率モニタリング

**完了日**: 2025-10-17

---

### task21-cte-basics.sql
**学習内容:**
- CTE（Common Table Expression）の基本
- WITH句の使い方
- 複数CTEの連鎖

**完了日**: 2025-10-18

---

### task22-multiple-cte.sql
**学習内容:**
- 複数CTEの組み合わせ
- CTEの参照関係
- 段階的なデータ加工

**完了日**: 2025-10-18

---

### task24-aggregation-patterns.sql ★NEW
**学習内容:**
- 集約関数の応用パターン（5パターン）
- 条件付き集約、統計量計算、割合計算
- 複数軸グループ化、ビジネスKPI計算

**実装した5つのパターン:**

#### Pattern 1: 条件付き集約
- `COUNTIF()` を使った効率的な集計
- カテゴリ別の件数を横並びで表示
- 実務例: 出席状況の詳細レポート
```sql
SELECT 
    user_id,
    COUNTIF(status = 'present') AS present_days,
    COUNTIF(status = 'absent') AS absent_days,
    COUNTIF(status = 'late') AS late_days,
    ROUND(COUNTIF(status = 'present') * 100.0 / COUNT(*), 2) AS attendance_rate
FROM attendance_records
GROUP BY user_id;
```

#### Pattern 2: 統計量の計算
- 記述統計量（平均、標準偏差、四分位数）
- `APPROX_QUANTILES()` でパーセンタイル計算
- データ品質チェック、異常値検出
```sql
SELECT 
    subject,
    ROUND(AVG(score), 2) AS mean,
    ROUND(STDDEV(score), 2) AS std_dev,
    APPROX_QUANTILES(score, 4)[OFFSET(2)] AS median
FROM test_scores
GROUP BY subject;
```

#### Pattern 3: 割合・パーセンテージ
- ウィンドウ関数で全体に対する割合を計算
- `SUM() OVER ()` で全体合計を取得
- 構成比・達成率の可視化
```sql
SELECT 
    category,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM data
GROUP BY category;
```

#### Pattern 4: 複数軸でのグループ化
- `DATE_TRUNC()` で時系列データを月単位に集約
- 月×科目など多次元分析
- `LAG()` で前月比を計算
```sql
SELECT 
    DATE_TRUNC(test_date, MONTH) AS month,
    subject,
    ROUND(AVG(score), 2) AS avg_score,
    LAG(ROUND(AVG(score), 2)) OVER (
        PARTITION BY subject 
        ORDER BY DATE_TRUNC(test_date, MONTH)
    ) AS prev_month_avg
FROM test_scores
GROUP BY month, subject;
```

#### Pattern 5: ビジネスKPIの計算
- 達成率、評価判定の自動算出
- 月次訓練レポート（あゆみSaaS風）
- 経営判断に使える指標
```sql
SELECT 
    user_id,
    month,
    ROUND(SUM(training_minutes) / 60.0, 2) AS total_hours,
    COUNTIF(training_minutes >= 60) AS days_over_1hour,
    CASE 
        WHEN total_hours >= 60 AND achievement_rate >= 80 THEN '目標達成'
        WHEN total_hours >= 40 THEN '要努力'
        ELSE '要支援'
    END AS performance_status
FROM training_data
GROUP BY user_id, month;
```

**BigQuery特有の関数:**
- `COUNTIF()`: 条件付きカウント
- `SAFE_DIVIDE()`: 0除算エラー回避
- `APPROX_QUANTILES()`: パーセンタイル計算
- `DATE_TRUNC()`: 日付の切り捨て

**ベストプラクティス:**
1. NULLに注意: `COUNT(*)` vs `COUNT(column)`
2. 0除算対策: `SAFE_DIVIDE(numerator, denominator)`
3. ウィンドウ関数: `SUM() OVER ()` で全体集計
4. `UNION ALL` でサンプルデータ作成

**実務での応用:**
- パターン1: ステータス別レポート、ダッシュボード
- パターン2: データ品質チェック、異常値検出
- パターン3: 市場シェア分析、目標達成率
- パターン4: 月次レポート、前月比分析
- パターン5: KPIダッシュボード、自動アラート

**ポートフォリオへの応用:**
- プロジェクト1（教育データ分析基盤）: 成績カテゴリ別分析
- プロジェクト2（あゆみSaaS）: 月次KPIレポート、利用者進捗管理

**完了日**: 2025-10-19

---

## 実行結果の例

### Emmaという名前の推移（2015-2020）
```
year | current_year | prev_year | yoy_change | yoy_growth_rate
2015 | 20455        | NULL      | NULL       | NULL
2016 | 19471        | 20455     | -984       | -4.8%
2017 | 19800        | 19471     | 329        | 1.7%
2018 | 18688        | 19800     | -1112      | -5.6%
2019 | 17184        | 18688     | -1504      | -8.0%
2020 | 15581        | 17184     | -1603      | -9.3%
```

**洞察:** Emmaという名前は2015年以降、毎年減少傾向

---

## 学んだ重要な教訓

### 1. データの粒度を必ず確認
- テーブル構造を理解してから分析を開始
- ドキュメントを読む習慣をつける
- サンプルクエリで確認

### 2. 間違った結果の見分け方
- 同じ年に複数行 → 粒度が間違っている
- 累積値が同じ → GROUP BYが必要
- 予想と違う結果 → まず粒度を疑う

### 3. ウィンドウ関数のベストプラクティス
- GROUP BYで集計してからウィンドウ関数
- CTEで段階的に構築
- PARTITION BYで適切にグループ分け
- コメントで意図を明確に

### 4. 集約関数のベストプラクティス（NEW）
- 条件付き集約で効率化（COUNTIF）
- NULLと0除算に注意
- ウィンドウ関数で全体集計（SUM() OVER ()）
- 実務では複数パターンを組み合わせる

### 5. BigQuery特有の注意点
- 公開データセットは州ごと・年ごとのことが多い
- クエリ処理時間を確認（パフォーマンス比較）
- ウィンドウ関数はサブクエリより高速
- `UNION ALL` でサンプルデータを作成できる

---

## 次の予定

### Task25-29: SQL基礎総仕上げ
- ✅ Task24: 集約関数の応用（完了）
- ⬜ Task25: HAVING句の活用（10/19）
- ⬜ Task26: LeetCode Easy 3問（10/19）
- ⬜ Task27-29: ウィンドウ関数総仕上げ（10/20）

### Week 2（10/21-10/27）: dbt実装
- ポートフォリオ2本の実装開始
- BigQueryとdbt Cloudの連携
- データモデリング実践

---

## Task38完了: あゆみDB構造・ER図作成

### プロジェクト概要
就労移行支援事業所向けSaaS「あゆみ」のデータベース設計

### 主要テーブル（10テーブル）

#### 1. users（利用者マスタ）
- 利用者の基本情報
- 機微情報は暗号化保存
- ソフトデリート対応

#### 2. staffs（スタッフ）
- RBAC（admin/staff）
- メールベース2FA対応

#### 3. attendance_plans（出席予定）
- 午前/午後/終日の3区分
- テンプレート機能

#### 4. attendance_records（出席実績）
- 承認ワークフロー
- 月次締めロック機能

#### 5. daily_reports_morning（朝日報）
- 睡眠・食事・ストレス評価
- 健康管理・メンタルヘルスケア

#### 6. daily_reports_evening（夕日報）
- 訓練内容・振り返り
- 自己評価機能

#### 7. interviews（面談記録）
- スタッフと利用者の面談

#### 8. audit_logs（監査ログ）
- 全操作を記録
- GDPR対応

#### 9. holidays（祝日マスタ）
- 日本の祝日情報

#### 10. settings（設定マスタ）
- Key-Valueストア

### リレーション
- users → attendances (1:N)
- users → daily_reports (1:N)
- users → interviews (1:N)
- staffs → audit_logs (1:N)

### セキュリティ対策
- パスワードハッシュ化
- 2要素認証（スタッフ）
- 監査ログ
- 暗号化保存
- ソフトデリート

### タイムゾーン方針
- DB保存: UTC
- 表示: JST（アプリ層変換）

**完了日**: 2025-10-17

---

## 参考リンク

- [BigQuery公式ドキュメント - 集約関数](https://cloud.google.com/bigquery/docs/reference/standard-sql/aggregate_functions)
- [BigQuery公式ドキュメント - ウィンドウ関数](https://cloud.google.com/bigquery/docs/reference/standard-sql/window-function-calls)
- [BigQuery公開データセット](https://cloud.google.com/bigquery/public-data)
- [dbt公式チュートリアル](https://docs.getdbt.com)

---

**最終更新**: 2025年10月21日（Task24完了）  
**累計学習時間**: 約8時間  
**次のタスク**: Task25（HAVING句の活用）