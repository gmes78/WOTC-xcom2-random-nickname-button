
/*

	TODO.

	There's nothing here.

	BUGS.

	* (FIXED? TESTING) After my forced refresh, the character's forced "by the book" pose is lost, which is most
		apparent when the character is wounded (they'll slump suddenly).
		
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

class Customize_Info_Listener extends UIScreenListener;

var UIScreen 					CurrentScreen;
var XGCharacterGenerator 		CharacterGenerator;
var XComGameState_Unit       	Unit;

var UIButton 					RandomFirstnameButton;
var UIButton 					RandomNicknameButton;
var UIButton 					RandomLastnameButton;
var UIButton					RandomCountryButton;
var UIButton					RandomBioButton;

// If there's a way to have the system autogen these, I haven't found it yet.
const BUTTON_FONT_SIZE	=	26;
const BUTTON_HEIGHT		=   36;
//const BUTTON_WIDTH		=	270;		// Doesn't seem to take? And it looks fine auto.
const BUTTON_SPACING	=	4;

// Same as UIButton (hopefully doesn't fuck with that)
delegate OnClickedDelegate(UIButton Button);

event OnInit(UIScreen Screen)
{
	local int						ButtonAnchorPos;
	local int						RandomFirstNameButtonX;
	local int						RandomFirstNameButtonY;
	local int						RandomNickNameButtonX;
	local int						RandomNickNameButtonY;
	local int						RandomLastNameButtonX;
	local int						RandomLastNameButtonY;
	local int						RandomCountryButtonX;
	local int						RandomCountryButtonY;
	local int						RandomBioButtonX;
	local int						RandomBioButtonY;
	
	/*
		The nickname button is disabled if one of two conditions are true:

		1. If the soldier is too low a rank for a nickname per standard game
		rules; this is fungible by other mods, EXCEPT:

		2. If the soldier is a Rookie (has no class).

		ToolTips are in place to explain this.
	*/
	local string					strRandomNickNameButtonLabel;	// for coloring
	local string					strNicknameTooltip;				// 
	

	/*************************************************************************************/

	CharacterGenerator = `XCOMGAME.Spawn( class 'XGCharacterGenerator' );

	/*************************************************************************************/
	
	/*
		It might be nice for these to be configurable for the user (i.e. in an INI file
		instead of hardcoded). Something to look into.
	*/
	ButtonAnchorPos = class'UIUtilities'.const.ANCHOR_TOP_RIGHT;
	CurrentScreen = `SCREENSTACK.GetCurrentScreen();	
	Unit = GetUnit();
	
	/*
		First Name
	*/
	RandomFirstNameButtonX = -250;
	RandomFirstNameButtonY = 250;
	RandomFirstnameButton = CreateButton('randomFirstnameButton', "Random First Name", OnRandomFirstnameButtonPress,
											ButtonAnchorPos, RandomFirstNameButtonX, RandomFirstNameButtonY);

	/*
		Last Name
	*/		
	RandomLastNameButtonX = RandomFirstnameButton.X;
	RandomLastNameButtonY = RandomFirstNameButton.Y + RandomFirstNameButton.Height + BUTTON_SPACING;
	RandomLastnameButton = CreateButton('randomLastnameButton', "Random Last Name", OnRandomLastnameButtonPress, 
										ButtonAnchorPos, RandomLastNameButtonX, RandomLastNameButtonY);
		
	/*
		Nickname

		This could do with a refactor but it works right now.
	*/	
	if (Unit.bIsSuperSoldier)
	{
		strRandomNickNameButtonLabel = class'UIUtilities_Text'.static.GetColoredText("Random Nickname", eUIState_Disabled);
		strNicknameTooltip = "Unit is a super soldier.";
	}
	else if (!Unit.IsVeteran() && !InShell())
	{
		strRandomNickNameButtonLabel = class'UIUtilities_Text'.static.GetColoredText("Random Nickname", eUIState_Disabled);
		strNicknameTooltip = "Rank is too low.";
	} else if (Unit.GetSoldierClassTemplateName() == 'Rookie') {
		strRandomNickNameButtonLabel = class'UIUtilities_Text'.static.GetColoredText("Random Nickname", eUIState_Disabled);
		strNicknameTooltip = "Can't generate nicknames for Rookies.";
	} else {
		strRandomNickNameButtonLabel = class'UIUtilities_Text'.static.GetColoredText("Random Nickname", eUIState_Normal);
	}
	
	RandomNickNameButtonX = RandomFirstNameButton.X;
	RandomNickNameButtonY = RandomLastNameButton.Y + RandomLastNameButton.Height + BUTTON_SPACING;
	RandomNicknameButton = CreateButton('randomNicknameButton', strRandomNickNameButtonLabel, OnRandomNicknameButtonPress,
										ButtonAnchorPos, RandomNickNameButtonX, RandomNickNameButtonY);

	if (Unit.bIsSuperSoldier || (!Unit.IsVeteran() && !InShell()) || (Unit.GetSoldierClassTemplateName() == 'Rookie'))
	{
		RandomNickNameButton.SetDisabled(true, strNicknameTooltip);
	}
		
	/*
		Country
	*/
	RandomCountryButtonX = RandomFirstNameButton.X;
	RandomCountryButtonY = RandomNickNameButton.Y + RandomNickNameButton.Height + BUTTON_SPACING;
	RandomCountryButton = CreateButton('randomCountryButton', "Random Country", OnRandomCountryButtonPress,
										ButtonAnchorPos, RandomCountryButtonX, RandomCountryButtonY);

	/*
		Bio
	*/										
	RandomBioButtonX = RandomFirstNameButton.X;
	RandomBioButtonY = RandomCountryButton.Y + RandomCountryButton.Height + BUTTON_SPACING;
	RandomBioButton = CreateButton('randomBioButton', class'UIUtilities_Text'.static.AlignLeft("Random Biography"), OnRandomBioButtonPress,
									ButtonAnchorPos, RandomBioButtonX, RandomBioButtonY);
}

simulated function UIButton CreateButton(name ButtonName, string ButtonLabel, delegate<OnClickedDelegate> OnClickCallThis, 
											int AnchorPos, int XOffset, int YOffset)
{
	local UIButton Button;

	Button = CurrentScreen.Spawn(class'UIButton', CurrentScreen);
	Button.InitButton(ButtonName, class'UIUtilities_Text'.static.GetSizedText(ButtonLabel, BUTTON_FONT_SIZE), OnClickCallThis);
	Button.SetAnchor(AnchorPos);
	Button.SetPosition(XOffset, YOffset); // relative to anchor, per other SetPos call comments I've seen.
	Button.SetSize(Button.Width, BUTTON_HEIGHT);
	
	return Button;
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
	
	// TODO: generate new name
	// XGCharacterGenerator class has member GenerateName(int gender, name countryname, OUT string first, OUT string last, optional int race)
	// function NameCheck in XComGameState_Unit takes an XGCharacterGenerator as param (then calls GenerateName)
	// Looks like the character generator is often instantiated locally: local XGCharacterGenerator CharacterGenerator;	
	// Need iGender, which is member of kAppearance, which is member of Unit.
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
	local string 					strNewFirstName;
	local string					strNewLastName;
	
	local string 					strFirstName;
	local string 					strNickName;
	local string 					strLastName;
	
	strFirstName = Unit.GetFirstName();
	strNickName = Unit.GetNickName();
	strLastName = Unit.GetLastName();	
	
	strNewFirstName = "NEWNAME";	// have to catch it whether or not I use it.
	strNewLastName = "NEWLAST";
	
	// XGCharacterGenerator class has member GenerateName(int gender, name countryname, OUT string first, OUT string last, optional int race)
	// function NameCheck in XComGameState_Unit takes an XGCharacterGenerator as param (then calls GenerateName)
	// Looks like the character generator is often instantiated locally: local XGCharacterGenerator CharacterGenerator;
	// ...will it let me do that? (Yes.)	
	// Need iGender, which is member of kAppearance, which is member of Unit.
	CharacterGenerator.GenerateName(Unit.kAppearance.iGender, Unit.GetCountry(), strNewFirstName, strNewLastName, Unit.kAppearance.iRace);
	
	Unit.SetUnitName(strFirstName, strNewLastName, strNickName);
	UpdateCharacterBio(strLastName, strNewLastName);
	ForceCustomizationMenuRefresh();
}

simulated function OnRandomCountryButtonPress(UIButton Button)
{
	// XGCharacterGenerator has member PickOriginCountry() which returns a name ''
	// Country looks to be stored in kSoldier (TSoldier) private member of XGCharacterGenerator.
	// XComGameState_Unit has members SetCountry and GetCountry. Boom?
	local string					strOldCountry;
	local name						newCountry;
	local string					strNewCountry;

	strOldCountry = Unit.GetCountryTemplate().DisplayName;

	newCountry = CharacterGenerator.PickOriginCountry();
	Unit.SetCountry(newCountry);
	strNewCountry = Unit.GetCountryTemplate().DisplayName;

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

	// Getting past this point with an empty string (in particular an
	// empty nickname) results in the hang and crash; not sure what
	// specifically triggers it yet.

	// The frequent offender is the RandomNickNameButton when clicked
	// on a soldier with an empty name...which is allowable in the
	// Character Pool (stock) and when someone uses the Full Customization
	// Mod.

	/*
		The old bio has a three line header: DOB, country of origin, and a blank line.
		Shipping this as is will result in a similar (but different) header being
		stuck on top. Only way to avoid this is to cut off the top three lines
		prior to shipping.
	*/

	`log(" ");
	`log("* * * * * * * * * * * * * * * * * * * * * *");
	`log("UPDATE BIO");
	`log("* * * * * * * * * * * * * * * * * * * * * *");
	`log(" ");

	oldBio = Unit.GetBackground();
	oldBio = Split(oldBio, "\n", true);
	oldBio = Split(oldBio, "\n", true);
	oldBio = Split(oldBio, "\n", true);

	newBio = Repl(oldBio, oldName, newName, true); // enforce case sensitivity
	
	Unit.GenerateBackground(newBio);
}

//event OnReceiveFocus(UIScreen Screen);

//event OnLoseFocus(UIScreen Screen);

event OnRemoved(UIScreen Screen)
{
	/*
		Still not clear to me that this is necessary...but how
		could it not be?
	*/
	// cleanup
	CharacterGenerator.Destroy();

	RandomFirstnameButton.Destroy();
	RandomNicknameButton.Destroy();
	RandomLastnameButton.Destroy();
	RandomCountryButton.Destroy();
}

defaultproperties
{
	ScreenClass = class'UICustomize_Info';
}

simulated function ForceCustomizationMenuRefresh()
{
	`log("Forcing Customization Menu Screen to update (Random Nickname Button Mod).");
	
	// UICustomize has member UISoldierHeader Header.
	// UISoldierHeader derives from UIPanel.
	// UISoldierHeader has member PopulateData(unit) which,
	// combined with the refresh call, MIGHT do the trick
	// THIS WORKS but feels janky with the current refresh call; wish I could just refresh the header.
	UICustomize_Info(CurrentScreen).Header.PopulateData(Unit);
	UICustomize_Info(CurrentScreen).UpdateData();							// hopefully force update on stock button labels themselves
	UICustomize_Info(CurrentScreen).CustomizeManager.Refresh(Unit, Unit);	// bit of a hack
}

/*
	SUPPORT CODE RIPPED FROM UICustomize.uc
*/

simulated function XComGameState_Unit GetUnit()
{
	// Here I am NOT trusting my assumption (see InShell() below).
	if (CurrentScreen != none)
	{
		Unit =  CurrentScreen.Movie.Pres.GetCustomizationUnit();
	}

	return Unit;
}

simulated function bool InShell()
{
	// Hopefully my assumption is correct that CurrentScreen will never be "none".
	// Shouldn't be as it gets populated in OnInit, which is called before this ever
	// will be. Right?
	return XComShellPresentationLayer(CurrentScreen.Movie.Pres) != none;
}