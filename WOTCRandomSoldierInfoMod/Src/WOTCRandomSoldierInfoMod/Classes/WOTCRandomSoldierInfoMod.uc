
/*

	TODO.

	There's nothing here.

	BUGS.

	* (FIXED) After my forced refresh, the character's forced "by the book" pose is lost, which is most
		apparent when the character is wounded (they'll slump suddenly).
		* I was making an unnecessary call that was causing the problem. I was young.

	* (FIXED*) The label on the Random Bio button isn't left justified as all the other buttons are; no idea
		why. :\
		* It's now left justified but the button's too wide, which is annoying. But it does look better, if
		not perfect.

	* (FIXED) Countries with more than one word (e.g. "South Africa") are stuck into the biography with
		no space (e.g. "SouthAfrica").

	*  (FIXED) SEVERE. Clicking Random Nickname for a soldier with no nickname causes a hard hang and crash of XCOM 2. :(

	* (FIXED) Clicking Random Nickname for a soldier with no nickname doesn't produce a nickname.
		* I finally figured this out: nicknames are sorted by X2SoldierClassTemplate, so a soldier that has no
		class can't get a nickname. In the Character Pool this is easy to work with (just assign the character a class)
		but with Rookies it won't work without me building a custom Nickname pool for Rookies. Maybe I could do this but
		...that seems a lot of work for not a lot of fun.
		* It would be good if the button greyed out in the case that the soldier is a Rookie (has no class).

	* (FIXED) If a soldier didn't have a nickname, you can use the normal button to give them one, but
		even then, clicking Random Nickname will delete that nickname and not grant them a
		new one. :\
		* This is the same issue as not producing a nickname; it DOES produce a nickname: "" which overwrites
		the existing nickname correctly. This happens to soldiers without a class (rookies).

	* (FIXED) Bio updates (upon new name/country) end up adding a new (and second) birthday/country of origin header;
		i.e. we end up with TWO headers to a given bio which is attrocious. OH it must not expect anybody to
		enter that, so I just need to not ship the first three lines of the old bio to the set bio call.

	* (FIXED) Random Country doesn't change the button, but DOES change the flag (in the header).

	WORRIES

	* (FIXED) I'm a bit worried that instantiating an XGCharacterGenerator each time OnInit is a memory leak; only because
		I'm not sure how cleanup works (or if I have to worry about it). I SUSPECT THIS AUTOCLEANS UP as it's
		a local specified variable, but not 100% (99.9%)

	* (FIXED) Clicking "Random Nickname" prior to the character being a supersoldier will result in clearing the nickname.
		I either need to ignore that (with a custom nickname generator) OR disable the button prior to supersoldier

	* (FIXED) The Bio has the first name of the soldier in it; do I want to (can I?) regen it (the same one) with the new name/info?
		* No, looks like it's hidden out of view? Or if it's in the code, I can't see it.
		* Only references I see to the character bio are in UICustomize_Info, where it's set via UIMCController (a low level
			flash API hook class).
		* If this same interface is used to initially generate the bio, I have yet to see where.

*/

class WOTCRandomSoldierInfoMod extends UIScreenListener
	config(WOTCRandomSoldierInfoMod);

var RandomSoldierInfoButtonPanel buttonPanel;

event OnInit(UIScreen Screen)
{
	class'RandomSoldierInfoButtonPanel'.static.BigLog("Loading WOTCRandomSoldierInfoMod.");

	buttonPanel = New class'RandomSoldierInfoButtonPanel';
	buttonPanel.InitPanel(Screen);
}

simulated function /*event*/ OnReceiveFocus(UIScreen Screen)
{
	buttonPanel.Event_OnReceiveFocus(Screen);
}

simulated function /*event*/ OnLoseFocus(UIScreen Screen)
{
	buttonPanel.Event_OnLoseFocus(Screen);
}

event OnRemoved(UIScreen Screen)
{
	buttonPanel.Event_OnRemoved(Screen);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

defaultproperties
{
	ScreenClass = class'UICustomize_Info';
}

