-- [[ Emoticons ]]
speak.emoji:Define(":B1:", "http://orig11.deviantart.net/e380/f/2014/100/3/8/b1_in_hd_by_tomajko-d7dz8iy.png")
speak.emoji:Define(":nyan:", "https://emojis.slackmojis.com/emojis/images/1450458551/184/nyancat_big.gif")
speak.emoji:Define(":party_parrot:", "https://emojis.slackmojis.com/emojis/images/1471119458/990/party_parrot.gif")
speak.emoji:Define(":facepalm:", "https://emojis.slackmojis.com/emojis/images/1450319441/51/facepalm.png")
speak.emoji:Define(":meow_parrot:", "https://emojis.slackmojis.com/emojis/images/1563480763/5999/meow_party.gif")

speak.emoji:Define(":gmod:", "https://cdn.discordapp.com/emojis/566703589695815682.png?v=1")
speak.emoji:Define(":funny:", "https://cdn.discordapp.com/emojis/567381394003722253.png?v=1")
speak.emoji:Define(":dummy:", "https://cdn.discordapp.com/emojis/589133881471402012.png?v=1")
speak.emoji:Define(":winner:", "https://cdn.discordapp.com/emojis/589133885242343470.png?v=1")
speak.emoji:Define(":agree:", "https://cdn.discordapp.com/emojis/589133885506322448.png?v=1")
speak.emoji:Define(":baybee:", "https://cdn.discordapp.com/emojis/589133892842160159.png?v=1")
speak.emoji:Define(":sad:", "https://cdn.discordapp.com/emojis/589133894683459594.png?v=1")
speak.emoji:Define(":late:", "https://cdn.discordapp.com/emojis/589133896952709131.png?v=1")
speak.emoji:Define(":informative:", "https://cdn.discordapp.com/emojis/589133896830943242.png?v=1")

speak.emoji:Define(":gmodheart:", "icon16/heart.png")

if speak.view then
    speak.logger.trace "refresh autocomplete cl_emoji"
    speak.view:RefreshAutocomplete()
end
