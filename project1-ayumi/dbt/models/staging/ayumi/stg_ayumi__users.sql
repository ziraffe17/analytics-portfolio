with source as (
    select * from {{ source('ayumi_raw', 'users') }}
),

renamed as (
    select
        id as user_id,
        name as user_name,
        name_kana,
        login_code,
        email,
        password,
        start_date,
        end_date,
        care_notes_enc,
        is_active,
        created_at,
        updated_at,
        deleted_at
    from source
)

select * from renamed