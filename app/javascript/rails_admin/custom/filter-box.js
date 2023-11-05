$(document).on("click", "#filters a", function (e) {
    e.preventDefault();
    $.filters.append({
      label: $(this).data("field-label"),
      name: $(this).data("field-name"),
      type: $(this).data("field-type"),
      value: $(this).data("field-value"),
      operator: $(this).data("field-type") == 'string' ? 'like' : $(this).data("field-operator"),
      select_options: $(this).data("field-options"),
      required: $(this).data("field-required"),
      index: $.now().toString().slice(6, 11),
      datetimepicker_options: $(this).data("field-datetimepicker-options"),
    });
  });