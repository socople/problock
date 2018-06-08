begin
  Setting.first_or_create(name: 'Settings')
rescue
  nil
end
