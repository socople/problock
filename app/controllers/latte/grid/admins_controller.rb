module Latte
  module Grid
    #
    class AdminsController < GridController
      include Mtable

      def model
        Admin
      end

      def permits
        %i[name email]
      end
    end
  end
end
