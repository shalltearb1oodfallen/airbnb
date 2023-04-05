{{
    config(
          materialized = 'incremental'
        , tags = ['fact', 'airbnb']
        , partition_by = {
                "field": "quarter",
                "data_type": "string"
              }
        , cluster_by = ["place", "country"]
        )
}}

with source as (select id
            , airbnb_id
            , host_response_rate
            , host_acceptance_rate
            , number_of_reviews
            , reviews_per_month
            , calculated_host_listings_count
            , availability_365
            , number_of_reviews_ltm
            , review_scores_rating
            , review_scores_accuracy
            , review_scores_cleanliness
            , review_scores_checkin
            , review_scores_communication
            , review_scores_location
            , review_scores_value
            , case
                when place = 'Buenos_Aires' then 'Buenos Aires'
                when place = 'Cape-Town' then 'Cape Town'
                when place = 'Los-Angeles' then 'Los Angeles'
                when place = 'Mexico-City' then 'Mexico City'
                when place = 'New-Orleans' then 'New Orleans'
                when place = 'New-York' then 'New York'
                when place = 'Rhode-Island' then 'Rhode Island'
                when place = 'San-Diego' then 'San Diego'
                when place = 'San-Francisco' then 'San Francisco'
                when place = 'Washington' then 'Washington DC'
                else place 
              end as place
            , quarter
            , current_timestamp() as loaded_at
            , {{ dbt_utils.generate_surrogate_key(['id','airbnb_id','host_response_rate','host_acceptance_rate',
                                                   'number_of_reviews','reviews_per_month','calculated_host_listings_count',
                                                   'availability_365','number_of_reviews_ltm','review_scores_rating',
                                                   'review_scores_accuracy','review_scores_cleanliness','review_scores_checkin',
                                                   'review_scores_communication','review_scores_location','review_scores_value',
                                                   'place','quarter'
                                                   ]) }} as rowhash
            from {{ ref('raw_cleaned') }}
),

country as (select place
                , county as country
        from {{ ref('country_data') }}
),

objects as (select key as object_key
            , id
            , dbt_valid_from
            , dbt_valid_to
            from {{ ref('dim_object') }}
),

host as (select key as host_key
        , id
        , dbt_valid_from
        , dbt_valid_to
        from {{ ref('dim_host') }}
        ),

facts as (select src.*
            , cty.country
            , obj.object_key
            , hst.host_key
        from source as src

        left join country as cty
            on src.place = cty.place

        left join objects as obj
            on src.id = obj.id
            and src.loaded_at >= obj.dbt_valid_from
            and src.loaded_at < coalesce(obj.dbt_valid_to, '9999-12-31')

        left join host as hst
            on src.id = hst.id
            and src.loaded_at >= hst.dbt_valid_from
            and src.loaded_at < coalesce(hst.dbt_valid_to, '9999-12-31')
)

select distinct *
from facts

{% if is_incremental() %}

    where rowhash not in (select rowhash from {{ this }})

{% endif %}