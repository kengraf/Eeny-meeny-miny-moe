# EENY 2025

### What changed
(PDF of presentation to class)["./pillars/eeny_2025.pdf"]

### Deploy
```
git clone https://github.com/kengraf/Eeny-meeny-miny-moe.git
cd Eeny-meeny-miny-moe/eeny_2025
sh deploy.sh {your-bucket-name} # The bucket will be created if it doesn't exist
```
The CloudFormation stack will export the URL of your lambda function to run the game

### Add friends
Replace the `friends` file in the S3 bucket with a list of your friends. One friend per line
```
curl {your-lambda-url}/reload
```
