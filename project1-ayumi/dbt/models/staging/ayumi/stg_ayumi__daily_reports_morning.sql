with source as (
    select * from {{ source('ayumi_raw', 'daily_reports_morning') }}
),

renamed as (
    select
        id as report_id,
        user_id,
        report_date,
        sleep_rating,
        stress_rating,
        meal_rating,
        bed_time_local,
        wake_time_local,
        sleep_minutes,
        mood_score,
        created_at,
        updated_at,
        deleted_at
    from source
)

select * from renamed