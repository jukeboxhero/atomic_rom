#! /usr/bin/env ruby
 
require 'crack'
require 'net/http'


Dir["./lib/*.rb"].each {|file| require file }

result = Net::HTTP.get(URI.parse('http://thegamesdb.net/api/GetPlatformsList.php'))
output = Crack::XML.parse(result)['Data']['Platforms']["Platform"]

output.each do |platform|
	p_alias = platform['alias']
	platform_path = "./roms/#{p_alias}"
	next if p_alias.nil?
	next unless Dir.exists? platform_path
	class_name = p_alias.gsub("-", "_").split('_').map{|e| e.capitalize}.join
	platform['path'] = platform_path

	begin
		klass = Class.new(AbstractPlatform) do
			def initialize(platform)
				@id = platform['id'].to_i
				@alias = platform['alias']
				@local_path = platform['path']
				super
			end

			subklass = Class.new(AbstractGame) do
				def initialize(data)
					super
				end
			end

			gameslist = Class.new(GamesList)

			self.const_set 'Game', subklass
			self.const_set 'LocalGamesList', gameslist
		end

		Object.const_set class_name, klass
		local_games = klass.new(platform).local_game_data
		local_games.process_games!

	rescue NameError => e
		p e
	end
end