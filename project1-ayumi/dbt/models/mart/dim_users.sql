-- models/mart/dim_users.sql
{{
  config(
    materialized='table',
    tags=['mart', 'dimension']
  )
}}

with users_base as (
    select
        user_id,
        user_name,
        name_kana,
        email,
        start_date,
        end_date,
        is_active,
        created_at,
        updated_at
    from {{ ref('stg_ayumi__users') }}
    where deleted_at is null
),

-- 最新の月次出席統計
latest_attendance as (
    select
        user_id,
        attendance_month,
        total_days,
        present_days,
        attendance_rate,
        row_number() over (partition by user_id order by attendance_month desc) as rn
    from {{ ref('int_attendance__monthly') }}
),

-- 最新の月次報告統計
latest_reports as (
    select
        user_id,
        report_month,
        monthly_morning_rate,
        monthly_evening_rate,
        monthly_avg_sleep_minutes,
        monthly_avg_stress_rating,
        monthly_avg_mood_score,
        row_number() over (partition by user_id order by report_month desc) as rn
    from {{ ref('int_reports__user_summary') }}
),

-- 全期間の統計
user_stats as (
    select
        user_id,
        count(distinct attendance_month) as total_months_active,
        round(avg(attendance_rate), 2) as avg_attendance_rate_overall,
        sum(present_days) as total_present_days
    from {{ ref('int_attendance__monthly') }}
    group by user_id
),

final as (
    select
        u.user_id,
        u.user_name,
        u.name_kana,
        u.email,
        u.start_date,
        u.end_date,
        u.is_active,
        
        -- 利用期間
        case
            when u.end_date is not null then
                date_diff(cast(u.end_date as date), cast(u.start_date as date), day)
            else
                date_diff(current_date(), cast(u.start_date as date), day)
        end as days_since_start,
        
        -- 最新月の出席統計
        la.attendance_month as latest_attendance_month,
        la.attendance_rate as latest_attendance_rate,
        la.present_days as latest_month_present_days,
        
        -- 最新月の報告統計
        lr.report_month as latest_report_month,
        lr.monthly_morning_rate as latest_morning_report_rate,
        lr.monthly_evening_rate as latest_evening_report_rate,
        lr.monthly_avg_sleep_minutes as latest_avg_sleep_minutes,
        lr.monthly_avg_stress_rating as latest_avg_stress_rating,
        lr.monthly_avg_mood_score as latest_avg_mood_score,
        
        -- 全期間統計
        us.total_months_active,
        us.avg_attendance_rate_overall,
        us.total_present_days,
        
        -- カテゴリ分類
        case
            when la.attendance_rate >= 95 then '優良'
            when la.attendance_rate >= 90 then '良好'
            when la.attendance_rate >= 80 then '要注意'
            else '要支援'
        end as attendance_category,
        
        case
            when lr.monthly_avg_stress_rating >= 4 then '高ストレス'
            when lr.monthly_avg_stress_rating >= 3 then '中ストレス'
            else '低ストレス'
        end as stress_category,
        
        u.created_at,
        u.updated_at,
        current_timestamp() as dw_created_at
        
    from users_base u
    left join latest_attendance la
        on u.user_id = la.user_id
        and la.rn = 1
    left join latest_reports lr
        on u.user_id = lr.user_id
        and lr.rn = 1
    left join user_stats us
        on u.user_id = us.user_id
)

select * from final