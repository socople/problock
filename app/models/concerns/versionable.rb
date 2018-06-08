#
module Versionable
  extend ActiveSupport::Concern

  included do
    has_paper_trail class_name: 'Version',
                    ignore: %i[id created_at updated_at current_sign_in_at
                               last_sign_in_at encrypted_password
                               sign_in_count remember_created_at
                               current_sign_in_ip last_sign_in_ip
                               remember_created_at]
  end
end
