{{
    config(
          materialized = 'view'
        , tags = ['view', 'evaluations']
    )
}}

select avg(host_response_rate) as avg_host_response_rate
    , avg(host_acceptance_rate) as avg_host_acceptance_rate     
    , avg(review_scores_rating) as avg_review_scores_rating
    , avg(review_scores_accuracy) as avg_review_scores_accuracy
    , avg(review_scores_cleanliness) as avg_review_scores_cleanliness
    , avg(review_scores_checkin) as avg_review_scores_checkin
    , avg(review_scores_communication) as avg_review_scores_communication
    , avg(review_scores_location) as avg_review_scores_location
    , avg(review_scores_value) as avg_review_scores_value
    , place
    , country
    , quarter
from {{ ref('fact_airbnb') }}
group by place
    , country
    , quarter