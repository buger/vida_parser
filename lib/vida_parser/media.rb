require "#{File.dirname(__FILE__)}/person"

module VidaParser
  class Media
    attr_reader :url,
                :media_type, 
                :parent_url,
                :title, :foreign_title, 
                :description, 
                :created, 
                :always_record,
                :production_year,
                :creator,
                :data, 
                :persons

    MEDIA_TYPE_XPATH = "//center/table[3]/tr/td[1]/table/tr[1]/td[@class='OkHead1']/font"
    TITLE_XPATH = "//center/table[3]/tr/td[1]/table/tr[2]/td/table/tr/td[@class='plain']/table[2]/tr[2]/td/div[1][@class='OkHead1']"

    PRODUCTION_INFO_XPATH = "//center/table[3]/tr/td[1]/table/tr[2]/td/table/tr/td[@class='plain']/table[2]/tr[4]/td[@class='OkTah11']"
    PRODUCTION_INFO_REGEXP = /Производство:(.*)(\d{4})\./
    
    DESCRIPTION_XPATH = "//center/table[3]/tr/td[1]/table/tr[2]/td/table/tr/td[@class='plain']/table[2]/tr[6]/td[@class='OkVrdTD']/p[@class='OkAlign']"

    PERSONS_XPATH = "//center/table[3]/tr/td[2]/table/tr[2]/td/table/tr/td[@class='plain']/table/tr/td/*"


    def initialize(url, options = {})
      @url = url

      @persons = []

      doc = Nokogiri::HTML(open(url))

      @media_type = doc.xpath(MEDIA_TYPE_XPATH).first.content.strip

      @title = doc.xpath(TITLE_XPATH)
      if parent = @title.xpath('a').first
        @title = parent.content.strip
        @parent_url = parent['href']
      else
        @title = @title.first.content.strip  
      end

      doc.xpath(PRODUCTION_INFO_XPATH).first.content.strip.match(PRODUCTION_INFO_REGEXP) 
      @creator = $1.strip
      @production_year = $2.to_i

      @description = doc.xpath(DESCRIPTION_XPATH).first.content.strip
      

      @role = nil
      doc.xpath(PERSONS_XPATH).each do |element|
        if element.name == "div"
          @role = element.content.strip
        elsif element.name == "li"
          @persons << Person.new(nil, {:name => element.content.strip, :role => @role})
        end               
      end  
    end
  end 
end
