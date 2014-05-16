// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var paypersocial = { 
	init : function() {
		this.newsletter_on_off_options();
		this.newsletter_radio_button_select();
		this.newsletter_init();
		this.campaigns_filter_change();
		this.handle_share_click();
	}, 

	newsletter_init :function() {
		$('#newsletter div#newsletter_decision').hide();
		paypersocial.newsletter_on_off_init();
		paypersocial.newsletter_radio_button_select_init();
	},
	
	newsletter_on_off_options : function() {
		$('#newsletter input#publisher_send_newsletters').bind('click', function(){
			paypersocial.newsletter_on_off_init();
		});
	},
	
	newsletter_on_off_init : function() {
		if($('#newsletter #publisher_send_newsletters:checked').is(':checked')) {
			$('#newsletter div#newsletter_decision').slideDown(500);
		} else {
			$('#newsletter div#newsletter_decision').slideUp(500);
		}
	},

	newsletter_radio_button_select : function() {
		$('#publisher_news_use_facebook_email_false').bind('click', function(){
			paypersocial.newsletter_radio_button_select_init();
		});
		$('#publisher_news_use_facebook_email_true').bind('click', function(){
			paypersocial.newsletter_radio_button_select_init();
		});
	},
	
	newsletter_radio_button_select_init :function() {
		if ($('#publisher_news_use_facebook_email_false').attr('checked') == 'checked') {
			$('#publisher_news_alternative_email').prop('disabled', false);
		} else if ($('#publisher_news_use_facebook_email_true').attr('checked') == 'checked') {
			$('#publisher_news_alternative_email').prop('disabled', true);
		}
	},

	campaigns_filter_change : function() {
		$("#campaign_click_company_name").change(function() {
			href = $('#filter_campaings_by_name_click').attr('href').split('=')[0];
			$('#filter_campaings_by_name_click').attr('href', href + '=' + $(this).val());
			$('#filter_campaings_by_name_click')[0].click();
		});
	},
	
	handle_share_click : function() {
		// #. handle click
		// #. display popup with share and cancel buttons; copy image url, ad_id, etc to popup
		// #. popup should contain a text area for message
		// #. pupup should contain a post form
		// #. click on cancel will cleanup popup and close it
		// #. click on share will post data on server: ad_id & publisher message
	}
};

$(document).ready(function() {
	$(".alert-message").alert();
	$("table.sortable_table").tablesorter();
	if ($(document).height() > $(window).height())
		height = $(document).height();
	else
		height = $(window).height();
	height = height - 40;
	$('.sidebar').height(height);

	$("#campaign_click_status").change(function() {
		href = $('#filter_campaings_clicks').attr('href').split('=')[0];
		$('#filter_campaings_clicks').attr('href', href + '=' + $(this).val());
		$('#filter_campaings_clicks')[0].click();
	});
	
	$("#tracking_request_status").change(function(){
		href = $('#filter_campaign_clicks_details').attr('href').split('=')[0];
		$('#filter_campaign_clicks_details').attr('href', href + '=' + $(this).val());
		$('#filter_campaign_clicks_details')[0].click(); 
	});
	
	$("#btnSaveStatus").bind('click', function() {
		var tracking_requests = [];
		$(":checkbox.check_all_element:checked").each(function(){
			tracking_requests.push($(this).val());
		});
		if(tracking_requests.length == 0){
			return;
		}
		
		$('form#save_selected_statuses input[name=new_status]').val($('select#trackingStatus').val());
		$('form#save_selected_statuses input[name=tracking_requests]').val(tracking_requests);
		$('form#save_selected_statuses input[type=submit]').click();
	});
	
	paypersocial.init();
});