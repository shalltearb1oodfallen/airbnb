{{
    config(
          materialized = 'view'
        , tags = ['view', 'counts']
    )
}}


select count(*) as counter
    , place
    , country
    , quarter
from {{ ref('fact_airbnb') }}
group by place
    , country
    , quarter