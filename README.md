# Eeny-meeny-miny-moe
A child might use this game/process to select from a group of friends.

This repo is an example deployment for my IT718 class; leveraging DynamoDB and Lambda.  

### General game process
1) Drop a set of "friend's names" into DynamoDB
2) Invoke a lambda to pick a random friend
3) Repeat until you run out of friends

### Versions
The IT718 class focus is on being well-architected.  The implementation has evolved as we implement various well-architected actions.  There are 3 versions, all provide the same game.

1) /original:  Deployment is just a long sequence of CLI commands.  It proved to be fragile in deployment.
2) /eeny_redo:  Deployment based on CloudFormation.  The ./pillars subdirectory provides the well-architected actions that were implement to improve on the original version.
3) /eeny_2025:  This round of well-architected review resulted in changes to the architecture for performance, stability, and simplification.

After cloning this repo, the README in each version will provide the steps needed to deploy.

To constant improvement!
