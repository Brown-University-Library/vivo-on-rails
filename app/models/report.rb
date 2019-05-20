class Report < ActiveRecord::Base
    # Calculate a name that can be used for the report
    # when is downloaded as a file.
    def download_name(ext)
        if self.name == nil || self.name.strip == ""
            return "untitled.#{ext}"
        end
        # strip non alpha numeric characters
        # and make sure it starts with a-z or _
        safe_name = self.name.strip.downcase.gsub(/[^0-9a-z]/i,"_")
        if safe_name[0] < 'a' || safe_name[0] > 'z'
            safe_name = "_#{safe_name}"
        end
        "#{safe_name}.#{ext}"
    end

    def mine?(user_id)
        self.user_id == user_id
    end
end