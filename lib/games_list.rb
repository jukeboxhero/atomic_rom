require 'zip'

class GamesList < Array

	def process_games!
		each do |game|
			ext = File.extname(game.local_path)
			dir = File.dirname(game.local_path)

			if ext == '.zip'
				Zip::File.open(game.local_path) do |zipfile|
				  zipfile.each do |file|
				    puts "Extracting #{file.name}"
    				file.extract("#{dir}/#{game.name}#{File.extname(file.name)}")
				  end
				end
				FileUtils.rm(game.local_path)
			else
				File.rename(game.local_path, "#{dir}/#{game.name}#{ext}")
			end
		end
	end

end