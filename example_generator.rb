require 'ripper2ruby'



def find_calls(out, name)
  out.select(Ruby::Call).select{|x| x.identifier.to_s == name }
end

src = File.read(ARGV[0])
 output = Ripper::RubyBuilder.build(src)


 describe_block =  find_calls(output,"describe").first
 
 puts "=== #{describe_block.nodes[1].value.to_s}"
 find_calls(output,"it").each_with_index do |c,i|
   puts "* #{c.nodes[1].value}"
   puts "        #{c.block.src.sub("do","")} "
 end
