// Toggle tooltip
$(() => {
  $('[data-toggle="tooltip"]').tooltip();
});

$(document).ready(() => {
  $('input:file').on('change', function () {
    $(this).next('.custom-file-label').html($(this).val().replace('C:\\fakepath\\', ''));
  });
});
