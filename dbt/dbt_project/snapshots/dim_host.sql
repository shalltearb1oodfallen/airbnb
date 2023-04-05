{% snapshot dim_host %}

{{ config(
      target_schema = 'project_airbnb'
    , strategy = 'check_modified'
    , unique_key = 'id'
    , check_cols = [ 'airbnb_id'
                    , 'host_id'
                    , 'host_name'
                    , 'host_since'
                    , 'host_location'
                    , 'host_about'
                    , 'host_response_time'
                    , 'host_is_superhost'
                    , 'host_identity_verified'
                    , 'host_neighbourhood'
                ]
        )
}}

with dim_host as (
    select {{ dbt_utils.generate_surrogate_key(['id', 'loaded_at']) }} as key
        , id
        , airbnb_id
        , host_id
        , host_name
        , host_since
        , host_location
        , host_about
        , host_response_time
        , host_is_superhost
        , host_identity_verified
        , host_neighbourhood
        , loaded_at
    from {{ ref('raw_cleaned') }}
)

select *
from dim_host

{% endsnapshot %}