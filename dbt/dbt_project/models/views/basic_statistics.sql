{{
    config(
          materialized = 'view'
        , tags = ['view', 'basics']
    )
}}

select min(dot.accommodates) as min_accommodates
    , max(dot.accommodates) as max_accommodates
    , avg(dot.accommodates) as avg_accommodates
    , min(dot.bathrooms) as min_bathrooms
    , max(dot.bathrooms) as max_bathrooms
    , avg(dot.bathrooms) as avg_bathrooms
    , min(dot.beds) as min_beds
    , max(dot.beds) as max_beds
    , avg(dot.beds) as avg_beds
    , ROUND(min((dot.price / cyd.exchange_rate)),2) as min_price_euro
    , ROUND(max((dot.price / cyd.exchange_rate)),2) as max_price_euro
    , ROUND(avg((dot.price / cyd.exchange_rate)),2) as avg_price_euro
    , min(dot.minimum_nights) as min_minimum_nights
    , avg(dot.minimum_nights) as avg_minimum_nights
    , fab.place
    , cyd.county as country
    , fab.quarter

from {{ ref('dim_object') }} as dot

inner join {{ ref('country_data') }} as cyd
    on dot.place = cyd.place

inner join {{ ref('fact_airbnb') }} as fab
    on dot.key = fab.object_key

where (dot.price / cyd.exchange_rate) < 15000
and (dot.price / cyd.exchange_rate) > 0

group by fab.place
    , cyd.county
    , fab.quarter