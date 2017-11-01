
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

var config int					RNBConf_PanelXOffset;
var config int					RNBConf_PanelYOffset;
var config int					RNBConf_Anchor;

var UICustomize_Info			CustomizeInfoScreen;
var XGCharacterGenerator 		CharacterGenerator;
var XComGameState_Unit       	Unit;

var UIPanel						RandomButtonBG;
var UIText						RandomButtonTitle;

var UIButton 					RandomFirstnameButton;
var UIButton 					RandomNicknameButton;
var UIButton 					RandomLastnameButton;
var UIButton					RandomCountryButton;
var UIButton					RandomBioButton;


const BUTTON_FONT_SIZE			=	26;
const BUTTON_HEIGHT				=   36;
const BUTTON_SPACING			=	3;

/*
	SUMMARY: The weird spacing in these strings IS ON PURPOSE.

	DETAILS FOLLOW.

	Here's my disappointing hack to try and finally make the buttons
	look reasonable. No matter what I do I can't get .SetWidth() or
	.SetSize() to affect the width of the buttons at all. There aren't
	many examples of them being used in the code, but the few that do
	exist do what you'd expect: they just call .SetSize or .SetWidth
	with values and presumably get results.

	Anyway, what I'm doing here is appending whitespace to the label
	text to force the auto-width setting to do my bidding, or as close
	as possible. It's not consistent and I'm worried it'll not carry
	across screen modes. I tested a few and in some cases the buttons
	appear pretty displaced from where I'd expect them, still visible
	but no longer aesthetically pleasing.

	I'll add config options to move the panel around.

	Still, it's nice to have buttons that are the same width(ish)
	finally.
*/

const FIRSTNAME_BUTTON_LABEL	= "Random First Name";
const LASTNAME_BUTTON_LABEL		= "Random Last Name";
const NICKNAME_BUTTON_LABEL		= "Random Nickname ";
const COUNTRY_BUTTON_LABEL		= "Random Country    ";
const BIO_BUTTON_LABEL			= "Random Bio           ";

// Button callback delegate
delegate OnClickedDelegate(UIButton Button);


event OnInit(UIScreen Screen)
{
	BigLog("loading my stuff now mkay?");

	CharacterGenerator	= `XCOMGAME.Spawn( class 'XGCharacterGenerator' );
	CustomizeInfoScreen	= UICustomize_Info(Screen);
	RefreshUnit();

	InitUI();
}

/*
	A NOTE ON EVENT VS. SIMULATED FUNCTION.

	I set these two functions as 'simulated function' as an accident
	and made a discovery. They seem to work either way, but when I
	tag them as events, there are bouts of slowdown upon clicks on
	my buttons.

	No idea why.
*/

simulated function /*event*/ OnReceiveFocus(UIScreen Screen)
{
	/*
		Previously, the Unit was only set in the OnInit event; the result
		was that using the < and > buttons in the Armory proper (in-game)
		would result in an embarrassing bug: the mod wouldn't refresh
		the Unit upon these button presses and thus would bring that
		soldier back in, superimposed awkwardly over the one that the
		user was actually viewing.

		The < and > buttons (bottom middle) in the armory proper (in-game)
		cause OnReceiveFocus events to proc here, so refreshing here
		solves the problem.
	*/

        BigLog("RandomNicknameButton.OnReceiveFocus");
		`log(" --> Resetting the stored Unit.");

		RefreshUnit();
}

simulated function /*event*/ OnLoseFocus(UIScreen Screen)
{
        BigLog("RandomNicknameButton.OnLoseFocus");
}

event OnRemoved(UIScreen Screen)
{
	/*
		Asset cleanup; this should only trigger once the player
		leaves the Armory or Character Pool. (*Should*.)
	*/
	BigLog("RandomNicknameButton.OnRemoved() -> CLEANING UP.");

	CustomizeInfoScreen.Destroy();
	CharacterGenerator.Destroy();

	/*
		I don't want to risk explicitly cleaning it up but
		if it was *created* for me (somehow) I want it to
		be garbage collected. According to this article,
		setting the reference to none is how that's done.

		https://wiki.beyondunreal.com/Legacy:Creating_Actors_And_Objects
	*/
	Unit = none;

	RandomButtonBG.Destroy();
	RandomButtonTitle.Destroy();

	RandomFirstnameButton.Destroy();
	RandomNicknameButton.Destroy();
	RandomLastnameButton.Destroy();
	RandomCountryButton.Destroy();
	RandomBioButton.Destroy();
}

simulated function InitUI()
{
	local int						AnchorPos;
	local string					strNicknameButtonLabel;		// for coloring, see NicknameButtonLabelAndTooltip()
	local string					strNicknameButtonTooltip;
	local string					strCountryButtonTooltip; 

	//AnchorPos = class'UIUtilities'.const.ANCHOR_TOP_RIGHT;
	AnchorPos = RNBConf_Anchor;

	RandomFirstnameButton	= CreateButton('randomFirstnameButton', FIRSTNAME_BUTTON_LABEL,	OnRandomFirstnameButtonPress,	AnchorPos, RNBConf_PanelXOffset, RNBConf_PanelYOffset);
	RandomLastnameButton	= CreateButton('randomLastnameButton',	LASTNAME_BUTTON_LABEL,	OnRandomLastnameButtonPress,	AnchorPos, RandomFirstnameButton.X, ButtonVertOffsetFrom(RandomFirstnameButton));

	NicknameButtonLabelAndTooltip(strNicknameButtonLabel, strNicknameButtonTooltip);
	RandomNicknameButton	= CreateButton('randomNicknameButton',	strNicknameButtonLabel,	OnRandomNicknameButtonPress,	AnchorPos, RandomFirstnameButton.X, ButtonVertOffsetFrom(RandomLastnameButton));
	DisableNicknameButtonIfRequired(strNicknameButtonTooltip);

	RandomCountryButton		= CreateButton('randomCountryButton',	COUNTRY_BUTTON_LABEL,	OnRandomCountryButtonPress,		AnchorPos, RandomFirstnameButton.X,	ButtonVertOffsetFrom(RandomNicknameButton));
	strCountryButtonTooltip = "No nation for this soldier.";
	DisableCountryButtonIfRequired(strCountryButtonTooltip);

	RandomBioButton			= CreateButton('randomBiographyButton', BIO_BUTTON_LABEL,		OnRandomBioButtonPress,			AnchorPos, RandomFirstnameButton.X, ButtonVertOffsetFrom(RandomCountryButton));
}

simulated function int ButtonVertOffsetFrom(const out UIButton uiButton)
{
	return uiButton.Y + uiButton.Height + BUTTON_SPACING;
}

simulated function NicknameButtonLabelAndTooltip(out string strLabel, out string strTooltip)
{
	if (Unit.bIsSuperSoldier)
	{
		strLabel	= class'UIUtilities_Text'.static.GetColoredText(NICKNAME_BUTTON_LABEL, eUIState_Disabled);
		strTooltip	= "Unit is a super soldier.";
	}
	else if (!Unit.IsVeteran() && !InShell())
	{
		strLabel	= class'UIUtilities_Text'.static.GetColoredText(NICKNAME_BUTTON_LABEL, eUIState_Disabled);
		strTooltip	= "Rank is too low.";
	} else if (Unit.GetSoldierClassTemplateName() == 'Rookie') {
		strLabel	= class'UIUtilities_Text'.static.GetColoredText(NICKNAME_BUTTON_LABEL, eUIState_Disabled);
		strTooltip	= "Can't generate nicknames for Rookies.";
	} else {
		strLabel	= class'UIUtilities_Text'.static.GetColoredText(NICKNAME_BUTTON_LABEL, eUIState_Normal);
		// No tooltip for default case
	}
}

simulated function DisableNicknameButtonIfRequired(const out string strTooltip)
{
	/*
		The nickname button is disabled under the following conditions:

		* The unit is a "Super Soldier" (Sid Meier, John 'Beaglerush' Teasdale, or the other guy)
			* Nothing ever overrides this.

		* If the soldier is too low a rank for a nickname per standard game rules.
			* This doesn't count in the Character Pool (InShell() == true)
			* Mods can safely override this, e.g. Full Customization Mod.

		* If the soldier is a Rookie (has no class).
			* If the soldier gains a class either by rank up (in-game) or assignment (in-shell)
			this no longer blocks.

		ToolTips are in place to explain this.
	*/

	if (Unit.bIsSuperSoldier || (!Unit.IsVeteran() && !InShell()) || (Unit.GetSoldierClassTemplateName() == 'Rookie'))
	{
		RandomNickNameButton.SetDisabled(true, strTooltip);
	}
}

simulated function DisableCountryButtonIfRequired(const out string strTooltip)
{
	/*
		The XPAC soldiers don't have nations. Clicking the button freezes the game.

		Also, apparently Super Soldiers don't either, as Nationality is disabled
		for them also under UICustomize_Info, so I'm following suit here.
	*/
	if (Unit.bIsSuperSoldier || Unit.IsChampionClass())
	{
		RandomCountryButton.SetDisabled(true, strTooltip);
	}
}

simulated function UIButton CreateButton(name nmName, string strLabel, delegate<OnClickedDelegate> OnClickCallThis,
										 int AnchorPos, int XOffset, int YOffset, optional int Width = -1)
{
	local UIButton	uiButton;

	uiButton = CustomizeInfoScreen.Spawn(class'UIButton', CustomizeInfoScreen);
	uiButton.InitButton(nmName, , OnClickCallThis);
	uiButton.SetAnchor(AnchorPos);

	/*
		SetPos is relative to the anchor, not the true origin.
		SetText uses some subset of HTML formatting which I
		don't know the whole of, but I did try creating a table
		and using CSS style embeds to get better control over
		the text, to no avail.
	*/

	uiButton.SetPosition(XOffset, YOffset);
	uiButton.SetText("<p align='LEFT'>" $ strLabel $ "</p>");

	return uiButton;
}

simulated function OnRandomFirstnameButtonPress(UIButton Button)
{
	local string 					strNewFirstName;
	local string					strNewLastName;

	local string 					strFirstName;
	local string 					strNickName;
	local string 					strLastName;

	strFirstName = Unit.GetFirstName();
	strNickName = Unit.GetNickName();
	strLastName = Unit.GetLastName();

	strNewFirstName = "NEWNAME";
	strNewLastName = "NEWLAST";		// have to catch it whether or not I use it.

	/*
		XGCharacterGenerator class has member
		GenerateName(int gender, name countryname, OUT string first, OUT string last, optional int race)
		(The out keyword is pass-by-reference in UnrealScript.)

		function NameCheck in XComGameState_Unit takes an XGCharacterGenerator as param (then calls GenerateName)

		Need iGender, which is member of kAppearance, which is member of Unit.
	*/
	CharacterGenerator.GenerateName(Unit.kAppearance.iGender, Unit.GetCountry(), strNewFirstName, strNewLastName, Unit.kAppearance.iRace);

	Unit.SetUnitName(strNewFirstName, strLastName, strNickName);
	UpdateCharacterBio(strFirstName, strNewFirstName);
	ForceCustomizationMenuRefresh();
}

simulated function OnRandomNicknameButtonPress(UIButton Button)
{
	local string 					strNewNickName;
	local string 					strFirstName;
	local string 					strLastName;

	strFirstName = Unit.GetFirstName();
	strLastName = Unit.GetLastName();

	strNewNickName = Unit.GenerateNickname();
	Unit.SetUnitName(strFirstName, strLastName, strNewNickName);
	ForceCustomizationMenuRefresh();
}

simulated function OnRandomLastnameButtonPress(UIButton button)
{
	local string 					strNewFirstname;
	local string					strNewLastname;

	local string 					strFirstname;
	local string 					strNickname;
	local string 					strLastname;

	strFirstName = Unit.GetFirstName();
	strNickName = Unit.GetNickName();
	strLastName = Unit.GetLastName();

	strNewFirstName = "NEWNAME";	// have to catch it whether or not I use it.
	strNewLastName	= "NEWLAST";

	/*
		XGCharacterGenerator class has member
		GenerateName(int gender, name countryname, OUT string first, OUT string last, optional int race)
		(the "out" keyword denotes pass-by-reference in UnrealScript).

		function NameCheck in XComGameState_Unit takes an XGCharacterGenerator as param (then calls GenerateName)

		Need iGender, which is member of kAppearance, which is member of Unit. Some last names are filtered
		by gender, e.g. countries like Iceland.
	*/
	CharacterGenerator.GenerateName(Unit.kAppearance.iGender, Unit.GetCountry(), strNewFirstname, strNewLastname, Unit.kAppearance.iRace);

	Unit.SetUnitName(strFirstname, strNewLastname, strNickname);

	/*
		Currently, last names aren't reflected in bios but no reason they couldn't be
		one day.
	*/
	UpdateCharacterBio(strLastname, strNewLastname);
	ForceCustomizationMenuRefresh();
}

simulated function OnRandomCountryButtonPress(UIButton Button)
{
	local string					strOldCountry;
	local name						newCountry;
	local string					strNewCountry;

	local bool						bValidCountry;

	/*
		XGCharacterGenerator has member PickOriginCountry() which returns a UE3 Name, the single quote kind.
		Country looks to be stored in kSoldier (TSoldier) private member of XGCharacterGenerator.
		XComGameState_Unit has members SetCountry and GetCountry.
		Easy peasy.

		NOTE. Sometimes mods that add countries aren't removed cleanly, which
		seems to cause crash for users when they hit this button.

		Two things could be the case:
			the country template is coming back none
		OR	the country name is empty (or weird).

		I can't check it for corruption, but hopefully that's not the issue.

		(If it is, I can't do anything about this.)
	*/

	if (Unit.GetCountryTemplate() != none)
	{
		strOldCountry = Unit.GetCountryTemplate().DisplayName;

		if (Len(strOldCountry) < 1)
			bValidCountry = false;
		else
			bValidCountry = true;

	} else {
		bValidCountry = false;
	}

	newCountry = CharacterGenerator.PickOriginCountry();
	Unit.SetCountry(newCountry);
	strNewCountry = Unit.GetCountryTemplate().DisplayName;

	if (bValidCountry)
		UpdateCharacterBio(strOldCountry, strNewCountry);

	ForceCustomizationMenuRefresh();
}

simulated function OnRandomBioButtonPress(UIButton Button)
{
	/*
		This function takes an optional string to force a background; perhaps
		I can use this to refresh an existing Bio with the name changed as needed?
	*/
	Unit.GenerateBackground();
	ForceCustomizationMenuRefresh();
}

simulated function UpdateCharacterBio(string oldName, string newName)
{
	local string				oldBio;
	local string				newBio;

	/*
		Calling this with a nickname is a recipe for disaster, esp. if it's empty:
		it results in the hang and crash; not sure what specifically triggers it yet.

		But so far nicknames don't appear in Bios, so no worries. Just don't call
		this on button presses tied to unrelated soldier data. <3
	*/

	/*
		The old bio has a three line header: DOB, country of origin, and a blank line.
		Shipping this as-is will result in a similar (but different) header being
		stuck on top: we accumulate headers.

		Only way to avoid this is to cut off the top three lines prior to shipping.
	*/

	oldBio = Unit.GetBackground();
	oldBio = Split(oldBio, "\n", true);
	oldBio = Split(oldBio, "\n", true);
	oldBio = Split(oldBio, "\n", true);

	newBio = Repl(oldBio, oldName, newName, true); // enforce case sensitivity

	Unit.GenerateBackground(newBio);
}


simulated function ForceCustomizationMenuRefresh()
{
	`log("Forcing Customization Menu Screen to update (Random Nickname Button Mod).");

	/*
		UICustomize has member UISoldierHeader Header.
		UISoldierHeader derives from UIPanel.
		UISoldierHeader has member PopulateData(unit) which,
		combined with the refresh call, calling PopulateData does the trick.
	*/

	CustomizeInfoScreen.Header.PopulateData(Unit);
	CustomizeInfoScreen.UpdateData();				// gets the country button label
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	Some utility code ripped from UICustomize.uc

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

simulated function XComGameState_Unit GetUnit()
{
	return CustomizeInfoScreen.Movie.Pres.GetCustomizationUnit();
}

simulated function RefreshUnit()
{
	Unit = GetUnit();
}

simulated function bool InShell()
{
	/*
		The "Shell" is the main menu area, outside of the game; this is relevant
		if we're in the Character Pool, which counts as "InShell".
	*/

	return XComShellPresentationLayer(CustomizeInfoScreen.Movie.Pres) != none;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	Some utility code to make my life easier.

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

 simulated function BigLog(string logEntry)
 {
	`log("* * * * * * * * * * * * * * * * * *");
	`log("");
	`log(logEntry);
	`log("");
	`log("* * * * * * * * * * * * * * * * * *");
 }

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

defaultproperties
{
	ScreenClass = class'UICustomize_Info';
}

