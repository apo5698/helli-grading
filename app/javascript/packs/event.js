$(document).on('click', '#options-select-all', () => {
  $("#options input:checkbox").prop('checked', true);
}); // Check all checkboxes

$(document).on('click', '#options-reset', () => {
  $("#options input:checkbox").prop('checked', false);
}); // Uncheck all checkboxes

window.customAdd = (placeholder, count) => {
  $("#custom-compile").append(
    `<div class="input-group mb-2" id="custom-command-${count}">` +
    `<input type="text" class="form-control">` +
    `<div class="input-group-append">` +
    `<button type="button" class="btn btn-primary" id="custom-command-${count}">Remove` +
    `</button></div></div>`);
}; // Add a custom command

$(document).on('click', "button[id^='custom-command-']", (e) => {
  $(`#${e.target.id}`).remove();
}); // Remove a custom command

$(() => {
  $('[data-toggle="tooltip"]').tooltip();
}); // Toggle tooltip

$(document).ready(() => {
  $('li#checkbox').on('click', function () {
    if ($(this).hasClass('active')) {
      $(this).removeClass('active');
    } else {
      $(this).addClass('active');
    }
    let checkbox = $(this).children('.custom-checkbox').children('input.custom-control-input');
    checkbox.prop('checked', !checkbox.is(':checked'));
  });
  $('li#radio').on('click', function () {
    if (!$(this).hasClass('active')) {
      $('li#radio').removeClass('active');
      $(this).addClass('active');
      $(this).children('input').prop('checked', true);
    }
  });
}); // Multi-select list buttons
