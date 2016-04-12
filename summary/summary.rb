#!/usr/bin/ruby
#Auth: bell@greedlab.com

require 'open-uri'
require 'getoptlong'

opts = GetoptLong.new(
    ['--title', '-t', GetoptLong::OPTIONAL_ARGUMENT],
    ['--directory', '-d', GetoptLong::OPTIONAL_ARGUMENT],
    ['--output', '-o', GetoptLong::OPTIONAL_ARGUMENT],
    ['--ignore', '-i', GetoptLong::OPTIONAL_ARGUMENT],
    ['--suffix', '-s', GetoptLong::OPTIONAL_ARGUMENT],
    ['--style', '-S', GetoptLong::OPTIONAL_ARGUMENT],
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--version', '-v', GetoptLong::NO_ARGUMENT]
)

$title = 'SUMMARY'
$output = './SUMMARY.md'
$directory = './'
$ignore = ['resource', 'Resource']
$suffix = ['.md', '.markdown']
$style = 'github'

$readme = "readme"

opts.each do |opt, arg|
  case opt
    when '--title'
      if arg == ''
        $title = 'My Blog'
      else
        $title = arg
      end
    when '--directory'
      $directory = arg
    when '--output'
      $output = arg
    when '--ignore'
      $ignore = arg
    when '--suffix'
      $suffix = arg
    when '--style'
      $style = arg
    when '--help'
      puts <<-EOF
summary.rb [OPTION]

-t, --title [string]:
   title ,default 'SUMMARY'

-d, --directory [directory path]:
   target directory path ,default './'

-o, --output [file path]:
   output file path ,default './SUMMARY.md'

-i, --ignore [array]:
   ignore string array ,default '['resource', 'Resource']'

-s, --suffix [array]:
   suffix string array ,default '['.md', '.markdown']'

-S, --style [string]:
   output style ,could be 'github' or 'gitbook', default 'github'

-h, --help:
   show help

-v, --version:
   show version
      EOF
      exit 0
    when '--version'
      puts <<-EOF
summary.rb 0.0.1
      EOF
      exit 0
  end
end

def get_readme(directory)
  # puts("debug" + directory)
  Dir.foreach(directory) do |file|
    $suffix.each do |suffix|
      readme = $readme + suffix
      # puts("debug" + readme + " " + file.downcase)
      if file.downcase.== readme
        return file
      end
    end
  end
end

def get_title(source_file)
  # puts source_file
  File.open(source_file, "r") do |file|
    line = file.gets
    while line && line == "\n"
      line = file.gets
    end
    if !line
      return nil
    end

    line = line.strip
    if line[0, 1] == "#"
      line = line[1, line.length - 1]
    end
    # puts line.strip
    return line.strip
  end
end

def summary_one_directory(summary, base, directory, ignore, deep)
  # puts directory
  if !File.directory?(directory)
    return
  end

  Dir.foreach(directory) do |file|
    # puts file
    if file.index(".") == 0
      next
    end

    fullPath = directory + "/" + file
    # puts fullPath
    if File.directory?(fullPath) # directory
      if ignore.include?(file)
        next
      end

      if $style == "gitbook"
        readme = get_readme(fullPath)
        if readme
          # puts("debug" + readme)
          string = " " * deep + "* [" + file + "](" + readme + ")"
        else
          string = " " * deep + "* " + file
        end
      else
        string = " " * deep + "* [" + file + "](" + fullPath + ")"
      end

      summary.syswrite(string + "\n")
      # puts string
      summary_one_directory(summary, base, fullPath, ignore, deep + 1)
    else # file
      if deep == 0 && file == "SUMMARY.md"
        next
      end
      $suffix.each do |suffix|
        length = suffix.length
        if file[-length, length] != suffix
          next
        end
        # puts "debug" + file
        name = file[0, file.length - length]
        if name.downcase == $readme
          next
        end
        if ignore.include?(name)
          next
        end

        title = get_title(fullPath)
        if !title || title.length == 0
          title = name
        end

        # puts fullPath
        # puts title

        baseLength = base.length
        if base[baseLength - 1, 1] != "/"
          baseLength += 1
        end
        relativePath = fullPath[baseLength, fullPath.length - baseLength]

        string = " " * deep + "* [" + title + "](" + URI::encode(relativePath) + ")"
        # puts string
        summary.syswrite(string + "\n")
      end

    end
  end
end

summary_file=File.new(File.join($output), "w+")
if !summary_file
  puts "Unable to whrite summary_file!"
  exit
end

unless File.directory? $directory
  puts "Unable to open target_directory!"
  exit
end

summary_file.syswrite("#" + $title + "\n")

summary_one_directory(summary_file, $directory, $directory, $ignore, 0)

puts $output