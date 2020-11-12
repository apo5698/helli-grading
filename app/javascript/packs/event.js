$(document).on('turbolinks:load', () => {
  // Tooltip
  $('[data-toggle="tooltip"]').tooltip();

  // Collapse toggle
  $('.collapse').collapse({ toggle: false });

  // Rotate icon
  $('.collapsed').on('click', function () {
    $(this).find("[class*='rotate']").toggleClass("down");
  });

  // File upload
  $('input:file').on('change', function () {
    const filename = $(this).val().split('\\').pop();
    $(this).siblings('label').html(filename);
  });

  // Select/deselect all
  $('input#select-all').on('click', () => {
    let checkboxes = $('input:checkbox[id!="select-all"]');
    checkboxes.prop('checked', !checkboxes.prop('checked'));
  });
  $('button#select-all').on('click', () => {
    let checkboxes = $('input:checkbox');
    checkboxes.prop('checked', !checkboxes.prop('checked'));
  });
});
