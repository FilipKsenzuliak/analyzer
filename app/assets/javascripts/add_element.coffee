$(document).on 'ready page:load', ->
  $('.submit-btn').on 'click', ->
    value = $(this).closest('td').next().html().trim() 
    element = $(this).closest('tr')
    $('.split-confirm').on 'click', ->
      element.hide()
      split = $('#split').val()
      if split == 'space'
        split = ' '
      parts = value.split(split)
      for part in parts
        element.after(createPattern(part))

$(document).on 'ready page:load', ->
  $('#splitModal').on 'hide.bs.modal', ->
    $('.split-confirm').unbind()

window.createPattern = (data) ->
  pattern = """
  <tr class='<UNKNOWN>'>
    <td id='check'><input type='checkbox' class='group' name='newsletter' value='#{data}'/></td>
    <td id="attribute">
      <div class="input-group">
        <input type="text" class="form-control" aria-label="Text input with dropdown button" id="expand" value='<UNKNOWN>'>
        <div class="input-group-btn">
          <a class="btn btn-primary btn-lg dropdown-toggle" data-toggle="dropdown" href="#">
            <span class="caret"></span>
          </a>
          <div class="dropdown-menu dropdown-menu-right">
            <li>
              <a href="" data-toggle="modal" data-target="#approvalModal">
                Create parser
              </a>
            </li>
            <li>
              <a href="" data-toggle="modal" data-target="#splitModal" class="submit-btn">
                Split expression
              </a>
            </li>
          </div>
        </div>
      </div>
    </td>
    <td id="value">
      #{data}
    </td>
    <td id="arrow"></td>
    <td id="regex"><textarea class="form-control" id="text-regex" readonly> No regular expression available </textarea></td>
  </tr>
  """