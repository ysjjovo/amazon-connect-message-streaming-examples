const translate = require('../index').translate
const a = async (content, s, t) => {
    console.log(await translate(content, s, t))
}
a('hi', 'en', 'zh')