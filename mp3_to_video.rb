MP3_DIR="~/Music/GarageBand"
WILDCARD="DoYouHear*.mp3"
TITLE='"Do You Hear What I Hear" a la Harry Simeone choir'

puts File.join(MP3_DIR, WILDCARD)

require 'RMagick'

# basename without extension
def squished_filename(filepath)
  File.basename(filepath).gsub(/\..*$/,'').gsub(' ','')
end

def title_text(filename)
  sub_description = filename.split('-')[1]
  expanded_sub_description = case sub_description
                             when /And/
                               sub_description.gsub(/(.*)And(.*)/,'\1 with \2 accompaniment')
                             when /Over/
                               sub_description.gsub(/(.*)Over(.*)/,'\1 primary with \2 voice and accompaniment')

                             end
  "#{TITLE}\n#{expanded_sub_description}"
end

def create_title_card(file)
  filename=squished_filename(file)

  canvas = Magick::Image.new(1920, 1080){self.background_color = 'black'}

  text = Magick::Draw.new
  text.pointsize = 50
  text.fill = 'white'
  text.gravity = Magick::CenterGravity
  text.annotate(canvas, 0, 0, 0, 0, title_text(filename))

  canvas.write("#{filename}.png")

  File.open("#{filename}.txt", "wt") do |f|
    f.puts(title_text(filename))
  end
end

Dir[File.expand_path(File.join(MP3_DIR, WILDCARD))].each do |file|
  create_title_card(file)
  # https://superuser.com/a/1041818/78459
  `ffmpeg -loop 1 -i #{squished_filename(file)}.png -i "#{file}" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest #{squished_filename(file)}.mp4`

end

