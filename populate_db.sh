friends=("first.last" "another.one")
for i in "${friends[@]}"
do
        : 
        aws dynamodb put-item --table-name eeny-redo --item \
                         '{ "Name": {"S": "'$i'"} }' 
done