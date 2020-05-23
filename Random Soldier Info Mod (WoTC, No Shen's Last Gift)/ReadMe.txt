This is a version of Thades' Random Soldier Info mod that doesn't require the Shen's Last Gift DLC.
WoTC is still required.

For more details, see the original mod's description here:
http://steamcommunity.com/sharedfiles/filedetails/?id=1188012104

This fork's source code is located at https://github.com/gmes78/WOTC-xcom2-random-nickname-button



Below is a copy of the original mod's description:

THIS IS THE WOTC EDITION.

Base game version here: http://steamcommunity.com/sharedfiles/filedetails/?id=630738292

Have you ever known a soldier's nickname was wrong, but you couldn't think of the right one? This happens to me all the time in XCOM and I've really wanted a "Random Nickname" button all throughout EU/EW/LW. Well, now I got the chance to make one. Enjoy!

This mod adds five buttons to the Character Info screen:
* Random First Name
* Random Last Name
* Random Nickname
* Random Country
* Random Bio

The buttons call the built-in generators and thus *should* use whatever lists you have, modified or stock. (If they don't, let me know.)

Names are generated with respect to gender and country of origin, as it's the stock randomization functions the mod is using to generate them.

A newly generated name or country will be reflected in the existing bio.

In-game nicknames can only be generated if the soldier is of rank to have one. Using the Character Pool or a mod to make lower rank soldiers nicknameable won't (yet) allow this mod to do the same, I'm afraid.

FAQ

"The game crashes when I load up now."

You are almost certainly encountering a mod conflict. Note that mods are at times still resident (and can run into one another) whether or not you disable them with the checkboxes now in the Firaxis launcher, which is a huge pain but there's not much I can do about it from the mod's end. As the majority of users don't experience a crash condition, I'm confident the mod isn't to blame directly...but I recognize that's hardly helpful to those of you running into it.

Head over to the Discussion tab on this page and have a look at relevant topics there; you may find some aid.

"The buttons don't appear anywyere."

I've seen two causes for this.

The most frequent one is a mod conflict of some kind. Try diabling all other mods but this one to see if the buttons show up. (Any mod that overrides UICustomize_Info rather than injects into it will likely kick my mod out of the game.)

Less frequently, certain screen modes can result in the buttons being drawn offscreen. Try modifying the values in the mod's INI file to see if you can get them drawing anywhere: XComRandomSoldierInfoButtonPanel.ini.

"Help! When I click the Nickname button, it doesn't work! OR it erases my operative's nickname!"

If a soldier doesn't have a class, they can't get a nickname from the built-in generator function, because each class has its own random nickname list. If your soldier's not yet a Squaddie, you can't random gen them a nickname even with the Full Customization Mod. If you're in the Character Pool, assign the soldier a class and it will work. :)

"Can you make your mod work with this other sweet mod?"

Most incompatibilities are due to the other modder is instantiating their own Customization menu rather than extending the existing one. Their custom menu will have a different (arbitrary) name that mine won't be able to pick up on. If you *really* want to, you can fork my project and have it extend your favorite mod's main class and it might just work. (Buyer beware.) As to whether I'll do that...I mean, it can't hurt to ask me. :)

My code is on GitHub and forks do not offend me. <3
https://github.com/thadeshammer/WOTC-xcom2-random-nickname-button

KNOWN BUGS AND ISSUES.

The default override for soldier stance can be lost upon clicking one of my buttons (i.e. they'll resume acting wounded if they are wounded). (No workaround.)
