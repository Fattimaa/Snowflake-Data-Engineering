
# Snowflake Tutorial 02
# Upload local CSV and JSON files to Snowflake internal stages
# Run in Windows PowerShell, NOT inside Snowflake SQL.

$connection = "snowflake_tutorial"
$dataPath = "C:\temp\load"

# Upload five CSV files individually
# Individual uploads avoid wildcard argument issues.

snow stage copy "$dataPath\contacts1.csv" "@mydatabase.public.my_csv_stage" --auto-compress -c $connection

snow stage copy "$dataPath\contacts2.csv" "@mydatabase.public.my_csv_stage" --auto-compress -c $connection

snow stage copy "$dataPath\contacts3.csv" "@mydatabase.public.my_csv_stage" --auto-compress -c $connection

snow stage copy "$dataPath\contacts4.csv" "@mydatabase.public.my_csv_stage" --auto-compress -c $connection

snow stage copy "$dataPath\contacts5.csv" "@mydatabase.public.my_csv_stage" --auto-compress -c $connection

# Upload JSON file
snow stage copy "$dataPath\contacts.json" "@mydatabase.public.my_json_stage" --auto-compress -c $connection

# If contacts3.csv was corrected after an initial upload,
# overwrite only that staged file using the following command:
#
# snow stage copy "$dataPath\contacts3.csv" "@mydatabase.public.my_csv_stage" --auto-compress --overwrite -c $connection
