with source as (
    select * from {{ source('ayumi_raw', 'staffs') }}
),

renamed as (
    select
        id as staff_id,
        name as staff_name,
        email,
        password,
        role,
        is_active,
        created_at,
        updated_at,
        deleted_at
    from source
)

select * from renamed