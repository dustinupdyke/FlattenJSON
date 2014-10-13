#!/usr/bin/ruby
require 'rubygems'
require 'json'

module Enumerable
  def object_split_character 
    return '_'
  end
  
  def flatten_with_path(parent_prefix = nil)
    res = {}

    self.each_with_index do |elem, i|
      if elem.is_a?(Array)
        k, v = elem
      else
        k, v = i, elem
      end
      
      key = parent_prefix ? "#{parent_prefix}#{object_split_character}#{k}" : k # assign key name for result hash

      if v.is_a? Enumerable
        res.merge!(v.flatten_with_path(key)) # recursive call to flatten child elements
      else
        res[key] = v
      end
    end

    res
  end
end

files = Dir["in/*json"]

i = 0

files.each do |file|

  json = File.read(file)
  obj = JSON.parse(json)

  s = ''
  if obj.to_s.strip.to_s[0,1] != '['
    s = obj.flatten_with_path.inspect.to_s
  else
    raw = []
    obj.each_with_index do |o|
      raw << o.flatten_with_path.inspect.to_s
    end
    s = raw.join(",\n")
  end
  s = '[' + s + ']'
  
  #s = obj.flatten_with_path.inspect.to_s
  s = s.gsub! '=>', ':'
  s = s.gsub! '",', "\",\n"

  j = JSON.parse(s)
  js = JSON.pretty_generate(j)

  fi = File.basename(file,File.extname(file)) + '.json'
  File.write("out/" + fi, js.to_s)

  puts "#{fi} flattened"
  i = i + 1

end

puts "--------"
puts "#{i} file(s) written"
