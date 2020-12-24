# frozen_string_literal: true

# noinspection RubyParameterNamingConvention
Capybara::RSpecMatchers.module_eval do
  def have_icon(**options, &optional_filter_block)
    Capybara::RSpecMatchers::Matchers::HaveSelector.new(:i, **options, &optional_filter_block)
  end

  (1..6).each do |header|
    define_method "have_h#{header}" do |text, **options, &optional_filter_block|
      Capybara::RSpecMatchers::Matchers::HaveSelector.new(
        "h#{header}",
        **options.merge(text: text),
        &optional_filter_block
      )
    end
  end

  def have_flash(style, **options, &optional_filter_block)
    Capybara::RSpecMatchers::Matchers::HaveSelector.new(
      'div',
      **options.merge(class: "alert alert-dismissible alert-#{style}"),
      &optional_filter_block
    )
  end
end
