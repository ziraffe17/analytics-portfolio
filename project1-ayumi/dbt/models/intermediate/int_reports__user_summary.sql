-- models/intermediate/int_reports__user_summary.sql
{{
  config(
    materialized='table',
    tags=['intermediate', 'reports']
  )
}}

with morning_reports as (
    select
        user_id,
        report_date,
        sleep_rating,
        stress_rating,
        meal_rating,
        sleep_minutes,
        mood_score,
        created_at as morning_report_time
    from {{ ref('stg_ayumi__daily_reports_morning') }}
    where deleted_at is null
),

evening_reports as (
    select
        user_id,
        report_date,
        training_summary,
        training_reflection,
        condition_note,
        other_note,
        created_at as evening_report_time
    from {{ ref('stg_ayumi__daily_reports_evening') }}
    where deleted_at is null
),

daily_combined as (
    select
        coalesce(m.user_id, e.user_id) as user_id,
        coalesce(m.report_date, e.report_date) as report_date,
        
        -- 朝の報告
        m.sleep_rating,
        m.stress_rating,
        m.meal_rating,
        m.sleep_minutes,
        m.mood_score,
        m.morning_report_time,
        
        -- 夕の報告
        e.training_summary,
        e.training_reflection,
        e.condition_note,
        e.other_note,
        e.evening_report_time,
        
        -- 報告完了状況
        case when m.user_id is not null then true else false end as has_morning_report,
        case when e.user_id is not null then true else false end as has_evening_report,
        case 
            when m.user_id is not null and e.user_id is not null then true 
            else false 
        end as has_both_reports,
        
        -- 年月情報
        date_trunc(coalesce(m.report_date, e.report_date), month) as report_month,
        date_trunc(coalesce(m.report_date, e.report_date), week) as report_week
        
    from morning_reports m
    full outer join evening_reports e
        on m.user_id = e.user_id
        and m.report_date = e.report_date
),

monthly_summary as (
    select
        user_id,
        report_month,
        
        -- 報告提出状況
        count(*) as total_report_days,
        countif(has_morning_report) as morning_report_count,
        countif(has_evening_report) as evening_report_count,
        countif(has_both_reports) as both_reports_count,
        
        -- 報告完了率
        round(safe_divide(countif(has_morning_report), count(*)) * 100, 2) as morning_report_rate,
        round(safe_divide(countif(has_evening_report), count(*)) * 100, 2) as evening_report_rate,
        round(safe_divide(countif(has_both_reports), count(*)) * 100, 2) as both_reports_rate,
        
        -- 睡眠関連の集計
        round(avg(sleep_minutes), 2) as avg_sleep_minutes,
        round(avg(sleep_rating), 2) as avg_sleep_rating,
        
        -- ストレス・気分の集計
        round(avg(stress_rating), 2) as avg_stress_rating,
        round(avg(mood_score), 2) as avg_mood_score,
        round(avg(meal_rating), 2) as avg_meal_rating,
        
        -- 訓練記録の有無
        countif(training_summary is not null and training_summary != '') as training_record_count
        
    from daily_combined
    group by user_id, report_month
),

final as (
    select
        dc.*,
        ms.total_report_days as monthly_total_days,
        ms.morning_report_count as monthly_morning_count,
        ms.evening_report_count as monthly_evening_count,
        ms.both_reports_count as monthly_both_count,
        ms.morning_report_rate as monthly_morning_rate,
        ms.evening_report_rate as monthly_evening_rate,
        ms.both_reports_rate as monthly_both_rate,
        ms.avg_sleep_minutes as monthly_avg_sleep_minutes,
        ms.avg_sleep_rating as monthly_avg_sleep_rating,
        ms.avg_stress_rating as monthly_avg_stress_rating,
        ms.avg_mood_score as monthly_avg_mood_score,
        ms.avg_meal_rating as monthly_avg_meal_rating,
        ms.training_record_count as monthly_training_count,
        current_timestamp() as created_at
    from daily_combined dc
    left join monthly_summary ms
        on dc.user_id = ms.user_id
        and dc.report_month = ms.report_month
)

select * from final