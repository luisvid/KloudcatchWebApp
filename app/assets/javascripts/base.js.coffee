jQuery ->
  locale = $("#locale").html()
  $("#droplets_table").dataTable
    sPaginationType: "full_numbers"
    bJQueryUI: true
    oLanguage: {sUrl: "/datatables-" + locale + ".txt"}
    bProcessing: true
    bServerSide: true
    sAjaxSource: $("#droplets_table").data("source")
  $("#users_table").dataTable
    sPaginationType: "full_numbers"
    bJQueryUI: true
    oLanguage: {sUrl: "/datatables-" + locale + ".txt"}
    bProcessing: true
    bServerSide: true
    sAjaxSource: $("#users_table").data("source")
  contactsTable = $("#contacts_table").dataTable
    sPaginationType: "full_numbers"
    bJQueryUI: true
    oLanguage: {sUrl: "/datatables-" + locale + ".txt"}
    aoColumnDefs: [{bSearchable: false, bVisible: false, aTargets: [4]}]
    bProcessing: true
    bServerSide: true
    sAjaxSource: $("#contacts_table").data("source")
  $(".carousel").carousel()
  $(".accordion .btn").click ->
    $(this).parents(".accordion").find(".btn").removeClass("active")
    $(this).addClass("active")
  $('.tooltip, a[rel="tooltip"]').tooltip()
  $(".details").live "click", () ->
    nTr = $(this).parents('tr')[0]
    if contactsTable.fnIsOpen(nTr)
      contactsTable.fnClose(nTr)
    else
      contactsTable.fnOpen(nTr, fnFormatContactDetails(contactsTable, nTr), 'details')
    return false
  $(".delete").live "click", () ->
    if $(this).data("confirm")
      nTr = $(this).parents('tr')[0]
      table_id = "#" + $(this).parents('table.display').attr("id")
      table = $(table_id).dataTable()
      console.log "table_id: " + table_id + ", nTr: " + nTr
      $.ajax
        url: $(this).data("url")
        data: {"_method": "delete"}
        dataType: "json"
        type: "POST"
        success: fnRemoveRecord(table, nTr)
    return false
  $(".toggle_admin").live "click", () ->
    if $(this).data("confirm")
      delete_button = $(this).prev("a.delete")
      toggle_admin_button = $(this)
      $.ajax
        url: $(this).data("url")
        dataType: "json"
        type: "POST"
        success: (data) ->
          toggle_admin_button.remove() 
          delete_button.after(data.html)
    return false
  $(".disable_dropbox").live "click", () ->
    if $(this).data("confirm")
      $.ajax
        url: $(this).data("url")
        dataType: "json"
        success: (data) ->
          $("#dropbox").html(data.html)
    return false
  $("#change_password").live "click", () ->
    $(this).addClass("hidden")
    $(".password_field").removeAttr("disabled")
    $("#password_fields").removeClass("hidden")
    return false
  $("#forgot_password").live "click", () ->
    email = $(this).parents("form:first").find("#sessions_email").val()
    if email is ""
      alert $(this).data("alert")
    else
      $.ajax
        url: $(this).data("url")
        dataType: "json"
        data: {email: email}
        success: (data) ->
          alert data.message
    return false
  $("#reset_password").live "click", () ->
    email = $(this).parents("form:first").find("#sessions_email").val()
    if email is ""
      alert $(this).data("alert")
    else
      $.ajax
        url: $(this).data("url")
        type: "POST"
        dataType: "json"
        data: {email: email}
        success: (data) ->
          alert data.message
    return false
    
fnRemoveRecord = (table, nTr) ->
  table.fnDeleteRow(nTr)

fnFormatContactDetails = (table, nTr) ->
  aData = table.fnGetData(nTr)
  sOut = '<table cellpadding="0" cellspacing="0" border="0" style="padding-left:50px;">'
  sOut += '<tr><td>' + aData[4] + '</td></tr>'
  sOut += '</table>'
  return sOut
window.fnFormatContactDetails = fnFormatContactDetails
