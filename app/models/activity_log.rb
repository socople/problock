#
class ActivityLog < Version
  include CsvExportable
  #
  default_scope { where.not(event: :destroy).order(created_at: :desc) }
end
