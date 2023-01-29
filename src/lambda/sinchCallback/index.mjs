// Import required AWS SDK clients and commands for Node.js
import {PublishCommand } from "@aws-sdk/client-sns";
import {snsClient } from "./snsClient.mjs";


export const handler = async(event) => {
    try {
    var body = JSON.parse(Buffer.from(event.body, 'base64').toString('utf8'))
    var msg = JSON.stringify({originationNumber: '+' + body.from, messageBody: body.body})
    console.log('msg', msg)
    var params = {
      Message: msg,
      TopicArn: "arn:aws:sns:us-east-1:052499878114:smsConnect-InboundSMSTopicD2F08B97-lVFr5h3prTiv",
    };
    const data = await snsClient.send(new PublishCommand(params));
    console.log("Success.",  data);
  } catch (err) {
    console.log("Error", err);
    return {"statusCode": 500}
  }
};