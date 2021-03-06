require_relative '../config/environment.rb'

class MTAStatus

  attr_accessor :doc

  LIRR = ["lirr", "long", "island", "rail", "road"]
  METRO_NORTH = ["metro-north", "metro", "north", "metronorth"]

  def initialize(service)
    @service = service.downcase if service
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
    if LIRR.include?(@service)
      lirr
    elsif METRO_NORTH.include?(@service)
      metro_north
    else
      subway
    end
  end

  def run
    puts
    puts "##### Train Status ######"
    puts Time.now
    puts "#########################"
    service_choice.each do |line_pair|
      if line_pair[1]!="GOOD SERVICE"
        puts "#{line_pair[0].bold}: #{line_pair[1].red}"
      else
        puts "#{line_pair[0]}: #{line_pair[1].green}"
      end
    end
    puts "#########################"
  end

end

