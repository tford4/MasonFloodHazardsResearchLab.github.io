/* Template Housekeeping (requires jQuery) */

$(document).ready(function()
{
	/* Fixes borders on tabs */

	$(".tabs ul li:first-child").wrapInner("<span></span>");
	$(".tabs ul li:first-child").addClass("first");
	$(".tabs ul li:last-child").addClass("last");

	/* Adjust title padding if there isn't a search form */

	if (($("#title h2").length > 0) && ($("#search-form").length == 0))
		$("#title").addClass("no-search");
		
	/* Dropdown menus */
	
	$(".tabs li").mouseover(function() {
		$(this).addClass("hover");
	}).mouseout(function() {
		$(this).removeClass("hover");
	});
	
	/* Making them keyboard accessible (based off of http://carroll.org.uk/sandbox/suckerfish/bones2.html */
	
	$(".tabs a").each(function() {
		$(this).focus(function() {
			$(this).parent().addClass("hover");
			$(this).parents("li").addClass("hover");
		});
		
		$(this).blur(function() {
			$(this).parent().removeClass("hover");
			$(this).parents("li").removeClass("hover");
		});
	});

});