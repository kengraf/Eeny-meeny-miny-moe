# Add friend records for testing.  
friends=("alice","bob","charlie")
for i in "${friends[@]}"
do
        : 
        aws dynamodb put-item --table-name EenyMeenyMinyMoe --item \
                         '{ "Name": {"S": "'$i'"} }' 
done
