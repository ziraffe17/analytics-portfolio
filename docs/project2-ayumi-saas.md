# プロジェクト2: 就労支援SaaS『あゆみ』データ分析基盤

## 概要
就労移行支援事業所向けSaaS『あゆみ』の運用データを活用したデータ分析基盤

## 目的
- 実務データを活用したデータ分析スキルの証明
- MySQL → BigQuery のETL/ELT実装
- 福祉×データという差別化された専門性のアピール
- ビジネスインパクトのあるダッシュボード構築

## 技術スタック
- **アプリケーション**: Laravel (PHP)
- **運用DB**: MySQL 8.0
- **DWH**: Google BigQuery
- **ETL/ELT**: Cloud Composer (Airflow) または手動バッチ
- **データ変換**: dbt (data build tool)
- **可視化**: Looker Studio
- **バージョン管理**: Git/GitHub

## システムアーキテクチャ
```
Laravel App → MySQL (Production) → ETL → BigQuery (DWH) → dbt → Looker Studio
```

### データフロー
1. **運用フェーズ**: Laravel AppがMySQLに書き込み
2. **ETLフェーズ**: 日次バッチでBigQueryに転送
3. **変換フェーズ**: dbtでデータ変換・集約
4. **分析フェーズ**: Looker Studioで可視化

## データベース設計

### 主要テーブル（10テーブル）

#### 1. users（利用者マスタ）
- 利用者の基本情報
- PII（個人識別情報）は暗号化
- ソフトデリート対応

#### 2. staffs（スタッフマスタ）
- 管理者・スタッフアカウント
- RBAC（Role-Based Access Control）
- 2要素認証対応

#### 3. attendance_plans（出席予定）
- 月次の出席計画
- 午前/午後/終日の区分

#### 4. attendance_records（出席実績）
- 実際の出席記録
- 承認ワークフロー
- 月次締めロック機能

#### 5. daily_reports_morning（朝日報）
- 睡眠時間
- 食事満足度
- ストレスレベル（1-5）
- 当日の目標

#### 6. daily_reports_evening（夕日報）
- 訓練内容
- 自己評価（1-5）
- 振り返りコメント

#### 7. interviews（面談記録）
- スタッフとの面談履歴
- 目標設定・進捗確認

#### 8. audit_logs（監査ログ）
- 全操作履歴
- GDPR・個人情報保護対応

#### 9. holidays（祝日マスタ）
- 日本の祝日データ

#### 10. settings（設定マスタ）
- システム設定値

### ER図
詳細は `ayumi-db-design.md` を参照

## dbtモデル設計

### データ層構造
```
dbt-ayumi/
├── models/
│   ├── staging/
│   │   ├── _staging.yml
│   │   ├── stg_users.sql
│   │   ├── stg_attendance_records.sql
│   │   ├── stg_daily_reports_morning.sql
│   │   └── stg_daily_reports_evening.sql
│   ├── intermediate/
│   │   ├── _intermediate.yml
│   │   ├── int_monthly_attendance.sql
│   │   ├── int_health_metrics.sql
│   │   └── int_training_hours.sql
│   └── mart/
│       ├── _mart.yml
│       ├── mart_attendance_summary.sql
│       ├── mart_mental_health_trend.sql
│       └── mart_training_effectiveness.sql
└── dbt_project.yml
```

### Layer 1: Staging（クリーニング）

#### `stg_users`
```sql
-- 利用者の基本情報をクリーニング
-- PII暗号化解除（分析用には不要な場合はIDのみ）
-- タイムゾーン変換（UTC → JST）
SELECT
    user_id,
    nickname,  -- 実名は使わない
    DATE(registered_at, 'Asia/Tokyo') as registered_date,
    is_active
FROM {{ source('raw', 'raw_users') }}
WHERE deleted_at IS NULL
```

#### `stg_attendance_records`
```sql
-- 出席実績のクリーニング
SELECT
    attendance_id,
    user_id,
    DATE(attendance_date, 'Asia/Tokyo') as attendance_date,
    status,  -- present/absent/late/early_leave
    time_slot,  -- morning/afternoon/full_day
    approved_at
FROM {{ source('raw', 'raw_attendance_records') }}
WHERE deleted_at IS NULL
```

#### `stg_daily_reports_morning`
```sql
-- 朝日報のクリーニング
SELECT
    report_id,
    user_id,
    DATE(report_date, 'Asia/Tokyo') as report_date,
    sleep_hours,
    meal_satisfaction,  -- 1-5
    stress_level,  -- 1-5
    today_goal
FROM {{ source('raw', 'raw_morning_reports') }}
WHERE deleted_at IS NULL
```

#### `stg_daily_reports_evening`
```sql
-- 夕日報のクリーニング
SELECT
    report_id,
    user_id,
    DATE(report_date, 'Asia/Tokyo') as report_date,
    training_content,
    self_evaluation,  -- 1-5
    reflection
FROM {{ source('raw', 'raw_evening_reports') }}
WHERE deleted_at IS NULL
```

### Layer 2: Intermediate（中間加工）

#### `int_monthly_attendance`
```sql
-- 月次出席集計
SELECT
    user_id,
    DATE_TRUNC(attendance_date, MONTH) as month,
    COUNT(*) as total_days,
    COUNTIF(status = 'present') as present_days,
    COUNTIF(status = 'absent') as absent_days,
    COUNTIF(status = 'late') as late_days,
    ROUND(COUNTIF(status = 'present') / COUNT(*) * 100, 2) as attendance_rate
FROM {{ ref('stg_attendance_records') }}
GROUP BY user_id, month
```

#### `int_health_metrics`
```sql
-- 健康指標の集計
SELECT
    m.user_id,
    DATE_TRUNC(m.report_date, WEEK) as week,
    AVG(m.sleep_hours) as avg_sleep_hours,
    AVG(m.meal_satisfaction) as avg_meal_satisfaction,
    AVG(m.stress_level) as avg_stress_level,
    AVG(e.self_evaluation) as avg_self_evaluation
FROM {{ ref('stg_daily_reports_morning') }} m
LEFT JOIN {{ ref('stg_daily_reports_evening') }} e
    ON m.user_id = e.user_id
    AND m.report_date = e.report_date
GROUP BY user_id, week
```

#### `int_training_hours`
```sql
-- 訓練時間の集計
SELECT
    user_id,
    DATE_TRUNC(report_date, MONTH) as month,
    COUNT(*) as training_days,
    SUM(training_minutes) / 60.0 as total_training_hours
FROM {{ ref('stg_daily_reports_evening') }}
GROUP BY user_id, month
```

### Layer 3: Mart（分析用）

#### `mart_attendance_summary`
```sql
-- 出席サマリー（経営ダッシュボード用）
SELECT
    u.user_id,
    u.nickname,
    a.month,
    a.total_days,
    a.present_days,
    a.absent_days,
    a.attendance_rate,
    CASE
        WHEN a.attendance_rate >= 90 THEN '優良'
        WHEN a.attendance_rate >= 70 THEN '良好'
        WHEN a.attendance_rate >= 50 THEN '要注意'
        ELSE '要支援'
    END as attendance_category
FROM {{ ref('stg_users') }} u
LEFT JOIN {{ ref('int_monthly_attendance') }} a
    ON u.user_id = a.user_id
WHERE u.is_active = TRUE
```

#### `mart_mental_health_trend`
```sql
-- メンタルヘルストレンド
SELECT
    u.user_id,
    u.nickname,
    h.week,
    h.avg_sleep_hours,
    h.avg_stress_level,
    h.avg_self_evaluation,
    LAG(h.avg_stress_level) OVER (
        PARTITION BY u.user_id ORDER BY h.week
    ) as prev_week_stress,
    h.avg_stress_level - LAG(h.avg_stress_level) OVER (
        PARTITION BY u.user_id ORDER BY h.week
    ) as stress_change
FROM {{ ref('stg_users') }} u
LEFT JOIN {{ ref('int_health_metrics') }} h
    ON u.user_id = h.user_id
WHERE u.is_active = TRUE
ORDER BY u.user_id, h.week DESC
```

#### `mart_training_effectiveness`
```sql
-- 訓練効果測定
SELECT
    u.user_id,
    u.nickname,
    t.month,
    t.training_days,
    t.total_training_hours,
    a.attendance_rate,
    h.avg_self_evaluation,
    CASE
        WHEN t.total_training_hours >= 60 
             AND a.attendance_rate >= 80 
             AND h.avg_self_evaluation >= 4.0
        THEN '高成果'
        WHEN t.total_training_hours >= 40 
             AND a.attendance_rate >= 60
        THEN '中成果'
        ELSE '要改善'
    END as effectiveness_category
FROM {{ ref('stg_users') }} u
LEFT JOIN {{ ref('int_training_hours') }} t
    ON u.user_id = t.user_id
LEFT JOIN {{ ref('int_monthly_attendance') }} a
    ON u.user_id = a.user_id 
    AND t.month = a.month
LEFT JOIN {{ ref('int_health_metrics') }} h
    ON u.user_id = h.user_id
    AND DATE_TRUNC(h.week, MONTH) = t.month
WHERE u.is_active = TRUE
```

## 分析指標（KPI）

### 1. 出席管理KPI
- **月次出席率**: 目標90%以上
- **連続欠席日数**: 3日以上で要支援フラグ
- **遅刻率**: 10%以下を目標

### 2. メンタルヘルスKPI
- **平均ストレスレベル**: 3.0以下を維持
- **平均睡眠時間**: 6.5時間以上
- **ストレス上昇トレンド**: 2週連続上昇で要面談

### 3. 訓練効果KPI
- **月次訓練時間**: 60時間以上
- **自己評価平均**: 4.0以上
- **訓練参加率**: 80%以上

### 4. 事業所運営KPI
- **稼働率**: 定員に対する利用者数
- **継続率**: 6ヶ月継続利用率
- **就職率**: 年間就職者数/利用者数

## Looker Studio ダッシュボード設計

### ダッシュボード1: 経営管理ダッシュボード
- **対象**: 施設長・管理者
- **更新頻度**: 日次
- **内容**:
  - 月次出席率推移
  - 利用者数推移
  - 稼働率
  - カテゴリ別利用者分布

### ダッシュボード2: 支援状況ダッシュボード
- **対象**: スタッフ
- **更新頻度**: 日次
- **内容**:
  - 利用者別出席状況
  - 要支援フラグ対象者リスト
  - メンタルヘルストレンド
  - 面談予定・履歴

### ダッシュボード3: 個人レポート
- **対象**: 利用者本人
- **更新頻度**: リアルタイム
- **内容**:
  - 自分の出席率
  - 訓練時間推移
  - 自己評価グラフ
  - 目標達成状況

## ETL実装（オプション）

### 方式1: Cloud Composer (Airflow)
```python
# DAG example
from airflow import DAG
from airflow.providers.google.cloud.transfers.mysql_to_gcs import MySQLToGCSOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator

# 日次でMySQLからBigQueryへ転送
```

### 方式2: dbt seeds（開発・テスト用）
```bash
# CSVエクスポート → dbt seeds にアップロード
dbt seed
```

## セキュリティ・コンプライアンス

### 個人情報保護
- ✅ 実名は使用しない（ニックネーム使用）
- ✅ 生年月日は年齢に変換
- ✅ 住所情報は都道府県のみ
- ✅ audit_logsで全操作を記録

### GDPR対応
- ✅ データ削除権（ソフトデリート）
- ✅ データポータビリティ（CSV出力）
- ✅ 監査ログ保持

## 実装スコープ

### Phase 1: サンプルデータ生成（Week 2）
- [ ] 仮生成データ50件作成
- [ ] BigQueryにアップロード
- [ ] dbt stagingモデル実装

### Phase 2: 分析モデル構築（Week 2-3）
- [ ] intermediateモデル3つ実装
- [ ] martモデル3つ実装
- [ ] テスト・ドキュメント追加

### Phase 3: ダッシュボード作成（Week 3）
- [ ] Looker Studio接続
- [ ] 経営管理ダッシュボード作成
- [ ] README更新

### Phase 4: 実データ置き換え（オプション）
- [ ] 上司承認取得
- [ ] 実データの匿名化処理
- [ ] ポートフォリオ v2.0 公開

## 差別化ポイント

### ビジネス視点
- ✅ 実務経験に基づく設計
- ✅ 福祉×データという希少性
- ✅ ビジネスインパクトの明確化

### 技術視点
- ✅ Laravel → MySQL → BigQuery の実装
- ✅ dbtによるデータ変換
- ✅ 監査ログ・セキュリティ対応

### ストーリー性
- ✅ 現職での課題解決
- ✅ データで支援の質を向上
- ✅ 社会貢献性の高いテーマ

## 成果物
- ✅ dbt Models（10+ models）
- ✅ SQLテストコード
- ✅ データカタログ（dbt docs）
- ✅ Looker Studio ダッシュボード（3種類）
- ✅ GitHub リポジトリ
- ✅ 設計ドキュメント

---

作成日: 2025-10-18  
最終更新: 2025-10-18