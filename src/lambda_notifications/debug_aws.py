import boto3
import os

# Force the profile
os.environ['AWS_PROFILE'] = 'iteso-lab'

session = boto3.Session(profile_name='iteso-lab')
creds = session.get_credentials()
current_creds = creds.get_frozen_credentials()

print(f"Profile: {session.profile_name}")
print(f"Region: {session.region_name}")
print(f"Access Key ID: {current_creds.access_key}")
# Check if these match your notepad
try:
    sts = session.client('sts')
    print(f"Identity: {sts.get_caller_identity()['Arn']}")
except Exception as e:
    print(f"Error: {e}")