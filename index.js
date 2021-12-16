const AWS = require("aws-sdk");

const dynamo = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  let body;
  let statusCode = 200;
  const headers = {
    "Content-Type": "application/json"
  };

  try {
    switch (event.routeKey) {
      case "DELETE /name/{id}":
        await dynamo
          .delete({
            TableName: "EenyMeenyMinyMoe",
            Key: {
              Name: event.pathParameters.id
            }
          })
          .promise();
        body = `Deleted item ${event.pathParameters.id}`;
        break;
      case "GET /name/{id}":
        body = await dynamo
          .get({
            TableName: "EenyMeenyMinyMoe",
            Key: {
              Name: event.pathParameters.id
            }
          })
          .promise();
        break;
      case "GET /next":
        body = await dynamo.scan({ TableName: "EenyMeenyMinyMoe" }).promise();
        break;
      case "PUT /names":
        let requestJSON = JSON.parse(event.body);
        await dynamo
          .put({
            TableName: "EenyMeenyMinyMoe",
            Item: {
              Name: requestJSON.name,
              Pickable: true
            }
          })
          .promise();
        body = `Put item ${requestJSON.id}`;
        break;
      default:
        throw new Error(`Unsupported route: "${event.routeKey}"`);
    }
  } catch (err) {
    statusCode = 400;
    body = err.message;
  } finally {
    body = JSON.stringify(body);
  }

  return {
    statusCode,
    body,
    headers
  };
};
