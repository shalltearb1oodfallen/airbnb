{{
    config(
          materialized = 'view'
        , tags = ['view', 'counts']
    )
}}


select latitude
  , longitude
  , fab.*

from {{ ref('country_data') }} as cyd

inner join (select count(*) as counter
                , place
                , country
                , quarter
            from {{ ref('fact_airbnb') }}
            group by place
                , country
                , quarter
            ) as fab
    on cyd.place = fab.place