# EENY 2025

### What changed
[PDF of presentation to class](./pillars/eeny_2025.pdf)

### 1) Clone
```
git clone https://github.com/kengraf/Eeny-meeny-miny-moe.git
cd Eeny-meeny-miny-moe/eeny_2025
```
The CloudFormation stack will export the URL of your lambda function to run the game

### 2) Add friends
Replace the `friends` file with a list of your friends. One friend per line

### 3) Deploy
```
sh deploy.sh {your-bucket-name} # The bucket will be created if it doesn't exist
```

### 4) Run the game
The deploy step will output the URL for your lambda fucntion
```
curl {your-lambda-url}
```
When the game returns "Game Over" the lambda will automatically repopulate DynamoDB

### 5) Optional: A different set of friends
Replace the `friends` file in your S3 bucket with a new list of friends.
```
curl {your-lambda-url}/reload
```
