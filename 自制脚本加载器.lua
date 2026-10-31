(function()
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local LP = Players.LocalPlayer
	local PG = LP:WaitForChild("PlayerGui")
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
				i[k] = v
			end
		end
		if pt then
			i.Parent = pt
		end
		return i
	end
	local function corner(p, r)
		return new("UICorner", { CornerRadius = UDim.new(0, r), Parent = p })
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
	local function pad(p, l, r, t, b)
		return new("UIPadding", {
			PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
			PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0), Parent = p,
		})
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
	local function ring(parent, sz, color, thick, trans)
		local f = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UD.fromScale(.5, .5),
			Size = UD.fromOffset(sz, sz), BackgroundTransparency = 1, Parent = parent,
		})
		corner(f, sz / 2)
		stroke(f, color, thick, trans)
		return f
	end
	local function fitScale(g, bw, pd, mn)
		local s = g:FindFirstChildOfClass("UIScale") or new("UIScale", { Scale = 1, Parent = g })
		local function u()
			s.Scale = math.clamp((CAM.ViewportSize.X - (pd or 40)) / bw, mn or .6, 1)
		end
		u()
		CAM:GetPropertyChangedSignal("ViewportSize"):Connect(u)
		return s
	end

	local gui = new("ScreenGui", {
		Name = "XJWCenterBoot", ResetOnSpawn = false, IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999999, Parent = PG,
	})

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

	local splash = new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UD.fromScale(.5, .5),
		Size = UD.fromOffset(260, 130), BackgroundColor3 = C.Bg,
		BorderSizePixel = 0, Visible = false, Parent = gui,
	})
	corner(splash, 6)
	stroke(splash, C.Cyan, 1, 0.4)
	techCorners(splash, C.Cyan, 12, 2, 0.1)
	local splashScale = new("UIScale", { Scale = 0.88, Parent = splash })

	local logoBox = new("Frame", {
		AnchorPoint = Vector2.new(.5, 0), Position = UD.new(.5, 0, 0, 16),
		Size = UD.fromOffset(44, 44), BackgroundTransparency = 1, Parent = splash,
	})
	local oRing = ring(logoBox, 44, C.Cyan, 1.5, 0.25)
	local mRing = ring(logoBox, 32, C.Purple, 1.2, 0.35)
	local dCore = diamond(logoBox, 12, 12, 20, C.Cyan, 0)
	grad(dCore, C.Cyan, C.Purple, 45)
	diamond(logoBox, 17, 17, 10, C.Bg, 0)

	new("TextLabel", {
		Position = UD.new(0, 0, 0, 68), Size = UD.new(1, 0, 0, 16), BackgroundTransparency = 1,
		Text = "X J W   中 心", TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 14, Parent = splash,
	})
	new("TextLabel", {
		Position = UD.new(0, 0, 0, 86), Size = UD.new(1, 0, 0, 12), BackgroundTransparency = 1,
		Text = "INITIALIZING", TextColor3 = C.Dim, Font = Enum.Font.Code, TextSize = 9, Parent = splash,
	})

	local sBar = new("Frame", {
		AnchorPoint = Vector2.new(.5, 0), Position = UD.new(.5, 0, 0, 106),
		Size = UD.fromOffset(180, 3), BackgroundColor3 = C.Panel2, BorderSizePixel = 0, Parent = splash,
	})
	corner(sBar, 2)
	local sFill = new("Frame", { Size = UD.new(0, 0, 1, 0), BackgroundColor3 = C.Cyan, BorderSizePixel = 0, Parent = sBar })
	corner(sFill, 2)
	grad(sFill, C.Cyan, C.Purple, 0)

	local loginCard = new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UD.fromScale(.5, .5),
		Size = UD.fromOffset(280, 190), BackgroundColor3 = C.Bg,
		BorderSizePixel = 0, Visible = false, Parent = gui,
	})
	corner(loginCard, 6)
	stroke(loginCard, C.Cyan, 1, 0.45)
	techCorners(loginCard, C.Cyan, 14, 2, 0.1)
	local loginScale = fitScale(loginCard, 280, 40, 0.65)

	local lTopGrad = grad(new("Frame", {
		Size = UD.new(1, -20, 0, 2), Position = UD.new(0, 10, 0, 0),
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = loginCard,
	}), C.Cyan, C.Purple, 0)
	lTopGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.5, 0), NumberSequenceKeypoint.new(1, 1),
	})

	new("TextLabel", {
		Position = UD.new(0, 0, 0, 18), Size = UD.new(1, 0, 0, 16), BackgroundTransparency = 1,
		Text = "IDENTITY  VERIFICATION", TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 13, Parent = loginCard,
	})
	new("TextLabel", {
		Position = UD.new(0, 0, 0, 36), Size = UD.new(1, 0, 0, 12), BackgroundTransparency = 1,
		Text = "请输入访问密钥以继续", TextColor3 = C.Dim, Font = Enum.Font.Gotham, TextSize = 10, Parent = loginCard,
	})
	new("Frame", {
		Position = UD.new(0, 0, 0, 58), Size = UD.new(1, 0, 0, 1), BackgroundColor3 = C.Line,
		BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = loginCard,
	})

	local inputWrap = new("Frame", {
		Position = UD.fromOffset(20, 74), Size = UD.new(1, -40, 0, 34),
		BackgroundColor3 = C.Panel, BorderSizePixel = 0, Parent = loginCard,
	})
	corner(inputWrap, 5)
	local inputStroke = stroke(inputWrap, C.Line, 1, 0.2)
	local keyBox = new("TextBox", {
		Size = UD.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "",
		PlaceholderText = "KEY - - - - - -", TextColor3 = C.Text, PlaceholderColor3 = C.Dim,
		Font = Enum.Font.Code, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false, Parent = inputWrap,
	})
	pad(keyBox, 12, 12, 0, 0)
	new("Frame", {
		Position = UD.fromOffset(0, 6), Size = UD.fromOffset(2, 22),
		BackgroundColor3 = C.Cyan, BorderSizePixel = 0, Parent = inputWrap,
	})

	local loginBtn = new("TextButton", {
		Position = UD.fromOffset(20, 120), Size = UD.new(1, -40, 0, 34),
		BackgroundColor3 = C.Panel2, BorderSizePixel = 0, Text = "",
		AutoButtonColor = false, Parent = loginCard,
	})
	corner(loginBtn, 5)
	local loginStroke = stroke(loginBtn, C.Cyan, 1, 0.2)
	local loginFill = new("Frame", {
		Size = UD.fromScale(1, 1), BackgroundColor3 = C.Cyan,
		BackgroundTransparency = 0.88, BorderSizePixel = 0, Parent = loginBtn,
	})
	corner(loginFill, 5)
	new("TextLabel", {
		Size = UD.fromScale(1, 1), BackgroundTransparency = 1, Text = "确 认 登 录",
		TextColor3 = C.Cyan, Font = Enum.Font.GothamBold, TextSize = 12, Parent = loginBtn,
	})

	local statusLabel = new("TextLabel", {
		Position = UD.new(0, 0, 0, 162), Size = UD.new(1, 0, 0, 14),
		BackgroundTransparency = 1, Text = "", TextColor3 = C.Red,
		Font = Enum.Font.Code, TextSize = 10, Parent = loginCard,
	})

	local loadPack
	do
		local root = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UD.fromScale(.5, .5),
			Size = UD.fromOffset(340, 140), BackgroundColor3 = C.Bg,
			BorderSizePixel = 0, Visible = false, Parent = gui,
		})
		corner(root, 6)
		stroke(root, C.Cyan, 1, 0.4)
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
			Text = "XJW  中心  //  INJECTION", TextColor3 = C.Text, Font = Enum.Font.GothamBold,
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
			Text = "Player", TextColor3 = C.Text, Font = Enum.Font.GothamBold,
			TextSize = 9, TextTruncate = Enum.TextTruncate.AtEnd, Parent = pArea,
		})
		local uidLbl = new("TextLabel", {
			Position = UD.fromOffset(4, 74), Size = UD.new(1, -8, 0, 10), BackgroundTransparency = 1,
			Text = "UID 000000", TextColor3 = C.Dim, Font = Enum.Font.Code,
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
			Position = UD.fromOffset(58, 10), Size = UD.new(1, -68, 0, 14), BackgroundTransparency = 1,
			Text = "正在注入...", TextColor3 = C.Text, Font = Enum.Font.GothamBold,
			TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = lArea,
		})
		local subLbl = new("TextLabel", {
			Position = UD.fromOffset(58, 26), Size = UD.new(1, -68, 0, 11), BackgroundTransparency = 1,
			Text = "INJECT  CORE", TextColor3 = C.Dim, Font = Enum.Font.Code,
			TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, Parent = lArea,
		})
		local pctLbl = new("TextLabel", {
			Position = UD.fromOffset(58, 40), Size = UD.new(1, -68, 0, 16), BackgroundTransparency = 1,
			Text = "  0%", TextColor3 = C.Cyan, Font = Enum.Font.Code,
			TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = lArea,
		})
		local barBg = new("Frame", {
			Position = UD.fromOffset(58, 64), Size = UD.new(1, -68, 0, 5),
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

		loadPack = {
			root = root, scale = scale, stroke = root:FindFirstChildOfClass("UIStroke"),
			avImg = avImg, title = titleLbl, sub = subLbl, pct = pctLbl, fill = barFill, stream = streamLbl,
			spinOut = spinOut, spinOutDot = spinOutDot, spinMid = spinMid, spinCore = spinCore,
			uidLbl = uidLbl, pNameLbl = pNameLbl,
		}

		task.spawn(function()
			local ok, th = pcall(function()
				return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			end)
			if ok and th and avImg.Parent then
				avImg.Image = th
			end
		end)
		pNameLbl.Text = LP.Name
		uidLbl.Text = "UID " .. tostring(LP.UserId)
	end

	local okCard = new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UD.fromScale(.5, .5),
		Size = UD.fromOffset(220, 84), BackgroundColor3 = C.Bg,
		BorderSizePixel = 0, Visible = false, Parent = gui,
	})
	corner(okCard, 6)
	stroke(okCard, C.Green, 1, 0.35)
	techCorners(okCard, C.Green, 12, 2, 0.15)
	local okScale = new("UIScale", { Scale = 0.9, Parent = okCard })

	local pulseOuter = new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UD.fromOffset(46, 42),
		Size = UD.fromOffset(42, 42), BackgroundTransparency = 1, Parent = okCard,
	})
	corner(pulseOuter, 21)
	stroke(pulseOuter, C.Green, 1.2, 0.7)

	local checkBox = new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UD.fromOffset(46, 42),
		Size = UD.fromOffset(22, 22), BackgroundTransparency = 1, Parent = okCard,
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
		Text = "脚本加载成功", TextColor3 = C.Text, Font = Enum.Font.GothamBold,
		TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = okCard,
	})
	new("TextLabel", {
		Position = UD.fromOffset(80, 44), Size = UD.new(1, -90, 0, 12), BackgroundTransparency = 1,
		Text = "SYSTEM  READY", TextColor3 = C.Green, Font = Enum.Font.Code,
		TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = okCard,
	})

	local function runLoader(pack, title, sub, accent, dur)
		pack.root.Visible = true
		pack.title.Text = title
		pack.sub.Text = sub
		pack.stroke.Color = accent
		pack.pct.TextColor3 = accent
		if pack.spinOut.UIStroke then
			pack.spinOut.UIStroke.Color = accent
		end
		if pack.spinOutDot then
			pack.spinOutDot.BackgroundColor3 = accent
		end
		if pack.spinCore then
			pack.spinCore.BackgroundColor3 = accent
		end
		pack.fill.BackgroundColor3 = accent

		pack.scale.Scale = 0.9
		tw(pack.scale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
		task.wait(0.12)

		local a1, a2 = 0, 0
		local c1 = RunService.RenderStepped:Connect(function(dt)
			a1 = a1 + dt * 300
			a2 = a2 - dt * 200
			pack.spinOut.Rotation = a1
			pack.spinMid.Rotation = a2
		end)
		local acc = 0
		local c2 = RunService.RenderStepped:Connect(function(dt)
			acc = acc + dt
			if acc > 0.09 then
				acc = 0
				pack.stream.Text = ">> " .. hex(4) .. " " .. hex(4) .. " " .. hex(4)
			end
		end)
		local t0 = os.clock()
		local c3 = RunService.RenderStepped:Connect(function()
			local t = math.clamp((os.clock() - t0) / dur, 0, 1)
			local e = 1 - (1 - t) ^ 2
			pack.fill.Size = UD.new(e, 0, 1, 0)
			pack.pct.Text = string.format("  %d%%", math.floor(e * 100))
		end)
		task.wait(dur)
		c3:Disconnect()
		pack.fill.Size = UD.new(1, 0, 1, 0)
		pack.pct.Text = "  100%"
		task.wait(0.2)
		c1:Disconnect()
		c2:Disconnect()
		tw(pack.scale, 0.2, { Scale = 0.9 })
		task.wait(0.22)
		pack.root.Visible = false
	end

	local _done = false
	local _started = false

	local function mainFlow()
		tw(mask, 0.5, { BackgroundTransparency = 0.4 })

		splash.Visible = true
		tw(splashScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)

		local a = 0
		local sC = RunService.RenderStepped:Connect(function(dt)
			a = a + dt * 90
			oRing.Rotation = a
			mRing.Rotation = -a * 0.7
		end)
		local t0 = os.clock()
		local bC = RunService.RenderStepped:Connect(function()
			local t = math.clamp((os.clock() - t0) / 1.3, 0, 1)
			sFill.Size = UD.new(1 - (1 - t) ^ 2, 0, 1, 0)
		end)
		task.wait(1.4)
		bC:Disconnect()
		sC:Disconnect()
		local aS = makeAlpha(splash)
		aS.tweenTo(1, 0.28)
		task.wait(0.3)
		splash.Visible = false
		splash:Destroy()

		local aL = makeAlpha(loginCard)
		loginCard.Visible = true
		loginScale.Scale = 0.9
		aL.set(1)
		tw(loginScale, 0.38, { Scale = 1 }, Enum.EasingStyle.Back)
		aL.tweenTo(0, 0.38)
		task.wait(0.4)

		keyBox.Text = "XJWnb666"

		local glowConn = RunService.RenderStepped:Connect(function()
			local p = (math.sin(os.clock() * 3) + 1) / 2
			inputStroke.Transparency = 0.55 - p * 0.35
		end)

		task.wait(0.6)

		statusLabel.Text = "验证成功  正在进入..."
		statusLabel.TextColor3 = C.Green
		tw(loginBtn, 0.15, { BackgroundColor3 = C.Green })
		loginStroke.Color = C.Green
		loginFill.BackgroundColor3 = C.Green
		if glowConn then
			glowConn:Disconnect()
		end

		task.wait(0.5)
		aL.tweenTo(1, 0.28)
		task.wait(0.32)
		loginCard.Visible = false
		loginCard:Destroy()

		local aB = makeAlpha(backdrop)
		backdrop.Visible = true
		aB.set(1)
		aB.tweenTo(0, 0.4)

		local scC = RunService.RenderStepped:Connect(function(dt)
			local y = scan.Position.Y.Scale + dt * 0.35
			if y > 1 then
				y = -0.02
			end
			scan.Position = UD.new(0, 0, y, 0)
		end)

		task.wait(0.45)
		runLoader(loadPack, "正在注入脚本核心...", "INJECT  CORE", C.Cyan, 1.6)
		task.wait(0.12)
		runLoader(loadPack, "正在加载功能模块...", "LOAD  FEATURES", C.Purple, 1.4)
		task.wait(0.12)

		local aO = makeAlpha(okCard)
		okCard.Visible = true
		okScale.Scale = 0.85
		aO.set(1)
		tw(okScale, 0.38, { Scale = 1 }, Enum.EasingStyle.Back)
		aO.tweenTo(0, 0.38)

		local pC = RunService.RenderStepped:Connect(function(dt)
			pulseOuter.Rotation = pulseOuter.Rotation + dt * 200
		end)
		task.wait(1.1)
		pC:Disconnect()

		aO.tweenTo(1, 0.26)
		task.wait(0.28)
		okCard.Visible = false
		okCard:Destroy()

		if scC then
			scC:Disconnect()
		end
		aB.tweenTo(1, 0.45)
		tw(mask, 0.55, { BackgroundTransparency = 1 })
		task.wait(0.5)
		pcall(function()
			backdrop.Visible = false
			backdrop:Destroy()
		end)
		pcall(function()
			loadPack.root:Destroy()
		end)
		_done = true
	end

	local function _bootSplashStart()
		if _started then
			return
		end
		_started = true
		task.spawn(function()
			local ok, err = pcall(mainFlow)
			if not ok then
				warn("[XJW] 加载动画异常: " .. tostring(err))
				_done = true
			end
		end)
		task.delay(60, function()
			if not _done then
				_done = true
			end
			pcall(function()
				if gui and gui.Parent then
					gui:Destroy()
				end
			end)
		end)
	end

	local function _bootBuild()
	end

	local function _bootStep(Progress, StageText, WaitTime)
		if WaitTime and WaitTime > 0 then
			task.wait(WaitTime)
		end
	end

	local function _bootFinish()
		local guard = 0
		while not _done and guard < 1400 do
			task.wait(0.05)
			guard = guard + 1
		end
		task.wait(0.05)
	end


	pcall(function()
		mask.BackgroundTransparency = 0.4
		splashScale.Scale = 0.88
		splash.Visible = true
	end)
	pcall(_bootSplashStart)
	pcall(_bootFinish)
	pcall(function()
		if gui and gui.Parent then
			gui:Destroy()
		end
	end)
	task.wait(0.1)
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/luraph.gihub.io/refs/heads/main/%E8%87%AA%E5%88%B6%E8%84%9A%E6%9C%AC.lua"))()
	end)
end)()
