MAX_TUTORIAL_ALERTS = 10;
TUTORIALFRAME_QUEUE = { };
LAST_TUTORIAL_BUTTON_SHOWN = nil;

function TutorialFrame_OnHide(self)
	PlaySound("igMainMenuClose");
	if ( not TutorialFrameCheckButton:GetChecked() ) then
		ClearTutorials();
		-- Hide all tutorial buttons
		TutorialFrame_HideAllAlerts();
		return;
	end
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	if ( getn(TUTORIALFRAME_QUEUE) > 0 ) then
		TutorialFrame_AlertButton_OnClick( TUTORIALFRAME_QUEUE[1][2] );
	end
end

function TutorialFrame_Update(currentTutorial)
	FlagTutorial(currentTutorial);
	TutorialFrame.id = currentTutorial;
	local title = _G["TUTORIAL_TITLE"..currentTutorial];
	local text = _G["TUTORIAL"..currentTutorial];
	if ( title and text) then
		TutorialFrameTitle:SetText(title);
		TutorialFrameText:SetText(text);
	end
	TutorialFrame:SetHeight(TutorialFrameText:GetHeight() + 62);

	-- Remove the tutorial from the queue and reanchor the remaining buttons
	local index = 1;
	while TUTORIALFRAME_QUEUE[index] do
		if ( currentTutorial == TUTORIALFRAME_QUEUE[index][1] ) then
			tremove(TUTORIALFRAME_QUEUE, index);
		end
		index = index + 1;
	end
	-- Go through the queue and reanchor the buttons
	local button;
	LAST_TUTORIAL_BUTTON_SHOWN = nil;
	for index, value in pairs(TUTORIALFRAME_QUEUE) do
		button = value[2];
		if ( LAST_TUTORIAL_BUTTON_SHOWN and LAST_TUTORIAL_BUTTON_SHOWN ~= button ) then
			button:SetPoint("BOTTOM", LAST_TUTORIAL_BUTTON_SHOWN, "BOTTOM", 36, 0);
		else
			button:SetPoint("BOTTOM", "TutorialFrameParent", "BOTTOM", 0, 0);
		end
		LAST_TUTORIAL_BUTTON_SHOWN = button;
	end
end

function TutorialFrame_NewTutorial(tutorialID)
	if ( not TutorialFrame:IsShown() ) then
		TutorialFrame:Show();
		TutorialFrame_Update(tutorialID);
		return;
	end

	-- Get tutorial button
	local button = TutorialFrame_GetAlertButton();
	-- Not enough tutorial buttons, not sure how to handle this right now
	if ( not button ) then
		return;
	end
	tinsert(TUTORIALFRAME_QUEUE, {tutorialID, button});

	if ( LAST_TUTORIAL_BUTTON_SHOWN and LAST_TUTORIAL_BUTTON_SHOWN ~= button ) then
		button:SetPoint("BOTTOM", LAST_TUTORIAL_BUTTON_SHOWN, "BOTTOM", 36, 0);
	else
		-- No button shown so this is the first one
		button:SetPoint("BOTTOM", "TutorialFrameParent", "BOTTOM", 0, 0);
	end
	button.id = tutorialID;
	button.tooltip = _G["TUTORIAL_TITLE"..tutorialID];
	LAST_TUTORIAL_BUTTON_SHOWN = button;
	button:Show();
	--UIFrameFlash(button, 0.75, 0.75, 10, 1);
	SetButtonPulse(button, 10, 0.5);
end

function TutorialFrame_GetAlertButton()
	local button;
	for i=1, MAX_TUTORIAL_ALERTS do
		button = _G["TutorialFrameAlertButton"..i];
		if ( not button.id) then
			button:ClearAllPoints();
			return button;
		end
		if ( i == MAX_TUTORIAL_ALERTS ) then
			-- No available tutorial buttons
			return nil;
		end
	end
end

function TutorialFrame_HideAllAlerts()
	local button;
	for i=1, MAX_TUTORIAL_ALERTS do
		button = _G["TutorialFrameAlertButton"..i];
		button.id = nil;
		button.tooltip = nil;
		button:ClearAllPoints();
		ButtonPulse_StopPulse(button);
		button:Hide();
	end
	LAST_TUTORIAL_BUTTON_SHOWN = nil;
	TUTORIALFRAME_QUEUE = { };
end

function TutorialFrame_CheckIntro()
	local button
	for i=1, MAX_TUTORIAL_ALERTS do
		button = _G["TutorialFrameAlertButton"..i];
		if ( button.id == 42 ) then
			button:Click();
			TutorialFrame:SetPoint("BOTTOM", "UIParent", "CENTER", 0, -90);
			return;
		end
	end
end

function TutorialFrame_AlertButton_OnClick(self)
	TutorialFrame:Show();
	self:ClearAllPoints();
	self:Hide();
	TutorialFrame_Update(self.id);
	self.id = nil;
end