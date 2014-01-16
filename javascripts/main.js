console.log('This would be the main JS file.');

$(document).ready(function() {
	var img = ($('.profile-circular-hidden').text());
	console.log("Hidden Image: " + img);
	if ( img != '/images/politicians/') {
		$('.profile-circular').css('background', "url('"+ img +"')");
		$('.profile-circular').css('background-size', "160px 160px");
	}
});
