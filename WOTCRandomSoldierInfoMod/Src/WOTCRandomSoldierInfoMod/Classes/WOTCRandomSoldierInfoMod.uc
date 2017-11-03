
/*

	Listener for general support (soldiers, reapers, and those advent turncoats)

	TODO.

	(IN PROGRESS.) SPARK is on deck now.

	BUGS.

	I should really track these on GitHub from now on.

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

