import json
import boto3
import re
import uuid  # Import uuid to generate unique IDs

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("EmailsTable")  # Replace with your DynamoDB table name

def validate_email(email):
    """
    Validate the email format using a regex pattern.
    """
    pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    return re.match(pattern, email)


def lambda_handler(event, context):
    # Set CORS headers
    response_headers = {
        "Access-Control-Allow-Origin": "*",  # Allow all origins
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
        "Access-Control-Allow-Headers": "Content-Type"
    }

    try:
        # Parse the request body
        body = json.loads(event["body"])
        name = body.get("name")
        email = body.get("email")

        # Validate that both name and email are provided
        if not name or not email:
            return {
                "statusCode": 400,
                "headers": response_headers,
                "body": json.dumps({"message": "Name and email are required"})
            }

        # Validate the email format
        if not validate_email(email):
            return {
                "statusCode": 400,
                "headers": response_headers,
                "body": json.dumps({"message": "Invalid email format"})
            }


#        response = table.scan(
#            FilterExpression="email = :email",
#            ExpressionAttributeValues={":email": email}
#        )

        response = table.get_item(
            Key={
                "email": email
                }
        )
        if "Item" in response:
            return {
                "statusCode": 409,
                "headers": response_headers,
                "body": json.dumps({
                "message": "This email and name combination already exists!"
                })
            }

#        if response.get("Items"):  
#            return {
#                "statusCode": 409,  # 409 Conflict (email already exists)
#                "body": json.dumps({
#                    "message": "Email already exist! \n We get it—you love us. But once is enough 🤔 \n You've already joined the club!"
#                })
#            }

        # Create an item to store in DynamoDB
        item = {
            "email": email,  # Store the subscriber's email
            "name": name  # Store the subscriber's name
        }

        # Insert the item into DynamoDB
        table.put_item(Item=item)


        # Return a success response
        return {
            "statusCode": 200,
            "headers": response_headers,
            "body": json.dumps({"message": "Subscription successful"})
        }

    except Exception as e:
        # Handle any errors
        return {
            "statusCode": 500,
            "headers": response_headers,
            "body": json.dumps({"message": "Internal server error", "error": str(e)})
        }