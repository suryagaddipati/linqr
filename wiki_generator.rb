require 'ripper2ruby'



def find_calls(out, name)
  out.select(Ruby::Call).select{|x| x.identifier.to_s == name }
end

def camelize(str)
  str.split('_').map {|w| w.capitalize}.join
end

def out_file_name(file)
"linqr.wiki/" +  camelize(file.split('/').last.gsub('_spec.rb','')) + ".rdoc"
end

def write_wiki(file)

  src = File.read(file)
  puts file
  output = Ripper::RubyBuilder.build(src)
  describe_block =  find_calls(output,"describe").first
  File.open(out_file_name(file), "w") do |file| 
    file.puts "=== #{describe_block.nodes[1].value.to_s}"
    find_calls(output,"it").each_with_index do |c,i|
      file.puts "* #{c.nodes[1].value}"
      file.puts "        #{c.block.src.sub("do","")} "
    end
  end

end


Dir.glob("examples/*/**").each {|f| write_wiki(f)}
