/* This javascript is included in: admin/ad/index.html.erb */
$(document).ready(function() {
	
	// Detecting drop-down menu changes
	$('#category_id').change(function(){
		
		// Getting campaing and category
		ad = $(this).parent().attr('class').split('_')[1]; // campaing is setted in "hide_edit_category_if" helper method
		category = $(this).val();
		
		$.ajax({
		  url: 'ads/'+ad+'/change_category/'+category,
		  success: function( data ) {
				//alert('Done!');
			}
		});
	});
});
