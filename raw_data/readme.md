# Loading raw data from source

All used airbnb data is coming from [insiderairbnb](http://insideairbnb.com/). It is stored on google cloud storage, because of the following reasons:
* insideairbnb provides only quartely data for the last 12 months
* main purpose of this project is learning, so no need to fetch the data multiple times from their website

However, due to an update or any other reason, it might be that one want to load the data from the original source. Script *download_airbnb.sh* can be used. Actually, it's just a lot of wget commands :-). 