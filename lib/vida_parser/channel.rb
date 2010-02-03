require "#{File.dirname(__FILE__)}/utils"
require "#{File.dirname(__FILE__)}/media"

module VidaParser
  class Shedule
    attr_accessor :start_time, :end_time, :media, :media_url

    def initialize(media, start_time = nil, end_time = nil)
      @media = media
      @start_time = start_time
      @end_time = end_time      
    end
  end


  class Channel
    attr_reader :title  

    SHEDULE_ROW_XPATH = "//center/table[3]/tr[1]/td[2]/table/tr[2]/td/table/tr/td[@class='plain']/table[3]//tr"

    def initialize(title)
      @title = title
    end
    
    # Days from # Fri, 31 Dec 1999
    def days_from_millenium(date)
      (Time.parse(date.to_s).to_i-946587600)/(60*60*24)
    end

    def shedule_on(date)
      a = WWW::Mechanize.new { |agent|
	agent.user_agent_alias = 'Mac Safari'
      }
      
      shedule_html = nil

      a.get('http://www.vida.ru/tvgrid/base.asp?pType=2') do |page|	
	options    = page.form_with(:action => "http://www.vida.ru/tvgrid/base.asp").fields[1].options
	channel_id = options.select{|o| o.text.downcase == @title.downcase}.first.value

	search_result = page.form_with(:action => "http://www.vida.ru/tvgrid/base.asp") do |f|
	  f.vfsChannels = channel_id
	  f.vfsDate = days_from_millenium(date)
	end.submit
	
	shedule_html = search_result.body
      end

      doc = Nokogiri::HTML(shedule_html)

      previous_media = nil
	  
      @shedule = []
      
      rows = doc.xpath(SHEDULE_ROW_XPATH)
      rows.each do |row|	    
	next if row == rows.last
	next if row.content.empty?

	time    = row.xpath('td[1]').first.content.strip
	hour    = time.split(':')[0].to_i
	minutes = time.split(':')[1].to_i
	start_time = DateTime.new(date.year, date.month, date.day, hour, minutes)
	
	title = row.xpath('td[3]').first.content.strip

	if media_url = row.xpath('td[3]/a').first
	  media_url = "http://www.vida.ru/tvgrid/#{media_url['href']}"
	end
	
	if !@shedule.empty?
	  @shedule.last.end_time = start_time
	end
		
	@media = Media.new(media_url, {:title => title}).parse

	@shedule << Shedule.new(@media, start_time)
      end

      @shedule
   end
  end
end
