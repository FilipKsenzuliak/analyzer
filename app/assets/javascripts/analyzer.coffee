# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


window.group = ->
  if $( "input:checked" ).length >= 2
    values = []
    checked = $('input:checked')
    sign = false
    first = null
    checked.each ->
      if sign
        $(this).closest('tr').hide("slow")
      else
        first = $(this)
      $(this).attr('checked', false)
      sign = true
      values.push $(this).val()

    first.parent().nextAll().eq(1).html(values.join(' '))
    first.attr('value', values.join(' '))
    button = $('.group')
    button.attr('id', '')

window.pat = ->
  $('.output-pattern').show(200)
  $('#p-arrow').fadeIn(1000)
  values = []
  $('.table tr:visible td:nth-child(2) div input').each ->
    values.push $(this).val()
  $('#pattern_text').val(values.join('::'))

$(document).on 'ready page:load', ->
  $(":checkbox").on "change", ->
    button = $('.group')
    if $( "input:checked" ).length >= 2
      button.attr('id', 'green')
    else
      button.attr('id', '')

$(document).on 'ready page:load', ->
  $(".group").on "click", ->
    if $( "input:checked" ).length == 0
      $('#arrow').fadeIn(1000)

$(document).on 'ready page:load', ->
  $("#parts").on "mouseover", ->
    $('#suggestion').css('visibility', 'visible')

$(document).on 'ready page:load', ->
  $('#s-arrow').fadeIn(1000)

$(document).on 'ready page:load', ->
  $(".table tr").on "click", ->
    className = $(this).attr('class').split(' ')[0]
    


