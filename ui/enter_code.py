ownerclass = 'HSFairwareReminder'
ownerimport = 'HSFairwareReminder.h'

result = Window(427, 228, "Enter Key")
result.canClose = False
result.canResize = False
result.canMinimize = False
titleLabel = Label(result, "Enter your key")
promptLabel = Label(result, "Type the key you received when you contributed to %@, as well as the e-mail used as a reference for the purchase.")
regkeyLabel = Label(result, "Registration key:")
regkeyField = TextField(result, "")
regemailLabel = Label(result, "Registration e-mail:")
regemailField = TextField(result, "")
osCheckbox = Checkbox(result, "Tell Hardcoded Software which operating system I'm using.")
osSubLabel = Label(result, "(to have some contribution statistics based on OSes)")
contributeButton = Button(result, "Contribute")
cancelButton = Button(result, "Cancel")
submitButton = Button(result, "Submit")

owner.codePromptTextField = promptLabel
owner.codeTextField = regkeyField
owner.emailTextField = regemailField
owner.registerOperatingSystemButton = osCheckbox
result.initialFirstResponder = regkeyField
titleLabel.font = Font(FontFamily.Label, FontSize.RegularControl, traits=[FontTrait.Bold])
smallerFont = Font(FontFamily.Label, FontSize.SmallControl)
for control in (promptLabel, regkeyLabel, regemailLabel, osCheckbox, osSubLabel):
    control.font = smallerFont
osCheckbox.controlSize = const.NSSmallControlSize
osCheckbox.state = const.NSOnState
contributeButton.action = Action(owner, 'contribute')
cancelButton.action = Action(owner, 'cancelCode')
cancelButton.keyEquivalent = "\\E"
submitButton.action = Action(owner, 'submitCode')
submitButton.keyEquivalent = "\\r"

for button in (contributeButton, cancelButton, submitButton):
    button.width = 100
regkeyLabel.width = 128
regemailLabel.width = 128
promptLabel.height = 32

titleLabel.packToCorner(Pack.UpperLeft)
titleLabel.fill(Pack.Right)
promptLabel.packRelativeTo(titleLabel, Pack.Below, Pack.Left)
promptLabel.fill(Pack.Right)
regkeyField.packRelativeTo(promptLabel, Pack.Below, Pack.Right)
regkeyLabel.packRelativeTo(regkeyField, Pack.Left, Pack.Middle)
regkeyField.fill(Pack.Left)
regemailField.packRelativeTo(regkeyField, Pack.Below, Pack.Right)
regemailLabel.packRelativeTo(regemailField, Pack.Left, Pack.Middle)
regemailField.fill(Pack.Left)
osCheckbox.packRelativeTo(regemailField, Pack.Below, Pack.Right)
osCheckbox.fill(Pack.Left)
osSubLabel.packRelativeTo(osCheckbox, Pack.Below, Pack.Left)
osSubLabel.y += 3
contributeButton.packRelativeTo(osSubLabel, Pack.Below, Pack.Left)
osSubLabel.x += 18
osSubLabel.fill(Pack.Right)
submitButton.packRelativeTo(osSubLabel, Pack.Below, Pack.Right)
cancelButton.packRelativeTo(submitButton, Pack.Left, Pack.Middle)
