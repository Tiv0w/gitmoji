const https = require('node:https');
const { writeFile } = require('node:fs')

https.get('https://raw.githubusercontent.com/carloscuesta/gitmoji/master/packages/gitmojis/src/gitmojis.json', (res) => {
  let rawData = ''

  res.on('data', (chunk) => {
    rawData += chunk
  })

  res.on('end', () => {
    try {
      const { gitmojis } = JSON.parse(rawData)
      const gitmojisList = gitmojis.map(({ emoji, code, description }) => `("${description}" "${code}" #x${emoji.codePointAt(0).toString(16).toUpperCase()})`)
      writeFile('./gitmoji-list.el', `(${gitmojisList.join('\n')})`, (err) => console.error(err))
    } catch (err) {
      console.error(err)
    }
  })
}).on('error', (e) => {
  console.error(e)
})
