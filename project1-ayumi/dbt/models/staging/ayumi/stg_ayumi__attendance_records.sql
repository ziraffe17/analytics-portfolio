with source as (
    select * from {{ source('ayumi_raw', 'attendance_records') }}
),

renamed as (
    select
        id as attendance_id,
        user_id,
        record_date as attendance_date,
        record_time_slot,
        attendance_type,
        note,
        source as attendance_source,
        is_approved,
        approved_by,
        approved_at,
        created_at,
        updated_at,
        deleted_at
    from source
)

select * from renamed