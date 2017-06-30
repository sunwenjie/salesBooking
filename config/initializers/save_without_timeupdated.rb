module ActiveRecord
  class Base
    def save_without_timestamping
      class << self
        def record_timestamps; false; end
      end
      save
      class << self
         def record_timestamps; super ; end
      end
    end
  end
end