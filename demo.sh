# Add friend records for testing.  
friends=("Ryan.Foley" "Ben.Grimes" "Conor.Harrington" "Scott.Kitterman" "Connor.LaRocque" "Justin.Moening" "Nick.Moreschi" "James.Msaddi" "Beau.Ramsey" "Brock.Therrien" "Ryan.Tremblay")
for i in "${friends[@]}"
do
        : 
        aws dynamodb put-item --table-name EenyMeenyMinyMoe --item \
                         '{ "Name": {"S": "'$i'"} }' 
done
