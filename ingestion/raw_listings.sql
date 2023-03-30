create table if not exists project_airbnb.raw_listings
    (
          id                                        string
        , name                                      string
        , host_id                                   string
        , host_name                                 string
        , neighbourhood_group                       string
        , neighbourhood                             string
        , latitude                                  string
        , longitude                                 string
        , room_type                                 string
        , price                                     string
        , minimum_nights                            string
        , number_of_reviews                         string
        , last_review                               string
        , reviews_per_month                         string
        , calculated_host_listings_count            string
        , availability_365                          string
        , number_of_reviews_ltm                     string
        , license                                   string
        , filename                                  string
        , loaded_at                                 timestamp
    );