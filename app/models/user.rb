class User < ActiveRecord::Base
    def self.for_session(eppn, display_name)
        return nil if eppn == nil
        user = User.find_by_eppn(eppn)
        if user == nil
            Rails.logger.info("Created user for EPPN: #{eppn}")
            user = User.new(eppn: eppn, display_name: display_name)
            user.save!
        end
        user
    end
end