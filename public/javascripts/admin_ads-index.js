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

	$(".reject_btn").click(function(){
		var ad_id = $(this).attr("id");
		$("#reject_modal").append("<span id='ad_id' hidden>" + ad_id + "</span>");
		$("#reject_modal").modal("show");
	});

	$("#reject_ad").click(function(){
		var ad_id = $("#ad_id").text();
		var message = $("#ad_state").val();
		$.post("/admin/ads/" + ad_id + "/reject", {message: message});
		$("#reject_modal").modal("hide");
	});
});
