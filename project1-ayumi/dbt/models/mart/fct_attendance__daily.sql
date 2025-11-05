-- models/mart/fct_attendance__daily.sql
{{
  config(
    materialized='table',
    tags=['mart', 'fact']
  )
}}

with attendance as (
    select
        user_id,
        attendance_date,
        attendance_type,
        record_time_slot,
        is_approved
    from {{ ref('stg_ayumi__attendance_records') }}
    where deleted_at is null
),

morning_reports as (
    select
        user_id,
        report_date,
        sleep_rating,
        stress_rating,
        meal_rating,
        sleep_minutes,
        mood_score
    from {{ ref('stg_ayumi__daily_reports_morning') }}
    where deleted_at is null
),

evening_reports as (
    select
        user_id,
        report_date,
        training_summary,
        training_reflection,
        condition_note
    from {{ ref('stg_ayumi__daily_reports_evening') }}
    where deleted_at is null
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
        
        a.attendance_date,
        a.attendance_type,
        a.record_time_slot,
        a.is_approved,

        -- 出席フラグ
        case when a.attendance_type in ('onsite', 'remote') then true else false end as is_present,
        case when a.attendance_type = 'onsite' then true else false end as is_onsite,
        case when a.attendance_type = 'remote' then true else false end as is_remote,
        case when a.attendance_type = 'absent' then true else false end as is_absent,
        case when a.attendance_type = 'late' then true else false end as is_late,
        case when a.attendance_type = 'early_leave' then true else false end as is_early_leave,
        
        -- 朝報告
        m.sleep_rating,
        m.stress_rating,
        m.meal_rating,
        m.sleep_minutes,
        m.mood_score,
        case when m.user_id is not null then true else false end as has_morning_report,
        
        -- 夕報告
        e.training_summary,
        e.training_reflection,
        e.condition_note,
        case when e.user_id is not null then true else false end as has_evening_report,
        
        -- 両方の報告有無
        case 
            when m.user_id is not null and e.user_id is not null then true 
            else false 
        end as has_both_reports,
        
        -- 日付情報
        extract(year from a.attendance_date) as year,
        extract(month from a.attendance_date) as month,
        extract(day from a.attendance_date) as day,
        format_date('%A', a.attendance_date) as day_of_week,
        
        current_timestamp() as created_at
        
    from attendance a
    left join users u
        on a.user_id = u.user_id
    left join morning_reports m
        on a.user_id = m.user_id
        and a.attendance_date = m.report_date
    left join evening_reports e
        on a.user_id = e.user_id
        and a.attendance_date = e.report_date
)

select * from combined