class User < ActiveRecord::Base
    def self.user_for_session(eppn, display_name)
        user = User.find_by_eppn(eppn)
        if user == nil
            user = User.new(eppn: eppn, display_name: display_name)
            user.save!
        end
        user
    end
end