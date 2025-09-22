import boto3
from botocore.exceptions import NoCredentialsError, ClientError
import argparse
import os

# ====== Hardcoded Configuration ======
local_file = "D:/build-scripts/HE3/sdk-ameba-v7.1d/project/realtek_amebaz2_v0_example/GCC-RELEASE/application_is/Debug/bin/Flash and OTA files/OTA_final_he3_renesas.bin"
bucket_name = "hoags-mp-release"
s3_folder = "Livpure/Automation_build"  # S3 folder
region_name = "ap-south-1"

# ====== Upload function with versioned filename ======
def upload_to_s3(access_key, secret_key, file_path=local_file):
    try:
        s3_client = boto3.client(
            's3',
            aws_access_key_id=access_key,
            aws_secret_access_key=secret_key,
            region_name=region_name
        )

        # Generate numbered filename
        base_name = os.path.basename(file_path)
        
        # List existing files in the folder to find the next number
        response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=s3_folder + '/')
        existing_files = [obj['Key'] for obj in response.get('Contents', [])]
        count = 1
        while True:
            new_file_name = f"{count}_{base_name}"
            new_s3_path = f"{s3_folder}/{new_file_name}"
            if new_s3_path not in existing_files:
                break
            count += 1

        # Upload the file
        s3_client.upload_file(file_path, bucket_name, new_s3_path)
        print(f"File uploaded successfully to s3://{bucket_name}/{new_s3_path}")
    except FileNotFoundError:
        print(f"The file {file_path} was not found.")
    except NoCredentialsError:
        print("AWS credentials not available or incorrect.")
    except ClientError as e:
        print("Error uploading file:", e)

# ====== Command-line argument parsing ======
parser = argparse.ArgumentParser(description="Upload a .bin file to S3 with versioned name")
parser.add_argument("--access_key", required=True, help="AWS Access Key")
parser.add_argument("--secret_key", required=True, help="AWS Secret Key")
args = parser.parse_args()

# ====== Run upload ======
upload_to_s3(args.access_key, args.secret_key)
