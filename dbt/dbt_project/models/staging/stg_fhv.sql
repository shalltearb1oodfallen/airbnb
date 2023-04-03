{{ config(materialized='table') }}

select * 
from {{ source('staging', 'raw_listings') }}
limit 2
