require "#{File.dirname(__FILE__)}/person"

module VidaParser
  class Media
    FILM = 1
    SERIAL = 2
    INFO = 3
    OTHER = 4
    KIDS = 5
    DOCUMENTAL = 6
    FUN = 7

    attr_reader :url,
                :media_type, 
                :parent_url,
                :title, :foreign_title, 
                :description, 
                :created, 
		:production_info,
                :always_record,
                :data, 
                :persons

    MEDIA_TYPE_XPATH = "//center/table[3]/tr/td[1]/table/tr[1]/td[@class='OkHead1']/font"
    TITLE_XPATH = "//center/table[3]/tr/td[1]/table/tr[2]/td/table/tr/td[@class='plain']/table[2]/tr[2]/td/div[1][@class='OkHead1']"

    PRODUCTION_INFO_XPATH = "//center/table[3]/tr/td[1]/table/tr[2]/td/table/tr/td[@class='plain']/table[2]/tr[4]/td[@class='OkTah11']"
    PRODUCTION_INFO_REGEXP = /Производство:(.*)(\d{4})\./
    
    DESCRIPTION_XPATH = ["//center/table[3]/tr/td[1]/table/tr[2]/td/table/tr/td[@class='plain']/table[2]/tr[6]/td[@class='OkVrdTD']/p[@class='OkAlign']",
			 "//center/table[3]/tr/td/table/tr[2]/td/table/tr/td[@class='plain']/table[2]/tr[4]/td[@class='OkVrdTD']/p[@class='OkAlign']"]

    PERSONS_XPATH = "//center/table[3]/tr/td[2]/table/tr[2]/td/table/tr/td[@class='plain']/table/tr/td/*"


    def initialize(url, options = {})
      @url = url

      @title = options[:title]
    end
    
    def parse
      return self if @url.nil?

      doc = Nokogiri::HTML(open(@url))

      @media_type = Media.get_type_by_string(doc.xpath(MEDIA_TYPE_XPATH).first.content.strip)

      @title = doc.xpath(TITLE_XPATH)
      if parent = @title.xpath('a').first
        @title = parent.content.strip
        @parent_url = parent['href']
      else
        @title = @title.first.content.strip  
      end
      
      if @production_info = doc.xpath(PRODUCTION_INFO_XPATH).first
	@production_info = @production_info.content.strip
	@description = doc.xpath(DESCRIPTION_XPATH[0]).first.content.strip
      else
	@description = doc.xpath(DESCRIPTION_XPATH[1]).first.content.strip
      end

      @persons = []

      @role = nil
      doc.xpath(PERSONS_XPATH).each do |element|
        if element.name == "div"
          @role = Person.type_by_string(element.content.strip)
        elsif element.name == "li"
	  @name = element.content.strip

	  if foreign_name = element.xpath('i').first
	    @foreign_name = foreign_name.content.strip.gsub(/[()]/,'')
	    @name.gsub!(@foreign_name,'').gsub!(/[()]/,'')
	  end

          @persons << Person.new(nil, {:name => @name, :foreign_name => @foreign_name, :role => @role})
        end               
      end  
      
      self
    end

    def self.get_type_by_string(string)
      case string
      when "Сериал"
	SERIAL
      when "Фильм", "Художественный фильм (многосерийный)", "Художественный фильм"
	FILM
      when "Инфо ( Новости )", "Инфо ( Происшествия )"
	INFO
      when "Передача ( А также )", "Передача ( Публицистика )"
	OTHER
      when "Передача ( Дети )", "Мультсериал", "Мультсериал (многосерийный)"
	KIDS
      when "Документальный фильм", "Документальный фильм (многосерийный)", "Документальный сериал"
	DOCUMENTAL
      when "Досуг ( Шоу )", "Досуг ( Музыка )"
	FUN
      else
	raise ArgumentError, "Не могу определить тип програмы '#{string}'"
      end
    end
  end 
end
