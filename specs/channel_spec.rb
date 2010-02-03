$lib_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift $lib_path

require "vida_parser"

module ChannelHelper
  @channels = {
    :channel_1 => VidaParser::Channel.new("Первый"),
    :channel_2 => VidaParser::Channel.new("Россия 1"),
    :channel_3 => VidaParser::Channel.new("MTV"),
    :channel_4 => VidaParser::Channel.new("2х2") 
  }

  def self.get(code)
    @channels[code]
  end
end

describe VidaParser::Channel do 
  it "Получить расписание на текущий день" do
    shedule = ChannelHelper.get(:channel_4).shedule_on(Date.today)

    shedule.each do |item|
      puts "#{item.start_time.to_s}-#{item.end_time.to_s} #{item.media.title}\n"
    end
  end
end
