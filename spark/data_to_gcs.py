from google.cloud import storage
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
    
# Create a client to access the GCS bucket
client = storage.Client.from_service_account_json("key.json")

# Define the bucket name and directory path
bucket_name = "airbnb_data_2022"
directory_path = "files/"

# Get the bucket
bucket = client.get_bucket(bucket_name)

# Get the blobs in the directory
blobs = bucket.list_blobs(prefix=directory_path)

# Initialize Spark Session
spark = (
    SparkSession.builder.appName("GCS to GCS")
    .config("spark.executor.instances", "16")
    .config("spark.executor.memory", "16g")
    .config("spark.driver.memory", "16g")
    .config("spark.sql.execution.arrow.enabled", "true")
    .config("spark.sql.csv.maxCharsPerColumn", "1000000")
    .config("spark.sql.debug.maxToStringFields", "1000000") 
    .getOrCreate()
)

spark._jsc.hadoopConfiguration().set(
    "google.cloud.auth.service.account.json.keyfile", "key.json"
)

spark.conf.set("spark.sql.csv.maxCharsPerColumn", "1000000")

# Define bucket names
source_bucket = "airbnb_data_2022"
buckets = client.list_buckets()
for bucket in buckets:
    if "project_airbnb" in bucket.name:
        target_bucket = bucket.name


backfill = "yes"
backfill_list = ["mar", "jun", "sep", "dec"]

if backfill == "yes":
    for i in backfill_list:
        # Extract the file names from the blobs
        listing_files = [
            obj.name
            for obj in client.list_blobs(bucket_name, prefix="files/")
            if "listings" in obj.name and i in obj.name and obj.name.endswith(".csv")
        ]
        non_listing_files = [
            obj.name
            for obj in client.list_blobs(bucket_name, prefix="files/")
            if "listings" not in obj.name
            and i in obj.name
            and obj.name.endswith(".csv")
        ]

        # Load listing files into a dataframe
        listing_df = (
            spark.read.format("csv")
            .option("header", "true")
            .option("delimiter", ",")
            .option("multiLine", "true")
            .option("quote", '"')
            .option("escape", '"')
            .load([f"gs://{source_bucket}/{file_name}" for file_name in listing_files])
            .withColumn("filename", F.input_file_name())
            .withColumn("timestamp", F.current_timestamp())
        )

        non_listing_df = (
            spark.read.format("csv")
            .option("header", "true")
            .option("delimiter", ",")
            .option("multiLine", "true")
            .option("quote", '"')
            .option("escape", '"')
            .load(
                [f"gs://{source_bucket}/{file_name}" for file_name in non_listing_files]
            )
            .withColumn("filename", F.input_file_name())
            .withColumn("timestamp", F.current_timestamp())
        )

        # Replace the string ""["...,..."]"" with "...,..."
        listing_df = listing_df.select(
            [
                F.regexp_replace(c, r"^\"\"\[(.*)\]\"\"$", "$1").alias(c)
                if t == "string"
                else c
                for c, t in listing_df.dtypes
            ]
        )
        non_listing_df = non_listing_df.select(
            [
                F.regexp_replace(c, r"^\"\"\[(.*)\]\"\"$", "$1").alias(c)
                if t == "string"
                else c
                for c, t in non_listing_df.dtypes
            ]
        )

        # Write the listing dataframe to the target bucket
        destination_path = f"gs://{target_bucket}/files/listings/{i}"
        destination_path_non = f"gs://{target_bucket}/files/non_listings/{i}"

        listing_df.write.option("header", "true").option("delimiter", ",").option(
            "quote", '"'
        ).option("escape", '"').option("multiLine", "false").mode("overwrite").csv(
            destination_path
        )

        non_listing_df.write.option("header", "true").option("delimiter", ",").option(
            "quote", '"'
        ).option("escape", '"').option("multiLine", "false").mode("overwrite").csv(
            destination_path_non
        )

else:
    listing_files = [
        obj.name
        for obj in client.list_blobs(bucket_name, prefix="files/")
        if "listings" in obj.name and obj.name.endswith(".csv")
    ]
    non_listing_files = [
        obj.name
        for obj in client.list_blobs(bucket_name, prefix="files/")
        if "listings" not in obj.name and obj.name.endswith(".csv")
    ]
    listing_df = listing_df.select(
        [
            F.regexp_replace(c, r"^\"\"\[(.*)\]\"\"$", "$1").alias(c)
            if t == "string"
            else c
            for c, t in listing_df.dtypes
        ]
    )
    non_listing_df = non_listing_df.select(
        [
            F.regexp_replace(c, r"^\"\"\[(.*)\]\"\"$", "$1").alias(c)
            if t == "string"
            else c
            for c, t in non_listing_df.dtypes
        ]
    )
    destination_path = f"gs://{target_bucket}/files/listings/"
    destination_path_non = f"gs://{target_bucket}/files/non_listings/"
    listing_df.write.option("header", "true").option("delimiter", ",").option(
        "quote", '"'
    ).option("escape", '"').option("multiLine", "false").mode("overwrite").csv(
        destination_path
    )

    non_listing_df.write.option("header", "true").option("delimiter", ",").option(
        "quote", '"'
    ).option("escape", '"').option("multiLine", "false").mode("overwrite").csv(
        destination_path_non
    )
