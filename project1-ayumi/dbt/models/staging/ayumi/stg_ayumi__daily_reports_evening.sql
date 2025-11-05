with source as (
    select * from {{ source('ayumi_raw', 'daily_reports_evening') }}
),

renamed as (
    select
        id as report_id,
        user_id,
        report_date,
        training_summary,
        training_reflection,
        condition_note,
        other_note,
        created_at,
        updated_at,
        deleted_at
    from source
)

select * from renamed