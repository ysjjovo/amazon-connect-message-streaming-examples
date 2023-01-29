// Import required AWS SDK clients and commands for Node.js
import {PublishCommand } from "@aws-sdk/client-sns";
import {snsClient } from "./snsClient.mjs";
const jwt = require("jsonwebtoken");
const sha256 = require('js-sha256');
const VONAGE_API_SIGNATURE_SECRET = 'E9VWuMNUBnaePh66'
export const handler = async(event) => {
    const payload = Buffer.from(event.body, 'base64').toString('utf8')
    let token = event.headers.authorization.split(" ")[1]
    console.log('token', token, 'payload', payload)
    try{
        var decoded = jwt.verify(token, VONAGE_API_SIGNATURE_SECRET, {algorithms:['HS256']});
        if(sha256(payload)!=decoded["payload_hash"]){
            console.log("tampering detected");
            return {"statusCode": 401}
        }
    }
    catch(err){
        console.log('Bad token detected')
        return {"statusCode": 401}
    }
    try {
      const body = JSON.parse(payload)
      var msg = JSON.stringify({originationNumber: '+' + body.msisdn, messageBody: body.text})
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