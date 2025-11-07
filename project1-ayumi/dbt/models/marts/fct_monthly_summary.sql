-- models/mart/fct_monthly_summary.sql
{{
  config(
    materialized='table',
    tags=['mart', 'fact']
  )
}}

with attendance_monthly as (
    select
        user_id,
        attendance_month,
        total_days,
        present_days,
        absent_days,
        late_days,
        early_leave_days,
        attendance_rate,
        approved_days,
        morning_records,
        afternoon_records,
        fullday_records
    from {{ ref('int_attendance__monthly') }}
),

reports_monthly as (
    select
        user_id,
        report_month,
        monthly_total_days,
        monthly_morning_count,
        monthly_evening_count,
        monthly_both_count,
        monthly_morning_rate,
        monthly_evening_rate,
        monthly_both_rate,
        monthly_avg_sleep_minutes,
        monthly_avg_sleep_rating,
        monthly_avg_stress_rating,
        monthly_avg_mood_score,
        monthly_avg_meal_rating,
        monthly_training_count
    from {{ ref('int_reports__user_summary') }}
    -- 日次レコードではなく月次サマリーのみ抽出
    where report_date = date_trunc(report_date, month)
        or report_date is null
),

-- 月次サマリーを集計
reports_aggregated as (
    select
        user_id,
        report_month,
        max(monthly_total_days) as monthly_total_days,
        max(monthly_morning_count) as monthly_morning_count,
        max(monthly_evening_count) as monthly_evening_count,
        max(monthly_both_count) as monthly_both_count,
        max(monthly_morning_rate) as monthly_morning_rate,
        max(monthly_evening_rate) as monthly_evening_rate,
        max(monthly_both_rate) as monthly_both_rate,
        max(monthly_avg_sleep_minutes) as monthly_avg_sleep_minutes,
        max(monthly_avg_sleep_rating) as monthly_avg_sleep_rating,
        max(monthly_avg_stress_rating) as monthly_avg_stress_rating,
        max(monthly_avg_mood_score) as monthly_avg_mood_score,
        max(monthly_avg_meal_rating) as monthly_avg_meal_rating,
        max(monthly_training_count) as monthly_training_count
    from reports_monthly
    group by user_id, report_month
),

users as (
    select
        user_id,
        user_name,
        is_active
    from {{ ref('stg_ayumi__users') }}
    where deleted_at is null
),

combined as (
    select
        u.user_id,
        u.user_name,
        u.is_active as user_is_active,
        
        coalesce(a.attendance_month, r.report_month) as summary_month,
        
        -- 出席関連
        a.total_days as attendance_total_days,
        a.present_days,
        a.absent_days,
        a.late_days,
        a.early_leave_days,
        a.attendance_rate,
        a.approved_days,
        a.morning_records,
        a.afternoon_records,
        a.fullday_records,
        
        -- 報告関連
        r.monthly_total_days as report_total_days,
        r.monthly_morning_count,
        r.monthly_evening_count,
        r.monthly_both_count,
        r.monthly_morning_rate,
        r.monthly_evening_rate,
        r.monthly_both_rate,
        
        -- 健康指標
        r.monthly_avg_sleep_minutes,
        r.monthly_avg_sleep_rating,
        r.monthly_avg_stress_rating,
        r.monthly_avg_mood_score,
        r.monthly_avg_meal_rating,
        r.monthly_training_count,
        
        -- 日付情報
        extract(year from coalesce(a.attendance_month, r.report_month)) as year,
        extract(month from coalesce(a.attendance_month, r.report_month)) as month,
        
        -- カテゴリ分類
        case
            when a.attendance_rate >= 95 then '優良'
            when a.attendance_rate >= 90 then '良好'
            when a.attendance_rate >= 80 then '要注意'
            else '要支援'
        end as attendance_category,
        
        case
            when r.monthly_avg_stress_rating >= 4 then '高ストレス'
            when r.monthly_avg_stress_rating >= 3 then '中ストレス'
            else '低ストレス'
        end as stress_category,
        
        case
            when r.monthly_avg_mood_score >= 8 then '良好'
            when r.monthly_avg_mood_score >= 5 then '普通'
            else '要注意'
        end as mood_category,
        
        current_timestamp() as created_at
        
    from users u
    left join attendance_monthly a
        on u.user_id = a.user_id
    left join reports_aggregated r
        on u.user_id = r.user_id
        and a.attendance_month = r.report_month
    where a.attendance_month is not null
        or r.report_month is not null
)

select * from combined