const AWS = require("aws-sdk")
// AWS.config.region = process.env.AWS_REGION
AWS.config.region = 'us-east-1'
module.exports = async (content, s, t) => {
    const translate = new AWS.Translate()
    let params = {
            Text: content,
            SourceLanguageCode: s,
            TargetLanguageCode: t,
    }

    return new Promise((resolve, reject) => {
        translate.translateText(params, (err, data) => {
            if (err) {
                reject(err)
                return
            }
            resolve(data.TranslatedText)
        })
    })
}