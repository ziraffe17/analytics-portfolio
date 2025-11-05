-- models/intermediate/int_attendance__monthly.sql
{{
  config(
    materialized='table',
    tags=['intermediate', 'attendance']
  )
}}

with attendance_base as (
    select
        user_id,
        date_trunc(attendance_date, month) as attendance_month,
        attendance_type,
        record_time_slot,
        is_approved
    from {{ ref('stg_ayumi__attendance_records') }}
    where deleted_at is null
),

monthly_aggregation as (
    select
        user_id,
        attendance_month,
        
        -- 出席状況別の日数集計
        count(*) as total_days,
        countif(attendance_type in ('onsite', 'remote')) as present_days,
        countif(attendance_type = 'onsite') as onsite_days,
        countif(attendance_type = 'remote') as remote_days,
        countif(attendance_type = 'absent') as absent_days,
        countif(attendance_type = 'late') as late_days,
        countif(attendance_type = 'early_leave') as early_leave_days,
        
        -- 出席率の計算
        round(
            safe_divide(
                countif(attendance_type in ('onsite', 'remote')), 
                count(*)
            ) * 100, 
            2
        ) as attendance_rate,
        
        -- 承認済みレコード数
        countif(is_approved) as approved_days,
        
        -- 時間帯別の集計
        countif(record_time_slot = '午前') as morning_records,
        countif(record_time_slot = '午後') as afternoon_records,
        countif(record_time_slot = '終日') as fullday_records
        
    from attendance_base
    group by 
        user_id, 
        attendance_month
),

final as (
    select
        user_id,
        attendance_month,
        total_days,
        present_days,
        onsite_days,
        remote_days,
        absent_days,
        late_days,
        early_leave_days,
        attendance_rate,
        approved_days,
        morning_records,
        afternoon_records,
        fullday_records,
        current_timestamp() as created_at
    from monthly_aggregation
)

select * from final