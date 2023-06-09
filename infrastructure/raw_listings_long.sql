create table if not exists project_airbnb.raw_listings_long
  (
      id                                            string
    , listing_url                                   string
    , scrape_id                                     string
    , last_scraped                                  string
    , name                                          string
    , description                                   string
    , neighborhood_overview                         string
    , picture_url                                   string
    , host_id                                       string
    , host_url                                      string
    , host_name                                     string
    , host_since                                    string
    , host_location                                 string
    , host_about                                    string
    , host_response_time                            string
    , host_response_rate                            string
    , host_acceptance_rate                          string
    , host_is_superhost                             string
    , host_thumbnail_url                            string
    , host_picture_url                              string
    , host_neighbourhood                            string
    , host_listings_count                           string
    , host_total_listings_count                     string
    , host_verifications                            string
    , host_has_profile_pic                          string
    , host_identity_verified                        string
    , neighbourhood                                 string
    , neighbourhood_cleansed                        string
    , neighbourhood_group_cleansed                  string
    , latitude                                      string
    , longitude                                     string
    , property_type                                 string
    , room_type                                     string
    , accommodates                                  string
    , bathrooms                                     string
    , bathrooms_text                                string
    , bedrooms                                      string
    , beds                                          string
    , amenities                                     string
    , price                                         string
    , minimum_nights                                string
    , maximum_nights                                string
    , minimum_minimum_nights                        string
    , maximum_minimum_nights                        string
    , minimum_maximum_nights                        string
    , maximum_maximum_nights                        string
    , minimum_nights_avg_ntm                        string
    , maximum_nights_avg_ntm                        string
    , calendar_updated                              string
    , has_availability                              string
    , availability_30                               string
    , availability_60                               string  
    , availability_90                               string
    , availability_365                              string
    , calendar_last_scraped                         string
    , number_of_reviews                             string
    , number_of_reviews_ltm                         string
    , number_of_reviews_l30d                        string
    , first_review                                  string
    , last_review                                   string
    , review_scores_rating                          string
    , review_scores_accuracy                        string
    , review_scores_cleanliness                     string
    , review_scores_checkin                         string
    , review_scores_communication                   string
    , review_scores_location                        string
    , review_scores_value                           string
    , license                                       string
    , instant_bookable                              string
    , calculated_host_listings_count                string
    , calculated_host_listings_count_entire_homes   string
    , calculated_host_listings_count_private_rooms  string
    , calculated_host_listings_count_shared_rooms   string
    , reviews_per_month                             string
    , filename                                      string
    , loaded_at                                     timestamp
  );