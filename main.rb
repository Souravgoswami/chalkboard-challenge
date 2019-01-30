#!/usr/bin/ruby -w
require 'ruby2d'
require 'securerandom'
STDOUT.sync = true

module Ruby2D
	def total_x() @x + @width end
	def total_y() @y + @height end
	def change_colour=(colour)
		__opacity__, self.color = self.opacity, colour
		self.opacity = __opacity__
		colour
	end
	def div_x(other) @x + @width/2 - other.width/2 end
	def div_y(other) @y + @height/2 - other.height/2 end
	def contain?(object) contains?(object.x, object.y) end
end

@width, @height = 640, 480
@fps, @path = 50, "#{File.dirname(__FILE__)}/"

# Set font path
Font = @path + 'fonts/Cinzel-Regular.ttf'
Font_Size = 45

Assigned_Time = 45.0

# Paused screen
R = Rectangle.new width: @width, height: @height, z: 5, color: '#000000', opacity: 0.4
Image.new @path + 'images/anshu-a-1180959-unsplash.jpg', width: @width, height: @height, z: -100

set width: @width, height: @height, title: 'Chalkboard Challenge', resizable: true, fps_cap: @fps

def maths(level=5)
	gen = -> (range=1..20) { rand(range).to_s }
	gen_div = ->(min=2, max=30) { "#{min.step(max, min).to_a.sample}/#{min}" }

	case level
		when 1
			[rand(0..20), rand(0..20)].sample(2).map(&:to_s)

		when 2
			[ "#{rand(10..30)} #{['+', '-'].sample} #{rand(1..5)}", "#{rand(10..30)} #{['+', '-'].sample} #{rand(1..5)}", gen[], gen[] ].sample(2).map(&:to_s)

		when 3
			[ gen_div[], gen_div.call(3, 30), gen[], gen[],
				"#{rand(10..30)} #{['+', '-'].sample} #{rand(1..5)}", "#{rand(10..30)} #{['+', '-'].sample} #{gen.[](1..5)}" ].sample(2).map(&:to_s)

		when 4
			[ gen_div[], gen_div.call(3, 30), gen_div.call(4, 40), gen[], gen[], "#{rand(1..5)} * #{rand(1..5)}",
				"#{rand(10..30)} #{['+', '-'].sample} #{rand(1..5)}", "#{rand(10..30)} #{['+', '-'].sample} #{gen.[](1..5)}" ].sample(2).map(&:to_s)

		when 5
			[ "(#{gen_div.call(rand(1..6))} * #{rand(1...5)})* #{rand(1..5)}", "(#{rand(1..20)} #{['+', '-'].sample} #{rand(1...20)})* #{rand(1..5)}",
				"(#{rand(1..20)} #{['+', '-'].sample} #{rand(1...20)})* #{rand(1..5)}",
				gen_div[], gen_div.call(3, 30), gen_div.call(4, 40), gen_div.call(5, 50) ].sample(2).map(&:to_s)

		else
			["(#{gen_div.call(rand(1..6))} * #{rand(1...5)})* #{rand(1..5)}", "(#{gen_div.call(rand(1..6))} * #{rand(1...5)})* #{rand(1..5)}",
				"(#{rand(1..20)} #{['+', '-'].sample} #{rand(1...20)})* #{rand(1..5)}", "(#{rand(1..20)} #{['+', '-'].sample} #{rand(1...20)})* #{rand(1..5)}",
				gen_div[], gen_div.call(3, 30), gen_div.call(4, 40), gen_div.call(5, 50) ].sample(2).map(&:to_s)
	end
end

def main
	particles, particle_speed = [], []
	100.times do
		size = rand(6..10)
		particles << Image.new(@path + 'images/circle.png', width: size, height: size, x: rand(0..@width), y: rand(0..@height),
				color: "##{SecureRandom.hex(3)}", z: -5 )
		particle_speed << rand(1.0..6.0)
	end

	# Variables
	particles_size = particles.size
	assigned_time = Assigned_Time
	started = false
	score, streak = 0, 0
	i, counter, started_var, warn_range = 0.0, 0, 1, 1..9

	countdown = Text.new 'Game Begins in 3', font: Font, z: 5, opacity: 0

	equal_touched = false
	equal = Rectangle.new width: @width - 6, height: 80, x: 3
	equal.y = @height - equal.height - 2
	equal_label = Text.new 'Equal', font: Font, color: '#000000', size: Font_Size/2
	equal_label.x, equal_label.y = equal.div_x(equal_label), equal.div_y(equal_label)

	message_touched = false
	message = Image.new @path + 'images/message.png'
	message.y = @height/7 - message.height
	message.x = @width/2 - message.width/2

	anim_control = 2
	message_anim = Triangle.new(color: '#ffffff', x1: message.x + 50, x2: message.x + 35, x3: message.x + 65,
			y1: message.total_y + 15, y2: message.total_y, y3: message.total_y, opacity: 0.5)
	message_shadow = Image.new @path + 'images/message_shadow.png', z: -1
	message_shadow.x ,message_shadow.y = message.x - (message_shadow.width - message.width)/2, message.y - (message_shadow.width - message.width)/2

	card_pressed = false
	card_a_touched = false

	card_a = Image.new @path + 'images/card.png'
	card_a.x, card_a.y = @width/2 - card_a.width/2, @height/3 - card_a.height/2

	card_b_touched = false
	card_b = Image.new @path + 'images/card.png'
	card_b.x, card_b.y = @width/2 - card_b.width/2, card_a.total_y + 10

	card_a_shadow = Image.new @path + 'images/card_shadow.png', opacity: 0
	card_b_shadow = Image.new @path + 'images/card_shadow.png', opacity: 0
	card_a_glow = Image.new @path + 'images/card_glow.png', opacity: 1, z: 5
	card_b_glow = Image.new @path + 'images/card_glow.png', opacity: 1, z: 5

	card_a_glow_correct = Image.new @path + 'images/card_glow_orange.png', opacity: 0
	card_b_glow_correct = Image.new @path + 'images/card_glow_orange.png', opacity: 0

	card_a_shadow.x, card_a_shadow.y = card_a.x, card_a.y
	card_b_shadow.x, card_b_shadow.y = card_b.x, card_b.y

	card_a_glow.x, card_a_glow.y = card_a.x - (card_a_glow.width - card_a.width)/2, card_a.y - (card_a_glow.width - card_a.width)/2
	card_b_glow.x, card_b_glow.y = card_b.x - (card_b_glow.width - card_b.width)/2, card_b.y - (card_b_glow.width - card_b.width)/2

	card_a_glow_correct.x, card_a_glow_correct.y = card_a.x - (card_a_glow_correct.width - card_a.width)/2, card_a.y - (card_a_glow_correct.width - card_a.width)/2
	card_b_glow_correct.x, card_b_glow_correct.y = card_b.x - (card_b_glow_correct.width - card_b.width)/2, card_b.y - (card_b_glow_correct.width - card_b.width)/2

	math = maths(rand(1..6))

	card_a_text = Text.new math[0], font: Font, color: '#000000', size: Font_Size
	card_a_text.x, card_a_text.y = card_a.div_x(card_a_text), card_a.div_y(card_a_text)

	card_b_text = Text.new math[1], font: Font, color: '#000000', size: Font_Size
	card_b_text.x, card_b_text.y = card_b.div_x(card_b_text), card_b.div_y(card_b_text)

	final_results_a, final_results_b = [], []

	# Sounds
	correct_sound = Sound.new @path + 'sounds/131662__bertrof__game-sound-correct-v2.wav'
	wrong_sound = Sound.new @path + 'sounds/131657__bertrof__game-sound-wrong.wav'
	beep = Sound.new @path + 'sounds/beep.wav'
	warning_beep = Sound.new @path + 'sounds/154953__keykrusher__microwave-beep.wav'
	start = Sound.new @path + 'sounds/start_game.ogg'

	# Buttons
	pause_touched = false
	pause = Image.new @path + 'images/pause.png', z: 5

	play_touched = false
	play = Image.new @path + 'images/play_button_64x64.png', z: 5
	play.x, play.y = pause.total_x + 5, pause.total_y + 5

	restart_touched = false
	restart = Image.new @path + 'images/restart.png', z: 5
	restart.x, restart.y = @width - restart.width - play.x, play.y

	power_touched = false
	power = Image.new @path + 'images/power.png', z: 5
	power.x, power.y = play.x, equal.y - power.height - 5

	screenshot_touched = false
	screenshot = Image.new @path + 'images/screenshot.png', z: 5
	screenshot.x, screenshot.y = @width/2 - screenshot.width/2, power.y

	screenshot_message = Text.new '', font: Font, z: 5, size: 10

	about_touched = false
	about = Image.new @path + 'images/bulb.png', z: 5
	about.x, about.y = restart.x, power.y

	play_big_touched = false
	play_big = Image.new @path + 'images/play.png', z: 5
	play_big.x, play_big.y = @width/2 - play_big.width/2, @height/2 - play_big.height/2 - equal.height/2

	#  time, timebox, point, pointbox
	pointbox_touched = false
	pointbox = Rectangle.new width: @width/6, height: @width/25
	pointbox.x, pointbox.y = @width - pointbox.width - 2, 2

	final_point = Text.new '', font: Font, size: 25, z: 5, opacity: 0

	timebox_touched = false
	timebox = Rectangle.new width: pointbox.width, height: pointbox.height
	timebox.x, timebox.y = pointbox.x - pointbox.width - 2, pointbox.y

	time = Text.new "Time: #{assigned_time}", font: Font, color: '#0000ff', size: 15
	time.x, time.y = timebox.div_x(time), timebox.div_y(time)

	point = Text.new "Score: #{score}", font: Font, color: '#0000ff', size: 15
	point.x, point.y = pointbox.div_x(point), pointbox.div_y(point)

	# increase opacity
	incop = -> (objects, max=1, step=0.03) { objects.each { |object| object.opacity += step if object.opacity < max } }

	# decrease opacity
	decop = -> (objects, min=0.6, step=0.03) { objects.each { |object| object.opacity -= step if object.opacity > min } }

	correct_img = Image.new @path + 'images/correct.png', opacity: 0
	correct_img.width /= 3
	correct_img.height /= 3

	wrong_img = Image.new @path + 'images/wrong.png', opacity: 0
	wrong_img.width /= 3
	wrong_img.height /= 3

	change_question = -> {
		case score
			when 0...250 then math = maths(1)
			when 250...400 then math = maths(2)
			when 400...550 then math = maths(3)
			when 550...650 then math = maths(4)
			when 650...900 then math = maths(5)
			else math = maths(6)
		end

		card_a_text.text, card_b_text.text = math[0], math[1]
		card_a_text.x, card_a_text.y = card_a.div_x(card_a_text), card_a.div_y(card_a_text)
		card_b_text.x, card_b_text.y = card_b.div_x(card_b_text), card_b.div_y(card_b_text)
	}

	check = ->(bool, card) {
		if started
			if bool
				streak += 1
				assigned_time += 5 if score % 10 == 0 unless score == 0
				correct_sound.play

				if card.equal?(card_a)
					correct_img.x, correct_img.y, correct_img.opacity = card_a.div_x(correct_img), card_a.div_y(correct_img), 1
				elsif card.equal?(card_b)
					correct_img.x, correct_img.y, correct_img.opacity = card_b.div_x(correct_img), card_b.div_y(correct_img), 1
				else
					correct_img.x, correct_img.y, correct_img.opacity = equal.div_x(correct_img), equal.div_y(correct_img), 1
				end

				temp_a = Text.new(eval(math[0]), font: Font, size: Font_Size, color: '#ffffff', z: -1)
				temp_b = Text.new(eval(math[1]), font: Font, size: Font_Size, color: '#ffffff', z: -1)
			else
				streak = 0
				assigned_time -= 3
				wrong_sound.play

				if card.equal?(card_a)
					card_a.color = '#ffa500'
					wrong_img.x, wrong_img.y, wrong_img.opacity = card_a.div_x(wrong_img), card_a.div_y(wrong_img), 1
				elsif card.equal?(card_b)
					card_b.color = '#ffa500'
					wrong_img.x, wrong_img.y, wrong_img.opacity = card_b.div_x(wrong_img), card_b.div_y(wrong_img), 1
				else
					equal.color = '#ffa500'
					wrong_img.x, wrong_img.y, wrong_img.opacity = equal.div_x(wrong_img), equal.div_y(wrong_img), 1
				end

				temp_a = Text.new(eval(math[0]), font: Font, size: Font_Size, color: '#000000', z: -1)
				temp_b = Text.new(eval(math[1]), font: Font, size: Font_Size, color: '#000000', z: -1)
			end

			temp_a.x, temp_a.y, temp_a.opacity = card_a.div_x(temp_a), card_a.div_y(temp_a), 1
			temp_b.x, temp_b.y, temp_b.opacity = card_a.div_x(temp_b), card_b.div_y(temp_b), 1

			final_results_a.push(temp_a)
			final_results_b.push(temp_b)

			card_pressed = true
			score += streak

			change_question[]
		end
	}

	on :mouse_move do |e|
		equal_touched = equal.contain?(e)
		card_a_touched = card_a.contain?(e)
		card_b_touched = card_b.contain?(e)
		message_touched = message.contain?(e)

		pointbox_touched = pointbox.contain?(e)
		timebox_touched = timebox.contain?(e)

		pause_touched = pause.contain?(e)
		play_touched = play.contain?(e)
		play_big_touched = play_big.contain?(e)
		restart_touched = restart.contain?(e)
		power_touched = power.contain?(e)
		screenshot_touched = screenshot.contain?(e)
		about_touched = about.contain?(e)
	end

	on :mouse_up do |e|
		result1, result2 = eval(math[0]), eval(math[1])

		if card_a.contain?(e)
			check.call(result1 > result2, card_a)
		elsif card_b.contain?(e)
			check.call(result2 > result1, card_b)
		elsif equal.contain?(e)
			check.call(result1 == result2, equal)
		end

		started_var += 1 if (play.contain?(e) && play.opacity > 0.5) || (play_big.contain?(e) && play_big.opacity > 0.5) || (pause.contain?(e) && pause.opacity > 0.5)

		close if power.contain?(e) && power.opacity > 0.4

		if screenshot.contain?(e) && screenshot.opacity > 0.4
			temp = @path + "screenshots/#{Time.new.strftime('%F-%H:%M:%S.png')}"
			Window.screenshot(temp)
			screenshot_message.text, screenshot_message.opacity = "Screenshot saved to #{temp}", 1
			screenshot_message.x, screenshot_message.y = @width/2 - screenshot_message.width/2, screenshot.total_y + 5
		end

		if restart.contain?(e)
			score = 0
			assigned_time = Assigned_Time
			started_var = 0
		end

		Thread.new { system('ruby', 'stats.rb') } if about.contain?(e) && about.opacity > 0.4
	end

	on :key_down do |k|
		result1, result2 = eval(math[0]), eval(math[1])

		started_var += 1 if %w(escape p).include?(k.key)

		if %w(up w).include?(k.key)
			check.call(result1 > result2, card_a)
		elsif %w(down s).include?(k.key)
			check.call(result2 > result1, card_b)
		elsif %w(right left space a d).include?(k.key)
			check.call(result1 == result2, equal)
		end
	end

	update do
		if started_var % 2 == 0
			unless started
				counter += 1
				countdown.opacity = 1

				case counter
					when 0...60
						countdown.text = 'Game Begins in 3'
					when 60...120
						countdown.text = 'Game Begins in 2'
					when 120...180
						countdown.text = 'Game Begins in 1'
					else
						started ||= true
						change_question[]
						counter = 0
				end

				if [1, 60, 120].include?(counter) then beep.play elsif counter >= 179 then start.play end

				countdown.x, countdown.y = @width/2 - countdown.width/2, screenshot.y - countdown.height
			else
				countdown.opacity = 0
			end
		else
			started = false
		end

		unless started
			incop.call([card_a_glow, card_b_glow])

			incop.call([R], 0.6)
			play_big.change_colour = play_big_touched ? '#ff66ff' : '#ffffff'

			play_touched ? decop.call([play]) : incop.call([play])
			play_big_touched ? decop.call([play_big]) : incop.call([play_big])
			restart_touched ? decop.call([restart]) : incop.call([restart])
			power_touched ? decop.call([power]) : incop.call([power])
			screenshot_touched ? decop.call([screenshot]) : incop.call([screenshot])
			about_touched ? decop.call([about]) : incop.call([about])
		else
			i += 1.0
			decop.call([final_point, card_a_glow, card_b_glow], 0)
			assigned_time = Assigned_Time - (i/@fps)

			warning_beep.play if i % @fps == 0 if warn_range.cover?(assigned_time)

			if assigned_time <= 0
				started_var += 1

				card_a.color = card_b.color = equal.color = '#ffffff'
				correct_img.opacity = wrong_img.opacity = 0

				incop.call([final_point])
				final_point.text = "Final Score: #{score}"

				final_point.x, final_point.y = @width/2 - final_point.width/2, card_a.y - final_point.height - 5
				final_point.opacity = 1

				File.open(@path + 'data/scorelist.data', 'a') { |file| file.puts(score) }

				score, i = 0, 0
			end

			time.text = "Time: #{assigned_time.round(1)}"
			time.x = timebox.div_x(time)

			point.text = "Score: #{score}"
			point.x = pointbox.div_x(point)

			decop.call([R, play, restart, about, power, screenshot, play_big], 0)

			# button animations
			equal_touched ? decop.call([equal]) : incop.call([equal])
			message_touched ? decop.call([message]) : incop.call([message])
			timebox_touched ? decop.call([timebox]) : incop.call([timebox])
			pointbox_touched ? decop.call([pointbox]) : incop.call([pointbox])

			if card_a_touched
				incop.call([card_a_shadow], 1, 0.09)
 				decop.call([card_a])
			else
				decop.call([card_a_shadow], 0, 0.09)
				incop.call([card_a])
			end

			if card_b_touched
				incop.call([card_b_shadow], 1, 0.09)
				decop.call([card_b])
			else
				decop.call([card_b_shadow], 0, 0.09)
				incop.call([card_b])
			end
		end

		# Code that should run whether the game is paused or not
		pause_touched ? decop.call([pause]) : incop.call([pause])
		decop.call([screenshot_message], 0, 0.005)

		# Text animation and correct_img, wrong_img animation
		if card_pressed
			decop.call([card_a_text, card_b_text], 0, 0.09)
			card_pressed = false if card_a_text.opacity <= 0
			incop.call([card_a_glow_correct, card_b_glow_correct], 1, 0.1)
		else
			incop.call([card_a_text, card_b_text], 1, 0.09)
			decop.call([correct_img, wrong_img], 0, 0.05)
			decop.call([card_a_glow_correct, card_b_glow_correct], 0, 0.03)
			card_a.change_colour = card_b.change_colour = equal.change_colour = '#ffffff'
		end

		# Message box animation
		anim_control = -1 if message_anim.x3 > message.total_x/1.1
		anim_control = 1 if message_anim.x2 < message.x * 1.2

		message_anim.x1 += anim_control
		message_anim.x2 += anim_control
		message_anim.x3 += anim_control

		# Answers animation
		final_results_a.each do |val_a|
			decop.call([val_a], 0, 0.01)
			val_a.y -= 2

			if val_a.opacity <= 0
				val_a.remove
				final_results_a.delete(val_a)
			end
		end

		final_results_b.each do |val_b|
			decop.call([val_b], 0, 0.005)
			val_b.y += 2

			if val_b.opacity <= 0
				val_b.remove
				final_results_b.delete(val_b)
			end
		end

		# Magic particle animation:
		particles_size.times do |i|
			val = particles[i]
			val.x -= Math.sin(i)
			val.y -= particle_speed[i]
			val.opacity -= 0.004
			val.x, val.y, val.color, val.opacity, particle_speed[i] = rand(0..@width), @height, "##{SecureRandom.hex(3)}", 1, rand(1.0..6.0) if (val.y <= -val.height || val.opacity <= 0)
		end
	end
end
main
show
