
module VidaParser
  class Person
    attr_reader :name, :foreign_name, :description, :role

    def initialize(url, options = {})
      @url = url

      if @url.nil?
        @name = options[:name] 
        @foreign_name = options[:foreign_name]
        @role = options[:role]
      end        
    end
  end
end
