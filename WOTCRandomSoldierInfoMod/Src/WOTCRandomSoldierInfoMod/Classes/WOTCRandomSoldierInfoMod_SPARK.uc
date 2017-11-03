
/*
	Listener for SPARK support.
*/

class WOTCRandomSoldierInfoMod_SPARK extends UIScreenListener
	config(WOTCRandomSoldierInfoMod);

var RandomSoldierInfoButtonPanel buttonPanel;

event OnInit(UIScreen Screen)
{
	class'RandomSoldierInfoButtonPanel'.static.BigLog("Loading WOTCRandomSoldierInfoMod_SPARK.");

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
	ScreenClass = class'UICustomize_SparkInfo';
}

