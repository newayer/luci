'use strict';
'require view';
'require dom';
'require ui';
'require form';
'require rpc';

var formData = {
	password: {
		pw1: null
	}
};
var m;
var flag=0;
var callSetUpgrade = rpc.declare({
	object: 'luci',
	method: 'setBlockDetect',
	params: [ 'url','mode' ],
	expect: { result: false }
});

return view.extend({
	checkPassword: function(section_id, value) {
		var strength = document.querySelector('.cbi-value-description'),
		    strongRegex = new RegExp("^(?=.{8,})(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*\\W).*$", "g"),
		    mediumRegex = new RegExp("^(?=.{7,})(((?=.*[A-Z])(?=.*[a-z]))|((?=.*[A-Z])(?=.*[0-9]))|((?=.*[a-z])(?=.*[0-9]))).*$", "g"),
		    enoughRegex = new RegExp("(?=.{6,}).*", "g");

		if (strength && value.length) {
			if (false == enoughRegex.test(value))
				strength.innerHTML = '%s: <span style="color:red">%s</span>'.format(_('Password strength'), _('More Characters'));
			else if (strongRegex.test(value))
				strength.innerHTML = '%s: <span style="color:green">%s</span>'.format(_('Password strength'), _('Strong'));
			else if (mediumRegex.test(value))
				strength.innerHTML = '%s: <span style="color:orange">%s</span>'.format(_('Password strength'), _('Medium'));
			else
				strength.innerHTML = '%s: <span style="color:red">%s</span>'.format(_('Password strength'), _('Weak'));
		}

		return true;
	},

	render: function() {
		var  s, o;
       	var body = E('hr');
		 
		m = new form.JSONMap(formData, _('功放功率控制'), _('设定功放的功率值'));
		m.readonly = !L.hasViewPermission();

		s = m.section(form.NamedSection, 'password', 'password');

		o = s.option(form.Value, 'pw1', _('功率值'));
        //var button = document.getElementById('cbi-button-save'); // 假设按钮的id为myButton
       // button.textContent = 'New Name'
		o.renderWidget = function(/* ... */) {
			var node = form.Value.prototype.renderWidget.apply(this, arguments);

			node.querySelector('input').addEventListener('keydown', function(ev) {
				if (ev.keyCode == 13 && !ev.currentTarget.classList.contains('cbi-input-invalid'))
					document.querySelector('.cbi-button-save').click();
			});

			return node;
		};
		m.render().then(function(formElement) {
         body.prepend(formElement);

        });
		
		body.appendChild(E('button', {
			'class': 'cbi-button cbi-button-action important',
			'click': ui.createHandlerFn(this, 'handleupgrade')
		}, _('下发')));
        
		return body;
	},

	handleupgrade: function() {
		var map = document.querySelector('.cbi-map');
		dom.callClassMethod(map, 'save').then(function() {
			if (formData.password.pw1 == null || formData.password.pw1.length == 0)
				return;
			if (flag == 1){
			  L.ui.addNotification(null, E('p', _('正在处理中，请耐心等待....')));
			  return;
			}
			flag =1;	
			L.ui.showModal(_('正在处理中…'), [
				E('p', { 'class': 'spinning' }, _('请稍后...'))
			]);
			return callSetUpgrade(formData.password.pw1,"1").then(function(res) {
			

			L.ui.awaitReconnect();
		})
		.catch(function(e) { L.ui.addNotificaon(null, E('p', e.message)) });
	    });
		

},

		/*return dom.callClassMethod(map, 'save').then(function() {
			if (formData.password.pw1 == null || formData.password.pw1.length == 0)
				return;


			/*return callSetPassword('root', formData.password.pw1).then(function(success) {
				if (success)
					ui.addNotification(null, E('p', _('The system password has been successfully changed.')), 'info');
				else
					ui.addNotification(null, E('p', _('Failed to change the system password.')), 'danger');

				formData.password.pw1 = null;
				formData.password.pw2 = null;

				dom.callClassMethod(map, 'render');
			});
			
	},*/
	
    handleSave: null,
	handleSaveApply: null,
	handleReset: null
});