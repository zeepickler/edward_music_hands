require 'yaml'
require 'fileutils'
class EdwardMusicHands
	# given root_dir
	# creates wav file in output_dir
	# returns outputs output_dir/filename.wav
	def initialize(track_title,song_length)
		@config = YAML::load_file "./config/settings.yml"
		@config[:song_segment_length] = @config[:song_segment_length].to_i
		get_seconds(song_length)
		set_song_parameters
		create_file_library
		select_sample_songs
		create_sample_library
		compose_music(@config[:output_dir],track_title)
		remove_temp_files
		puts "#{@config[:file_name]} created!"
	end

	private
	def get_seconds(song_length)
		min, sec = song_length.split(":")
		@config[:seconds] = min.to_i * 60 + sec.to_i
	end
	def set_song_parameters
		@config[:number_of_samples_in_song] = @config[:seconds] / @config[:song_segment_length]
		@config[:songs_to_sample] = @config[:seconds] / 30
	end
	def create_file_library
		@config[:file_library] = Dir.glob( File.join(@config[:music_root_dir],"**/*") )
																.select{|f| File.file?(f) && @config[:input_file_types].include?( f.split(".").last.downcase ) }
	end

	def select_sample_songs
		if @config[:songs_to_sample].to_i > @config[:file_library].size
			puts "ERROR: songs_to_sample must be less than #{@config[:file_library].size}."
			exit 0
		else
			@config[:sample_songs] = @config[:file_library].shuffle.first(@config[:songs_to_sample])
		end
	end

	# cut in_file.wav into 30 sec segments -- out_file00n.wav
	# sox in_file.wav out_file.wav trim 0 30 : newfile : restart


	def create_sample_library
		@config[:sample_library] = []
		Dir.mkdir(@config[:temp_dir]) unless Dir.exist?(@config[:temp_dir])
		@folder_num = 1
		@config[:sample_songs].each do |in_file|
			sample_dir = File.join(@config[:temp_dir], "sample_" + @folder_num.to_s )
			Dir.mkdir(sample_dir)
			file_name = "sample_" + @folder_num.to_s + ".mp3"
			file_path = File.join(sample_dir,file_name)
			`sox "#{in_file}" "#{file_path}" trim 0 #{@config[:song_segment_length].to_i} : newfile : restart`
			@config[:sample_library] << Dir.glob( File.join(sample_dir,"*") )
			@folder_num += 1
		end
		@config[:sample_library].flatten!
	end

	def compose_music(output_dir,track_title)
		track_file = track_title.gsub(" ","_") + ".wav"
		Dir.mkdir output_dir unless Dir.exist? output_dir
		file_path = File.join(output_dir,track_file)
		`sox #{@config[:sample_library].shuffle.first(@config[:number_of_samples_in_song].to_i).join(" ")} #{file_path}`
		@config[:file_name] = file_path
	end

	def remove_temp_files
		if Dir.exist?(@config[:temp_dir])
			FileUtils.rm_r(@config[:temp_dir])
		end
	end
end

title = ARGV[0]
song_length = ARGV[1]
EdwardMusicHands.new(title,song_length)



