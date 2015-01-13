-- Bird metatable
Bird = {}
Bird.__index = Bird

function Bird.new(x, y, jump, image, originx, originy)
	
	local self = setmetatable({}, Bird)
	
	self.x = x
	self.y = y
	self.xspeed = 0
	self.yspeed = 0
	self.gravity = 0
	self.friction = 1
	self.originx = originx
	self.originy = originy
	
	self.image = image
	self.jump = jump
	
	self.dead = false
	
	return self
	
end

function Bird:update()
   
    self.yspeed = self.yspeed + self.gravity
	self.xspeed = self.xspeed * self.friction

    self.x = self.x + self.xspeed
    self.y = self.y + self.yspeed
	
	if self.y + self.originy > 200 then
		self:die()
		self.xspeed = 0
	end
	
	if self.dead and self.y > 200 - 9 then
		self.y = 200 - 9
	end
	
end

function Bird:keypressed(key)
	
	if key == self.jump and not self.dead then
		self.yspeed = -3.7 --4.2 before
	end
	
end

function Bird:die()
	
	--do white flash and screen shake
	self.dead = true
	self.xspeed = 0
	
end

function Bird:draw()
	
	if self.yspeed < 0 then
		tilt = math.pi / 8
		--tilt = self.yspeed / (-4.5) * math.pi / 6
	else
		tilt = math.pi / 8 - (math.min(1, self.yspeed / 6) * (math.pi / 2 + math.pi / 8))
		--tilt = math.min(1, self.yspeed / 6) * (-math.pi / 2)
	end
	
	if self.xspeed == 0 and not self.dead then
		tilt = 0
	end
	
	quad = love.graphics.newQuad(self.x, self.y, 17, 12, self.image:getWidth(), self.image:getHeight())
	love.graphics.draw(
			self.image, self.x, self.y, -tilt, 1, 1, self.originx, self.originy)
	--love.graphics.drawq(self.image, quad, self.x, self.y)
	
end

-- Pipe metatable
Pipe = {}
Pipe.__index = Pipe

function Pipe.new(x, y, bottomimg, topimg)
	
	local self = setmetatable({}, Pipe)
	
	self.x = x
	self.y = y
	self.bottomimg = bottomimg
	self.topimg = topimg
	
	self.past = false
	
	return self
	
end

function Pipe:update()
	
	if self.x < viewX - 26 then
		self.x = self.x + 4 * hgap
		self.y = math.random(12 + vgap, 188)
		self.past = false
	end
	
	if collides(self.x, self.y, 26, 188,
		bird.x - bird.originx + 1, bird.y - bird.originy + 1, 17 - 2, 12 - 1) or
	collides (self.x, self.y - vgap - 188, 26, 188,
		bird.x - bird.originx + 1, bird.y - bird.originy + 1, 17 - 2, 12 - 1) then
			if not bird.dead then
				bird:die()
			end
	end
	
	if self.x < bird.x and not self.past then
		self.past = true
		score = score + 1
	end
	
end

function Pipe:draw()
	
	love.graphics.draw(self.bottomimg, self.x, self.y)
	love.graphics.draw(self.topimg, self.x, self.y - vgap, 0, 1, 1, 0, 188)
	
end

function collides(x1, y1, w1, h1, x2, y2, w2, h2)
	
	return
		x1 < x2 + w2 and
		x2 < x1 + w1 and
		y1 < y2 + h2 and
		y2 < y1 + h1
	
end

function love.load()
	
	score = 0
	numbers = {}
	numbers[0] = love.graphics.newImage("0.png")
	numbers[1] = love.graphics.newImage("1.png")
	numbers[2] = love.graphics.newImage("2.png")
	numbers[3] = love.graphics.newImage("3.png")
	numbers[4] = love.graphics.newImage("4.png")
	numbers[5] = love.graphics.newImage("5.png")
	numbers[6] = love.graphics.newImage("6.png")
	numbers[7] = love.graphics.newImage("7.png")
	numbers[8] = love.graphics.newImage("8.png")
	numbers[9] = love.graphics.newImage("9.png")
	
	math.randomseed(os.time())
	
	love.graphics.setCaption("Flappy Bird by PJ")
	
	-- Initialize viewport
	love.graphics.setMode(288, 512, false, true, 0)
	viewX = 0
	
	-- Initialize background/foreground
	background = love.graphics.newImage("bcknd.png")
	ground = love.graphics.newImage("ground.png")
	getready = love.graphics.newImage("get ready.png")
	diagram = love.graphics.newImage("diagram.png")
	pressr = love.graphics.newImage("pressr.png")
	difficulties = love.graphics.newImage("difficulties.png")
	
	groundX0 = 0
	groundX1 = 154
	groundX2 = 308
	groundoffset = 0
	
	bird = Bird.new(50, 128, " ", love.graphics.newImage("bird.png"), 8, 6)
	
	pipeimg = love.graphics.newImage("pipe.png")
	toppipe = love.graphics.newImage("top pipe.png")
	hgap = 84
	vgap = 60
	
	pipes = {}
	npipes = 0
	for i = 0, 3 do
		pipes[i] = Pipe.new(200 + (i+1) * hgap, math.random(12 + vgap, 188),
			pipeimg, toppipe)
		npipes = npipes + 1
	end
	
end

function love.update(dt)
	
	bird:update()
	
	for i = 0, npipes - 1 do
		pipes[i]:update()
	end
	
	viewX = bird.x - 50
	
	if bird.xspeed == 0 and not bird.dead then
		groundX0 = groundX0 - 1.2
		groundX1 = groundX1 - 1.2
		groundX2 = groundX2 - 1.2
		if groundX0 <= -154 then
			groundX0 = groundX0 + 308
		end
		if groundX1 <= -154 then
			groundX1 = groundX1 + 308
		end
		if groundX2 <= -154 then
			groundX2 = groundX2 + 308
		end
	end
   
end

function love.keypressed(key)
	
	if key == "escape" then
		love.event.quit()
	end
	
	if key == " " and bird.xspeed == 0 and not bird.dead then
		--pick difficulty
		
		start()
	end
	
	if key == "r" and bird.dead then
		score = 0
		bird.x = 50
		bird.y = 128
		bird.gravity = 0
		bird.yspeed = 0
		bird.dead = false
		for i = 0, 3 do
			pipes[i] = Pipe.new(200 + (i+1) * hgap, math.random(12 + vgap, 188),
				pipeimg, toppipe)
		end
	end
	
	bird:keypressed(key)
	
end

function start()
	bird.xspeed = 1.2
	bird.gravity = 0.2 --0.25 before
	
	groundoffset = groundX0 % 154
end

function love.draw()
	
	-- Create viewport
	love.graphics.scale(2, 2)
	love.graphics.translate(-viewX, 0)
	
	love.graphics.draw(background, viewX, 0)
	
	for i = 0, npipes - 1 do
		pipes[i]:draw()
	end
	
	bird:draw()
	
	if bird.xspeed == 0 and not bird.dead then
		love.graphics.draw(ground, groundX0, 200)
		love.graphics.draw(ground, groundX1, 200)
		love.graphics.draw(ground, groundX2, 200)
	else
		love.graphics.draw(ground, math.floor(viewX / 154) * 154 + groundoffset, 200)
		love.graphics.draw(ground, (math.floor(viewX / 154) + 1) * 154 + groundoffset, 200)
		love.graphics.draw(ground, (math.floor(viewX / 154) - 1) * 154 + groundoffset, 200)
	end
	
	if bird.xspeed == 0 and not bird.dead then
		love.graphics.draw(getready, 29, 60)
		love.graphics.draw(diagram, 50 + 14, 110)
	end
	
	if score > 9 then
		love.graphics.draw(numbers[math.floor(score / 10)], viewX + 72 - 7, 18)
		love.graphics.draw(numbers[score % 10], viewX + 72 + 1, 18)
	else
		love.graphics.draw(numbers[score % 10], viewX + 72 - 3, 18)
	end
	
end