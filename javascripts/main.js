console.log('This would be the main JS file.');

$(document).ready(function() {
	var img = ($('.circular-hidden').text());
	console.log("Hidden Image: " + img);
	if ( img != '/images/politicians/') {
		$('.circular').css('background', "url('"+ img +"')");
	}
});

