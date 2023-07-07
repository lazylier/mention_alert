# About

This is a csm for minetest. What it does is play a sound when certain names/words are mentioned by other players.

# Commands

The main command is alert. If the first argument is "on" or "off" it will enable or disable alerts. There can be any number of other arguments. For each one beginning with "+" it will add that name to the nicknames list, and each beginning with "-" will be removed, while -* will remove all nicknames. Other prefixes are [a+ a- a-\*] for the *accept* list, [r+ r- r-\*] for the *reject* list, and [f+ f- f\*] for the *friends* list.

If alert has no argument, or any other than on or off, it will print the current status  

The other commands are alert_reset to erase all lists, and alert_test to play the mention sound.

# Lists

You will be notified for any message that contains a word in **nicknames** if that message is sent by another player; or contains any word in the **accept** list, and does *not* contain any word in the **reject** list. You will also be notified for PMs, and if anyone in your **friends** list joins the game.

# Sounds
Put sounds in .minetest/sounds  
Sounds are from https://pixabay.com/sound-effects/wind-chimes-bells-115747/  
