ownerclass = 'HSFairwareReminder'
ownerimport = 'HSFairwareReminder.h'

result = Window(403, 344, "%@ is Fairware")
result.canClose = False
result.canResize = False
result.canMinimize = False
titleLabel = Label(result, "Please Contribute")
fairwarePromptLabel = Label(result, NLSTR("<fairware prompt>"))
unpaidHoursLabel = Label(result, "Unpaid hours: %0.1f")
moreInfoButton = Button(result, "More Info")
continueButton = Button(result, "Continue")
enterKeyButton = Button(result, "Enter Key")
contributeButton = Button(result, "Contribute")

owner.fairwarePromptTextField = fairwarePromptLabel
owner.fairwareUnpaidHoursTextField = unpaidHoursLabel
result.initialFirstResponder = continueButton
titleLabel.font = Font(FontFamily.Label, FontSize.RegularControl, traits=[FontTrait.Bold])
fairwarePromptLabel.font = Font(FontFamily.Label, FontSize.SmallControl)
unpaidHoursLabel.font = titleLabel.font
unpaidHoursLabel.textColor = Color(0.9, 0.1, 0.1)
moreInfoButton.bezelStyle = const.NSRoundRectBezelStyle
moreInfoButton.action = Action(owner, 'moreInfo')
continueButton.keyEquivalent = "\\r"
continueButton.action = Action(owner, 'closeDialog')
enterKeyButton.action = Action(owner, 'showEnterCode')
contributeButton.action = Action(owner, 'contribute')

for button in (moreInfoButton, continueButton, enterKeyButton, contributeButton):
    button.width = 113
fairwarePromptLabel.height = 232

titleLabel.packToCorner(Pack.UpperLeft)
titleLabel.fill(Pack.Right)
fairwarePromptLabel.packRelativeTo(titleLabel, Pack.Below, Pack.Left)
fairwarePromptLabel.fill(Pack.Right)
unpaidHoursLabel.packRelativeTo(fairwarePromptLabel, Pack.Below, Pack.Left)
moreInfoButton.packRelativeTo(unpaidHoursLabel, Pack.Right, Pack.Middle)
unpaidHoursLabel.fill(Pack.Right)
continueButton.packRelativeTo(unpaidHoursLabel, Pack.Below, Pack.Left)
enterKeyButton.packRelativeTo(continueButton, Pack.Right, Pack.Middle)
contributeButton.packRelativeTo(enterKeyButton, Pack.Right, Pack.Middle)
