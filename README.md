# Airbnb Data 2022

## Table of content
 * [Description](#item-one)
 * [Used tools](#item-two)
 * [Pipeline](#item-three)
 * [Replication](#item-four)
 * [Requirements](#item-five)
 * [Execution](#item-six)
 
<!-- headings -->
<a id="item-one"></a>
## Description
Airbnb dataset as of 2022. Purpose is to get some insights and comparisons about airbnb rentals all over the world. Developed as final project for the 2023 [Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp). For that reason airbnb data is taken on a quarterly base including data of 61 cities, mostly from Europe and the US.
 
<a id="item-two"></a>
## Tools
 * python
 * terraform
 * docker
 * gcs
 * big query
 * dbt
 * makefile
 * spark
 * google datastudio aka lookerstudio
 * ci/cd using megalinter with github actions
 
<a id="item-three"></a>
## Pipeline
![Architecture](/graphic/architecture.png)

A makefile executes a terraform script, which creates an gcs bucket with a random number, because every bucket must be unique. After that, a database is implemented in biq query and raw tables added. For this two sql-files, stored in *infrastructure* are executed. Following that, a container creates the dbt environment, including needed dbt profile.
Next step is then fetching data. Originally coming from [insideairbnb](http://insideairbnb.com), it is now also stored within a [gcs bucket](https://storage.googleapis.com/airbnb_data_2022/), since this data is only provide on a quarterly basis for the last 12 months, so recreation would otherwise impossible on a later point of time. Therefore, using spark is actually not necessary, copying directly from gcs to gcs would be possible. However, to simulate a more realistic scenario, spark is used to fetch and copy the data into an own gcs bucket, which serves as data lake. From there a short python script ingest the data into Big Query, used as data warehouse.

Within Big Query two raw tables contains raw data. Before raw data is ingested, these tables will be cleaned and do not contain any data then. The complete new data is inserted into these tables. Afterwards, an ephemeral dbt model make some type transformations and join both tables together. Subsequently, dbt snapshot builds two dimensional tables, before another dbt model builds a fact table to complete the starschema data model. Finally, dbt build some views which provides some aggregated values to use later in lookerstudio.

For understanding, since fresh data is only provided every three months, the makefile is used to execute the complete pipeline and loops over the available datasets. Therefore, a real orchestration tool is not implemented (however, prefect is provided as docker, but no files added, since it is simply not needed).

<a id="item-four"></a>
## Replication
This project can be replicated on Linux, macOS and Windows. However, it requires next to gcp credentials also some settings. **Be aware, that depending on your resources and internet connection, recreation of this project may need some time, approx 30-60 Minutes**.

<a id="item-five"></a>
## Requirements
  * Create an account on [gcp](https://console.cloud.google.com)
  * Make a new [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
  * Open [IAM API](https://console.cloud.google.com/flows/enableapi?apiid=iam.googleapis.com&redirect=https://console.cloud.google.com)
  * Create and download [service account key](https://cloud.google.com/iam/docs/keys-create-delete)
  * provide this key and project id (see execution)
  * [make](https://www.gnu.org/software/make/) (on Debian/Ubuntu it can be installed by `apt-get install make`)
  * docker > 20.10.17 (doesn't work with this docker version, which is default in snap. Tested with docker 23.0.3. For Debian/Ubuntu I provide a shell script, for others have a look at [docker](https://docs.docker.com/engine/install/)
  * If you're using a VM, it was tested on gcp VM, e2-standard-4, x86/64 architecture, 30 GB disk space using Debian-11-bullseye
    
<a id="item-six"></a>
## Execution
 * clone this repository
 * within this repository two .txt-files are provided `key.txt` and `gcs_project.txt` Store the path and name of your file into the first file. Make sure, not spaces or lines exist. In the second file set the id of your project. Both files contain an example. Alternatively, open `Makefile` and change the entries in line 11 (path and file name) and 12 (project). Execute it afterwards by using `make key`
 * To update docker on Debian/Ubuntu execute `make docker`
 * The first two points are optional. To build now the infrastructure execute `make infrastructure`
 * The last step requires the most time, since a lot of data is transfered two times from gcs to gcs to Big Query. In addition dbt is executed for every loop to provide slowly changing dimension tables. Execute it with `make pipeline`
 * As a tip: depending on individual settings it might be, that the process requires serveral times to enter sudo password. So, setting up the time is recommended. By executing `EDITOR=nano visudo` (without editor=nano, vi is used), file `/etc/sudoers`is opened. Add `Defaults timestamp_timeout=60` to increase the timeout to 60 Minutes. Please use visudo for that, because it locks sudoers-file, save edits to a temporary file and checks for syntax errors, before copying to the original file. This is recommended, since any error make `sudo` unusable. For more information, including security risks have a look [here](https://wiki.archlinux.org/title/sudo)
 