#!/usr/bin/ruby -w

require 'json'

if ARGV.size != 3
  puts "USAGE: projectConfig.rb <project.pbxproj> <ORGANIZATIONNAME> <CLASSPREFIX>"
  return
end

def deep_find_obj_with_key_value(data, desired_key, desired_value, hits = [])
  result = 0
  case data
  when Array
    # data.each do |value|
    #   deep_find_value_with_key value, desired_key, hits
    # end
  when Hash
    if (data.key?(desired_key)) && (data[desired_key] == desired_value)
      return 1
    else
      data.each do |key, val|
        result = deep_find_obj_with_key_value(val, desired_key,desired_value, hits)
        if result > 0
          # puts  "< " + key
          hits << key
          return result
        end
      end
    end
  end
  return result
end

`plutil -convert json -r -o project.json -- "#{ARGV[0]}"`

json = File.read("project.json")
File.delete("project.json")
hash = JSON.parse(json)

hits=[]
deep_find_obj_with_key_value(hash,"isa","PBXProject",hits)

size = hits.size
if size != 2
  puts "can not find PBXProject"
  return
end

hash [hits[1]][hits[0]]["attributes"]["ORGANIZATIONNAME"]=ARGV[1]
hash [hits[1]][hits[0]]["attributes"]["CLASSPREFIX"]=ARGV[2]

# puts hash
aFile = File.new("project-modified.json", "w")
if ! aFile
return 0
end

aFile.write(hash.to_json)
aFile.close

`plutil -convert xml1 -o project-modified.xml -- project-modified.json`
File.delete("project-modified.json")

`mv project-modified.xml "#{ARGV[0]}"`
