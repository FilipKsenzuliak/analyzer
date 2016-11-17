# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'change', ".parsers", ->
  selectValue = $('.parsers').val()
  if selectValue == 'Tokens'
    $('#tokens').show()
    $('#groups').hide()
  if selectValue == 'Groups'
    $('#groups').show()
    $('#tokens').hide()