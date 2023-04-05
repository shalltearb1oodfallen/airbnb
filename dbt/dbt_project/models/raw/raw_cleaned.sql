{{config(
     materialized = 'ephemeral'
    , tags = ['stage']
)}}


select {{ dbt_utils.generate_surrogate_key(['rls.id', 'rls.latitude', 'rls.longitude']) }} as id
  , cast(rls.id as numeric) as airbnb_id
  , rls.name  
  , rll.description
  , rls.neighbourhood_group
  ,	rls.neighbourhood
  , rll.neighborhood_overview as neighbourhood_overview
  , rls.host_id
  , rls.host_name
  , rll.host_since
  , rll.host_location
  , rll.host_about
  , rll.host_response_time
  , rll.host_response_rate
  , rll.host_acceptance_rate
  , rll.host_is_superhost
  , rll.host_identity_verified 
  , rll.host_neighbourhood 
  , cast(rls.latitude as float64) as latituide
  , cast(rls.longitude as float64) as longitude
  , rll.property_type
  , rls.room_type
  , rll.accommodates
  , rll.bathrooms
  , rll.beds
  , rll.amenities
  , cast(rls.price as float64) as price
  , cast(rls.minimum_nights as numeric) as minimum_nights
  , cast(rls.number_of_reviews as numeric) as number_of_reviews
  , rll.first_review
  , cast(rls.last_review as date) as last_review
  , cast(rls.reviews_per_month as float64) as reviews_per_month
  , cast(rls.calculated_host_listings_count as numeric) as calculated_host_listings_count
  , cast(rls.availability_365 as numeric) as availability_365
  , cast(rls.number_of_reviews_ltm as numeric) as number_of_reviews_ltm
  , rll.review_scores_rating
  , rll.review_scores_accuracy
  , rll.review_scores_cleanliness
  , rll.review_scores_checkin
  , rll.review_scores_communication
  , rll.review_scores_location
  , rll.review_scores_value
  , initcap(substr(rls.filename, 33, (length(rls.filename)-36))) as place
  , substr(rls.filename, 29, 3) as quarter
  , rls.loaded_at
from {{ source('project_airbnb', 'raw_listings') }} as rls

inner join (select id
                , description
                , neighborhood_overview
                , cast(host_since as date) as host_since
                , host_location
                , host_about
                , host_response_time
                , case
                    when regexp_contains(host_response_rate, r'\d+%') then cast(replace(host_response_rate, '%', '') as float64) / 100
                    when host_response_rate = 'N/A' then null
                    end as host_response_rate
                , case
                    when regexp_contains(host_acceptance_rate, r'\d+%') then cast(replace(host_acceptance_rate, '%', '') as float64) / 100
                    when host_acceptance_rate = 'N/A' then null
                    end as host_acceptance_rate
                , case
                    when lower(host_is_superhost) = 't' then true
                    else false
                    end as host_is_superhost
                , case
                    when lower(host_identity_verified) = 't' then true
                    else false
                    end as host_identity_verified
                , host_neighbourhood
                , cast(latitude as float64) as latitude
                , cast(longitude as float64) as longitude
                , property_type
                , cast(accommodates as numeric) as accommodates
                , cast(bathrooms as numeric) as bathrooms
                , cast(bedrooms as numeric) as bedrooms
                , cast(beds as numeric) as beds
                , amenities
                , cast(first_review as date) as first_review
                , cast(review_scores_rating as float64) as review_scores_rating
                , cast(review_scores_accuracy as float64) as review_scores_accuracy
                , cast(review_scores_cleanliness as float64) as review_scores_cleanliness	
                , cast(review_scores_checkin as float64) as review_scores_checkin
                , cast(review_scores_communication as float64) as review_scores_communication	
                , cast(review_scores_location as float64) as review_scores_location
                , cast(review_scores_value as float64) as review_scores_value                
                from {{ source('project_airbnb', 'raw_listings_long') }}
                where host_name is not null
                or host_since is not null
            ) as rll
        on rls.id = rll.id
        and cast(rls.latitude as float64) = cast(rll.latitude as float64)
        and cast(rls.longitude as float64) = cast(rll.longitude as float64)


