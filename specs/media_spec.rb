$lib_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift $lib_path

require "vida_parser"

module MediaHelper
  @media_list = {
    :serial_1 => VidaParser::Media.new("http://vida.ru/tvgrid/gate.asp?id=20969690"), # Нет информации о производстве

    :film_1 => VidaParser::Media.new("http://www.vida.ru/tvgrid/gate.asp?id=20969699") # Все есть
  }

  def self.get(code)
    @media_list[code]
  end
end

Spec::Runner.configure do |config|
  config.extend(MediaHelper)
end

describe VidaParser::Media do
  context "Проверка ссылки на родителя" do
    it "Сериал, с ссылкой на родителя" do
      @media = MediaHelper.get :serial_1
      
      @media.media_type.should == "Сериал"

      @media.parent_url.should_not be_nil
      @media.parent_url.should match("http:\/\/.*")
    end
    
    # Фильм у которого нет родителя
    it "Фильм без ссылки на родителя" do
      @media = MediaHelper.get :film_1
      
      @media.media_type.should == "Художественный фильм (многосерийный)"

      @media.parent_url.should be_nil
    end
  end

  context "Получение производителя и года" do
    it "Программа с заполненой информацией" do
      @media = MediaHelper.get :film_1

      @media.production_year.should == 1982

      @media.creator.should == 'Киностудия им. А.Довженко. СССР.'
    end

    it "Программа без информации" do
      @media = MediaHelper.get :serial_1

      @media.production_year.should == 2008

      @media.creator.should == ""
    end
  end 

  context "Описание программы" do
    it "Обычный фильм" do
      @media = MediaHelper.get :film_1
    
      @media.description.should == (<<-TEXT
      Вор-рецидивист Алексей Дедушкин по кличке Батон пойман с чужим чемоданом, в котором находился редкий и ценный орден Андрея Первозванного. Как выяснилось позднее, орден принадлежал когда-то барону фон Дицу. Тем не менее, владелец не заявлял о пропаже в милицию, на что наверняка были свои причины. Следователь Станислав Тихонов вынужден отпустить Батона. Но следствие на этом не заканчивается...
      TEXT
      ).strip
    end
  end

  context "Проверка заполнения ролей в фильме" do
    it "Заполнение актеров и режисеров в фильме" do
      @media = MediaHelper.get(:film_1)

      throw @media.persons
    end
  end
end
