class AbstractPlatform
	attr_reader :id, :name, :alias, :controller, :overview, :developer, 
				:manufacturer, :cpu, :memory, :sound, :display, :media, 
				:maxcontrollers, :local_path, :games, :local_games


	def initialize(platform)
		p "Getting system information..."
		response = Net::HTTP.get(URI.parse("http://thegamesdb.net/api/GetPlatform.php?id=#{self.id}"))
		output = Crack::XML.parse(response)['Data']["Platform"]
		output.delete("id")
		output.each do |k,v|
			instance_variable_set("@#{k}", v)
		end
		@name = output.delete("Platform")
		@local_games = self.class.const_get("LocalGamesList").new
	end

	def populate_games!
		p "Populating games for #{self.name}"
		response = Net::HTTP.get(URI.parse("http://thegamesdb.net/api/GetPlatformGames.php?platform=#{self.id}"))
		output = Crack::XML.parse(response)['Data']['Game']

		@games ||= output.map do |game|
			self.class.const_get("Game").new(game)
		end
	end

	def local_game_data
		return @local_games unless @local_games.empty?
		self.populate_games!

		Dir["#{self.local_path}/*"].each do |file|
			game_name = File.basename(file, ".*")
			#response = Net::HTTP.get(URI.parse("http://thegamesdb.net/api/GetGame.php?name=#{'super-mario-world'}&platform=#{URI::encode(self.name)}"))
			tags = game_name.scan(/\(([^\)]+)\)/)
			game_alias = game_name.gsub(/\(([^\)]+)\)/, '').strip.downcase
			game_obj = @games.select{|x| x.name.downcase == game_alias}.first
			output = nil
			if game_obj
				response = Net::HTTP.get(URI.parse("http://thegamesdb.net/api/GetGame.php?id=#{game_obj.id}"))
				output = Crack::XML.parse(response)['Data']['Game']
			else
				response = Net::HTTP.get(URI.parse("http://thegamesdb.net/api/GetGame.php?id=#{game_obj.name.downcase}"))
				output = Crack::XML.parse(response)['Data']['Game'].first
			end
			
			output.merge!(:local_path => file)
			@local_games << self.class.const_get("Game").new(output)
		end

		@local_games
	end
end