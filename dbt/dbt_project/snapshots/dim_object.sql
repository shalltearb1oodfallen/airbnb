{% snapshot dim_object %}

{{ config(
      target_schema = 'project_airbnb'
    , strategy = 'check_modified'
    , unique_key = 'id'
    , check_cols = ['airbnb_id'
                  , 'name'
                  , 'description'
                  , 'neighbourhood_group'
                  , 'neighbourhood'
                  , 'neighbourhood_overview'
                  , 'latituide'
                  , 'longitude'
                  , 'property_type'
                  , 'room_type'
                  , 'accommodates'
                  , 'bathrooms'
                  , 'beds'
                  , 'amenities'
                  , 'price'
                  , 'minimum_nights'
                  , 'first_review'
                  , 'last_review'
                  , 'place'
                  , 'loaded_at'
                ]
  )
}}

with dim_obj as (
    select {{ dbt_utils.generate_surrogate_key(['id', 'loaded_at']) }} as key
        , id
        , airbnb_id
        , name
        , description
        , neighbourhood_group
        , neighbourhood
        , neighbourhood_overview
        , latituide
        , longitude
        , property_type
        , room_type
        , accommodates
        , bathrooms
        , beds
        , amenities
        , price
        , minimum_nights
        , first_review
        , last_review
        , place
        , loaded_at
    from {{ ref('raw_cleaned') }}
)

select *
from dim_obj

{% endsnapshot %}