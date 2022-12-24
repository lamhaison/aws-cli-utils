# aws-cli-utils
This is the project to collect helpful aws cli commandline with complex options to support your working
## Why I want to write this project.
- Sometimes, aws cli is list, get, describes. It is pretty hard to remmebers.
- Sometimes, you want to add more options on purpose and you want to have a place to collect and reuse it in the future. That is the reason I defined that structure to help me collect helpful commandlines and share on the github.



## Setting on ~/.aws/config

```

[PROFILE_NAME-dev]
region = region
role_arn = arn:aws:iam::ACCOUNT_NAME:role/PROFILE_NAME-prod
source_profile = SOURCE_PROFILE
mfa_serial = arn:aws:iam::ACCOUNT_NAME_MFA:mfa/ACCOUNT_NAME

[PROFILE_NAME-stg]
region = region
role_arn = arn:aws:iam::ACCOUNT_NAME:role/PROFILE_NAME-stg
source_profile = SOURCE_PROFILE
mfa_serial = arn:aws:iam::ACCOUNT_NAME_MFA:mfa/ACCOUNT_NAME


[PROFILE_NAME-prd]
region = region
role_arn = arn:aws:iam::ACCOUNT_NAME:role/PROFILE_NAME-prod
source_profile = SOURCE_PROFILE
mfa_serial = arn:aws:iam::ACCOUNT_NAME_MFA:mfa/ACCOUNT_NAME
```
