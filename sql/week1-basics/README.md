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

### 4. BigQuery特有の注意点
- 公開データセットは州ごと・年ごとのことが多い
- クエリ処理時間を確認（パフォーマンス比較）
- ウィンドウ関数はサブクエリより高速

---

## 次週の予定

### Task18-19: ウィンドウ関数応用
- LAG/LEAD関数の深掘り
- 複雑な集約パターン

### Task20-36: SQL演習
- LeetCode SQL問題
- 分析SQLパターン学習

---

## 参考リンク

- [BigQuery公式ドキュメント - ウィンドウ関数](https://cloud.google.com/bigquery/docs/reference/standard-sql/window-function-calls)
- [BigQuery公開データセット](https://cloud.google.com/bigquery/public-data)
- [dbt公式チュートリアル](https://docs.getdbt.com)

---

**完了日**: 2025年10月15日（Task15-17完了）  
**学習時間**: 約2時間  
**難易度**: ★★★☆☆  
**重要度**: ★★★★★


## Task18完了: LAG/LEAD関数実践

### 学んだパターン

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

### 実務での活用
- 売上の前年比分析
- 在庫トレンドの把握
- KPIの推移分析
- 目標との差異分析

### 完了日: 2025-10-16