# encoding utf-8

require "rubygems"
require "open-uri"
require "nokogiri"
require "slim"
require "ruby-progressbar"

BASEURL = "http://www.lostfilm.tv"
uris = Array.new
titles = Array.new
description = Array.new
genres = Array.new
images = Array.new

progressbar = ProgressBar.create :total => Nokogiri::HTML(open(BASEURL + "/serials.php")).xpath("//*[@id='Onwrapper']/div[4]/div[1]/div[2]/a").count

Nokogiri::HTML(open(BASEURL + "/serials.php")).xpath("//*[@id='Onwrapper']/div[4]/div[1]/div[2]/a").map do |a|
  progressbar.increment
  uris.push BASEURL + a["href"]
  doc = Nokogiri::HTML(open(BASEURL + a["href"]))
  doc.xpath("//*[@id='Onwrapper']/div[4]/div[1]/div[1]/h1").map do |t|
    titles.push t.content
  end
  doc.xpath("//*[@id='Onwrapper']/div[4]/div[1]/div[1]/span[4]").map do |d|
    description.push d.content
  end
  doc.xpath("//*[@id='Onwrapper']/div[4]/div[1]/div[1]/span[2]").map do |g|
    genres.push g.content
  end
  doc.xpath("//*[@id='Onwrapper']/div[4]/div[1]/div[1]/img").map do |i|
    images.push BASEURL + i["src"]
  end
end

items = uris.zip(titles, description ,genres, images)

File.open("lostfilm.html", "w") do |result|
  result.write Slim::Template.new("lostfilm.slim").render(nil, :items => items)
end
