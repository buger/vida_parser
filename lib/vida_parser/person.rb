
module VidaParser
  class Person
    DIRECTOR = 1
    ACTOR = 2
    HEAD = 3 # Руководитель
    PRODUCER = 4 
    CASTER = 5 # Ведущий

    attr_reader :name, :foreign_name, :description, :role

    def initialize(url, options = {})
      @url = url

      if @url.nil?
        @name = options[:name] 
        @foreign_name = options[:foreign_name]
        @role = options[:role]
      end        
    end

    def self.type_by_string(string)
      case string
      when "В ролях", "Звезды кино", "Звезды тв"
	ACTOR
      when "Режиссер", "Режиссеры"
	DIRECTOR
      when "Руководитель"
	HEAD
      when "Продюсер","Директоры"
	PRODUCER
      when "Ведущие", "Ведущий"
	CASTER
      else
	raise StandardError, "Не могу определить тип роли для '#{string}'"
      end
    end
  end
end
