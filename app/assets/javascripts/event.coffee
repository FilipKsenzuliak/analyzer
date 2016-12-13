# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).on 'ready page:load', ->
  $('#event-arrow').fadeIn(1000)

window.event_pattern = ->
  values = []
  $('.table tr td input').each ->
    values.push($(this).val())
  console.log values.join(' ')
  $.ajax '/save_event' , 
  type: "POST",
  dataType: "JSON",
  data: 
    event_pattern: values.join(' ')
    log_pattern: $('.log-pattern').html()
  asnyc: false,
  success: (data) ->
    $('#notification').html('Pattern was successfully saved')
    $('#notification').fadeOut(3000)


$(document).on 'ready page:load', ->
	if $('#warn').html() != ''
		$('.event-data').prop('disabled', true)

window.event_tag = ->
  $('.output-tag').show(200)