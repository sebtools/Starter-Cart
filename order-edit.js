function loadActions() {
	changeAction();
}
function changeAction() {
	var oAction = document.getElementById('Action');
	var action = "";
	
	if (oAction) {
		action = oAction.options[oAction.selectedIndex].text;
		
		if (action == "Ship") {
			oSebForm.toggleField("ShipperTrackingNumber", "show");
		}
		else {
			oSebForm.toggleField("ShipperTrackingNumber", "hide");
		}
	}
}
window.cart.addEvent(window, 'load', loadActions);