require_relative '../config/environment.rb'

class MTAStatus

  attr_accessor :doc

  SUBWAY = ["subway", "irt", "ind", "bmt", "tube", "train", "underground"]
  LIRR = ["lirr", "long", "island", "rail", "road"]
  METRO_NORTH = ["metro-north", "metro", "north"]

  def initialize(service)
    if service!=nil
      @service = service.downcase
    else
      @service = "subway"
    end   
    @doc  = Nokogiri::HTML(open(MTA))
    run
  end

  def name
    @doc.xpath("//name").collect do |name|
      name.children.text
    end
  end

  def status
    @doc.xpath("//status").collect do |s|
      s.children.text
    end
  end

  def note
    @doc.xpath("//text").collect do |note|
      note.children.text
    end
  end

  def output
    name.zip(status)
  end

  def subway
    output[0..10]
  end

  def lirr
    output[30..40]
  end

  def metro_north
    output[41..50]
  end

  def service_choice
    call = []
    if SUBWAY.include?(@service)
      call.concat(subway)
    elsif LIRR.include?(@service)
      call.concat(lirr)
    elsif METRO_NORTH.include?(@service)
      call.concat(metro_north)
    end
  end

  def run
    puts
    puts "############### Status ###############"
    service_choice.each do |line_pair|
      if line_pair[1]!="GOOD SERVICE"
        puts "#{line_pair[0].bold}: #{line_pair[1].red}"
      else
        puts "#{line_pair[0]}: #{line_pair[1].green}"
      end
    end
    puts "######################################"
  end

end
