#!/usr/bin/env ruby
# Generate HTML TOC for the OWASP MSTG

require "redcarpet"
require "htmlentities"

class DocumentRender < Redcarpet::Render::HTML_TOC

  def header(title, level)

    title = HTMLEntities.new.encode(title) # Securitay!
    anchor = title.downcase.gsub(' ','-').gsub(/[^0-9a-z\-]/i, '')

    case level
    when 1
      "<a href=\"https://github.com/OWASP/owasp-mstg/blob/master/Document/#{$curfile}\##{anchor}\"><h1>#{title}</h1></a>\n"
    when 2
      "<a href=\"https://github.com/OWASP/owasp-mstg/blob/master/Document/#{$curfile}\##{anchor}\"><h2>#{title}</h2></a>\n"
    when 3
      "<p><a href=\"https://github.com/OWASP/owasp-mstg/blob/master/Document/#{$curfile}\##{anchor}\">#{title}</a>\</p>\n"
    end
  end
end

class TestcaseRender < Redcarpet::Render::HTML_TOC

  def header(title, level)

    title = HTMLEntities.new.encode(title) # Securitay!
    anchor = title.downcase.gsub(' ','-').gsub(/[^0-9a-z\-]/i, '')

    case level
    when 1
      "<a href=\"https://github.com/OWASP/owasp-mstg/blob/master/Document/Testcases/#{$curfile}\##{anchor}\"><h1>#{title}</h1></a>\n"
    when 2
      "<a href=\"https://github.com/OWASP/owasp-mstg/blob/master/Document/Testcases/#{$curfile}\##{anchor}\"><h2>#{title}</h2></a>\n"
    when 3
      "<p><a href=\"https://github.com/OWASP/owasp-mstg/blob/master/Document/Testcases/#{$curfile}\##{anchor}\">#{title}</a>\</p>\n"
    end
  end
end

def render_testcases()
  markdown = Redcarpet::Markdown.new(TestcaseRender, fenced_code_blocks: true)

  Dir.foreach('../Document/') do |fn|
    if fn =~ /\.md$/
      $curfile = fn    
      file = File.open("../Document//#{fn}")
                  contents = file.read
                  puts markdown.render(contents)
    end
  end

end

puts '''
<html>
<head>

<style>
@import url(http://fonts.googleapis.com/css?family=Montserrat:400,700);
@import url(http://fonts.googleapis.com/css?family=Lato:100,300,400,700,900,100italic,300italic,400italic,700italic,900italic);
body, html{
  -webkit-font-smoothing: antialiased !important;
  -moz-osx-font-smoothing: grayscale;
  overflow-y: auto;
  overflow-x: hidden;
  font-family: \'Montserrat\', sans-serif;
}
@media (min-width: 1200px){
  .container {
    width: 960px;
  }
}
h1{
  font-weight: 700;
  font-size: 30px;
}
h2{
  font-size: 25px;
}
h3{
  font-size: 20px;
  font-style: italic;
  font-weight: 100;
  line-height: 26px;
}
p{
  font-size: 20px;
  font-weight: 400;
}
</style>

</head>
<body>

    <div id="top">
  <img height=100px src="https://raw.githubusercontent.com/OWASP/owasp-masvs/master/Document/images/OWASP_logo.png"/>
    </div>

'''

markdown = Redcarpet::Markdown.new(DocumentRender, fenced_code_blocks: true)

Dir.foreach('../Document') do |fn|

  if fn =~ /0x07a/ # Render test cases after chapter 6
    render_testcases()
  end

  if fn =~ /\.md$/
    $curfile = fn
    file = File.open("../Document/#{fn}")
                contents = file.read
                puts markdown.render(contents)
  end
end



puts "</body>\n"
