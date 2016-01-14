$ ->
  $.datepicker.setDefaults
    dateFormat: "yy-mm-dd",
    changeYear: true,
    yearRange: "1950:2000",
    maxDate: "2000-12-31",
    minDate: "1940-01-01",
    firstDay: 1,
    showOtherMonths: true,
    hideIfNoPrevNext: true

  $('#released_on').datepicker({})

  $('#like input').click (event) ->
    event.preventDefault()
    $.post(
      $('#like form').attr('action')
      (data) -> $('#like p').html(data).effect('highlight', color: '#fcd')
    )
