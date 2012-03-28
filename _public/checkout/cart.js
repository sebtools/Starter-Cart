//self-executing anonymous function
(function(){
	if(!window.cart) { window.cart = {} }
	
	//Public methods
	addEvent = function(obj, evType, fn) {
		if (obj.addEventListener){
			obj.addEventListener(evType, fn, true);
			return true;
		} else if (obj.attachEvent){
			var r = obj.attachEvent("on"+evType, fn);
			return r;
		} else {
			return false;
		}
	};
	window.cart.addEvent = addEvent;
	
	addEventToId = function(id, evType, fn) {
		window.cart.addEvent(document.getElementById(id), evType, fn);
	}
	window.cart.addEventToId = addEventToId;
	
	setStyleById = function(i, p, v) {
		var n = document.getElementById(i);
		n.style[p] = v;
	};
	window.cart.setStyleById = setStyleById;
	
	ship2bill = function() {
		var isRequired = true;
		var shipdisplay = "block";
		if ( document.getElementById('ship2billing') && document.getElementById('group-billaddress') && document.getElementById('group-shipaddress') ) {
			
			if ( document.getElementById('ship2billing').checked ) {
				isRequired = false;
				shipdisplay = "none"
			}
			jsfrmSebform["Ship_FirstName"].required = isRequired;
			jsfrmSebform["Ship_LastName"].required = isRequired;
			jsfrmSebform["Ship_Address1"].required = isRequired;
			jsfrmSebform["Ship_City"].required = isRequired;
			jsfrmSebform["Ship_StateProvinceID"].required = isRequired;
			jsfrmSebform["Ship_PostalCode"].required = isRequired;
			window.cart.setStyleById('group-shipaddress','display',shipdisplay);
		}
	}
	window.cart.ship2bill = ship2bill;
	getURL = function(url) {
		var oImg = new Image();
		oImg.src = url;
	}
	window.cart.getURL = getURL;
	addItem = function(ProductIdentifier) {
		var addurl = "cart.cfc?method=addItem&" + ProductIdentifier;
		getURL(addurl);
	}
	window.cart.addItem = addItem;
	removeItem = function(ProductIdentifier) {
		var addurl = "cart.cfc?method=removeItem&" + ProductIdentifier;
		getURL(addurl);
	}
	window.cart.removeItem = removeItem;
	
	//Private methods
	function initBill2Ship() {
		if ( document.getElementById('ship2billing') ) {
			var myfunc = window.cart.ship2bill;
			window.cart.addEventToId('ship2billing','click',myfunc);
			window.cart.ship2bill();
		}
	}
	window.cart.initBill2Ship = initBill2Ship;
	function initCCV() {
		if ( document.getElementById('cart-ccv-helplink') ) {
			var myfunc = function() {
				window.open(this.href,'ccv-help','status=0,toolbar=0,location=0,menubar=0,directories=0,width=250,height=250');
				return false;
			};
			document.getElementById('cart-ccv-helplink').onclick = myfunc;
		}
	}
	window.cart.initCCV = initCCV;
	loadCartWindow = function() {
		initBill2Ship();
		initCCV();
	}
	window.cart.loadCartWindow = loadCartWindow;
	
	
	//Take action
	addEvent(window,'load',window.cart.loadCartWindow);
	
	window.oCart = window.cart;
})();
