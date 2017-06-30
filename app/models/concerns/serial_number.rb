module Concerns
  module SerialNumber

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def create_sn
        year_code=%w{A B C D E F G H I J K}
        month_code=%w{1 2 3 4 5 6 7 8 9 A B C D E F}
        day_code=%w{1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W}
        year_sn = year_code[Time.now.year-2014] # 1 bit
        month_sn = month_code[Time.now.month-1] # 1 bit
        day_sn = day_code[Time.now.day] # 1 bits
        sec_sn = (Time.now.to_i.to_s)[-5..-1] # 5 bits
        millisecond_sn = Time.now.strftime("%3N").to_s # 3 bits
        #microsecond_sn = Time.now.strftime("%6N").to_s # 6 bits
        rand_sn = rand(99).to_s.rjust(2, "0") #2 bits
        year_sn+month_sn+day_sn+sec_sn+millisecond_sn+rand_sn # 13 bits
      end
    end
  end
end