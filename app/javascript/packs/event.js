// Toggle tooltip
$(() => {
  $('[data-toggle="tooltip"]').tooltip();
});

$(document).ready(() => {
  // Select/Deselect all checkboxes
  $('button#toggle-all').on('click', () => {
    let checkboxes = $('input:checkbox');
    if (checkboxes.prop('checked')) {
      checkboxes.prop('checked', false);
      $('.collapse').collapse('hide')
    } else {
      checkboxes.prop('checked', true);
      $('.collapse').collapse('show')
    }
  });

  // File upload
  $('input:file').on('change', function () {
    $(this).next('.custom-file-label').html($(this).val().replace('C:\\fakepath\\', ''));
  });

  // Expand checkboxes and radio buttons
  $('li[class*="list-group-item-action"]').on('click', function (e) {
    if (e.target !== this)
      return;

    let input = $(this).find('input');
    input.prop('checked', input.attr('type') === 'radio' ? true : !input.is(':checked'));
  });

  // make radio button active
  $('li[class*="list-group-item-action"]').on('click', function () {
    let input = $(this).find('input');
    if (input.attr('type') === 'radio') {
      $(this).parent().find('li[class*="active"]').removeClass('active');
      $(this).addClass('active');

      let selected_id = '_submissions_' + $(this).attr('id');
      let selected_div = $('#' + selected_id);

      $("div[id^='_submissions_'][id!='" + selected_id + "']").collapse('hide');
      $("#_submissions").collapse('show');

      if (!selected_div.hasClass('show')) {
        selected_div.collapse('show');
      }

      $('html, body').animate({
        scrollTop: selected_div.offset().top - 200
      }, 500);
    }
  });
});

// Keep input values on page reload until session expires
if (window.sessionStorage) {
  let url = $(location).attr('href');

  $(document).ready(() => {
    let selectorInputCheckbox = $(':checkbox');
    let selectorInputRadio = $(':radio');
    let selectorInputText = $(':text');

    selectorInputCheckbox.each(function () {
      let item = `${url}?${$(this).attr('id')}`;
      $(this).prop('checked', JSON.parse(sessionStorage.getItem(item)) || $(this).is(':checked'));
      // Only restore once or clear on page reload
      sessionStorage.removeItem(item);
    });
    selectorInputRadio.each(function () {
      let item = `${url}?radio`;
      $(`input#${sessionStorage.getItem(item)}`).prop('checked', true);
      // Only restore once or clear on page reload
      sessionStorage.removeItem(item);
    });
    selectorInputText.each(function () {
      let item = `${url}?${$(this).attr('id')}`;
      $(this).val(sessionStorage.getItem(item) || $(this).val());
      // Only restore once or clear on page reload
      sessionStorage.removeItem(item);
    });

    selectorInputCheckbox.on('change', function () {
      sessionStorage.setItem(`${url}?${$(this).attr('id')}`, $(this).is(':checked'));
    });
    selectorInputRadio.on('change', function () {
      sessionStorage.setItem(`${url}?radio_check`, $(this).attr('id'));
    });
    selectorInputText.on('change', function () {
      sessionStorage.setItem(`${url}?${$(this).attr('id')}`, $(this).val());
    });
  });
}
