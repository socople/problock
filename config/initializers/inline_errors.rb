ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  unless html_tag =~ /^<label/
    %{<div class="has-error">#{html_tag}<span class="help-block">#{instance.error_message.first}</span></div>}.html_safe
  else
    %{#{html_tag}}.html_safe
  end
end
