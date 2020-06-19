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
      $('.collapse').collapse('hide');
    } else {
      checkboxes.prop('checked', true);
      $('.collapse').collapse('show');
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
});
