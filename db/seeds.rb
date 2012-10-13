# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'nokogiri'
require 'open-uri'

# CLUES #
clues=nil
File.open("#{Rails.root}/db/fixtures/clues.xml",'r') do |f|
  clues = Nokogiri::XML(f)
end
count= 0
clues.xpath('//RECORD').each do |clue|
  clue_attributes= {}
  clue.elements.each do |element|
    clue_attributes[(element.name).to_sym]=element.text unless ["created_at","updated_at"].include?(element.name)
  end #clues.elements.each
  record= Clue.find_or_initialize_by_key(clue_attributes, without_protection: true)
  if record.new_record?
    count+=1
    record.save!
  end #if @record.new_record?
end #statuses.xpath('//RECORD').each
puts "* Created #{count} new clues out of #{Clue.count}"
