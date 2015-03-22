class AbstractGame
	attr_reader :id, :name
	def initialize(data)
		@id = data.delete("id").to_i
		@name = data.delete('GameTitle')


		data.each do |k,v|
			instance_variable_set("@#{k}", v)
		end
	end
end