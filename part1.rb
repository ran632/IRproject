require 'nokogiri'
require 'open-uri'
require 'pry'
require 'csv'
require 'fileutils'


puts "hello"
puts "how many movies would like to crawl? please type a number"
@user_num_crawl = gets.chomp.to_i
go_crawl

BEGIN {
@website_url = "http://www.torec.net"
def go_crawl
  page_from = 1
  page_to = 710
  crawled = 0
  max_crawled = @user_num_crawl || 5000
  main_url = "#{@website_url}/movies_subs.asp?p="
  puts "STARTS CRAWLING, it can take a while......"
  FileUtils.mkdir_p 'movies'
  CSV.open("data.csv", "wb") do |csv|
    csv << ["‫‪serialNum‬‬","url‬‬","name‬‬","year‬‬","producer‬‬","actors‬‬","genres‬‬"]
    (page_from..page_to).each do |n|

      url = "#{main_url}#{n}"
      if crawled >= max_crawled
        puts "@@@@@@@ FINISHED crawled #{crawled} @@@@@"
        puts "there is now metadata file 'data.csv' and movies directory with all movies description files"
        break
      else
        puts "$$$$$$$$$$$$$ already crawled #{crawled} $$$$$$$$$$$$$$$$$$$"
      end

      #begin
      links = crawl_movies_page_for_links(url)
      links.each do |link|
        # begin
          crawl_doc(@website_url+link, csv)
          crawled += 1
        # rescue
        #   puts "Error in #{link}"
        # end
      end
      # rescue
      #   puts "ERROR! #{$!}"
      #   next
      # end

    end
  end
end

def crawl_movies_page_for_links(url)
  links = []
  movies_page = Nokogiri::HTML(open(url, read_timeout: 5))
  link_elements = movies_page.css("a[href^='/sub.asp?sub_id=']")
  link_elements.each do |le|
    links << le.attributes["href"].value
  end
  links
end

def crawl_doc(url, csv)
  serialNum = url.tr("^0-9", '')
  puts "crawling doc ##{serialNum}"
  doc = Nokogiri::HTML(open(url, read_timeout: 5))
  data = {}
  data_html_element = doc.css(".sub_name_span")
  data[:serialNum] = serialNum
  data[:url] = url
  data[:name] = doc.css(".sub_title").text
  data[:year] = begin data_html_element.first.children[2].text rescue "" end
  data[:producer] = begin data_html_element.first.children[12].text rescue "" end
  actors = []
  doc.css(".sub_name_span a").each do |actor|
    actors << actor.text
  end
  data[:actors] = actors.join(", ")
  data[:genre] = begin data_html_element.first.children[9].text rescue "" end
  description = doc.css(".sub_name_div").text
  csv << data.values
  File.write("movies/#{serialNum}.txt", description)
end
}
