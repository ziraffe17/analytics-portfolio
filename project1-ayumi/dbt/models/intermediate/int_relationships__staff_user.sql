-- models/intermediate/int_relationships__staff_user.sql
{{
  config(
    materialized='table',
    tags=['intermediate', 'relationship']
  )
}}

with users_base as (
    select
        user_id,
        user_name,
        start_date,
        end_date,
        is_active,
        created_at as user_created_at,
        updated_at as user_updated_at
    from {{ ref('stg_ayumi__users') }}
    where deleted_at is null
),

staffs_base as (
    select
        staff_id,
        staff_name,
        role,
        is_active as staff_is_active,
        created_at as staff_created_at,
        updated_at as staff_updated_at
    from {{ ref('stg_ayumi__staffs') }}
    where deleted_at is null
),

-- Note: usersテーブルにstaff_idカラムがないため、
-- 実際の担当関係は別のテーブル（例: user_staff_assignments）が必要
-- ここでは全ユーザーと全スタッフのクロス集計として作成
user_staff_cross as (
    select
        u.user_id,
        u.user_name,
        u.start_date,
        u.end_date,
        u.is_active as user_is_active,
        u.user_created_at,
        u.user_updated_at,
        
        s.staff_id,
        s.staff_name,
        s.role as staff_role,
        s.staff_is_active,
        s.staff_created_at,
        s.staff_updated_at
        
    from users_base u
    cross join staffs_base s
),

staff_summary as (
    select
        staff_id,
        count(*) as total_potential_users
    from user_staff_cross
    where user_is_active
    group by staff_id
),

final as (
    select
        c.user_id,
        c.user_name,
        c.user_is_active,
        c.start_date as user_start_date,
        c.end_date as user_end_date,
        c.staff_id,
        c.staff_name,
        c.staff_role,
        c.staff_is_active,
        
        -- 利用期間の計算（日付型にキャスト）
        case
            when c.end_date is not null then
                date_diff(
                    cast(c.end_date as date), 
                    cast(c.start_date as date), 
                    day
                )
            else
                date_diff(
                    current_date(), 
                    cast(c.start_date as date), 
                    day
                )
        end as user_days,
        
        -- スタッフの担当可能利用者数
        s.total_potential_users as staff_potential_workload,
        
        current_timestamp() as created_at
        
    from user_staff_cross c
    left join staff_summary s
        on c.staff_id = s.staff_id
)

select * from final