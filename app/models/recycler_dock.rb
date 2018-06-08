#
class RecyclerDock < Version
  include CsvExportable
  #
  default_scope { where(event: :destroy).order(created_at: :desc) }
end
