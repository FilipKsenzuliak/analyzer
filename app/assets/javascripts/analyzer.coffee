# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->
  $(":checkbox").on "change", ->
    button = $('.group')
    if $( "#table .analyzer tr input:checked" ).length >= 2
      button.attr('id', 'green')
    else
      button.attr('id', '')

window.group = ->
  if $( "#table .analyzer tr" ).length >= 2
    values = []
    checked = $('#table .analyzer tr input:checked')
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
  $('.table tr:visible td:nth-child(2)>div>input').each ->
    values.push "%{" + $(this).val().toString() + "}"
  separator = $("#separator").val().toString()
  if separator == '(space)'
    separator = ' '
  $('#pattern_text').val(values.join(separator))

$(document).on 'ready page:load', ->
  $(".group").on "click", ->
    if $( "input:checked" ).length == 0
      $('#g-arrow').fadeIn(1000)

$(document).on 'ready page:load', ->
  $("#help_submit").on "click", ->
    $.get($("#search_form").attr("action"), $("#search_form").serialize(), null, "script")
    return false

$(document).on 'ready page:load', ->
  $('#s-arrow').fadeIn(1000)

$(document).on 'ready page:load', ->
  $(".arrow-down").on "click", ->
    if $(this).attr('class') == 'arrow-down' 
      $(this).addClass('arrow-up').removeClass('arrow-down')
    else
      $(this).addClass('arrow-down').removeClass('arrow-up')
    className = $(this).closest('tr').attr('class')
    if $(this).closest('tr').next().attr('class') == className
      $(this).closest('tr').next().fadeToggle(1000)

$(document).on 'ready page:load', ->
  $(".submit-btn").click (event) ->
    event.preventDefault()
    $(this).prev().submit()

$(document).on 'ready page:load', ->
  elements =  $('.table tbody tr:visible')
  elements.each ->
    if $(this).attr('class') != '<UNKNOWN>'
      $(this).find("td:nth-child(2)>div>input").css('background-color', '#b2e8ae')


