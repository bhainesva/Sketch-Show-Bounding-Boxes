const frameworkName = "ShowBoundingBoxes"

function onStart(context) {
  const scriptPath = context.scriptPath
  const directory = scriptPath.stringByDeletingLastPathComponent()
  const mocha = Mocha.sharedRuntime()

  const loaded = mocha.loadFrameworkWithName_inDirectory(frameworkName, directory)
  if (!loaded) {
    log(frameworkName + " loadFrameworkWithName_inDirectory failed")
    return
  }

  const frameworkClass = NSClassFromString(frameworkName)
  if (!frameworkClass) {
    log(frameworkName + " NSClassFromString failed")
    return
  }

  if (!frameworkClass.install()) {
    log(frameworkName + " install failed")
    return
  }

  log(frameworkName + " OK")
}

function showBoundingBoxes(context) {
  const frameworkClass = NSClassFromString(frameworkName)
  frameworkClass.toggle()
}

function toggleBoundingBoxesCrossMarks(context) {
  const frameworkClass = NSClassFromString(frameworkName)
  frameworkClass.toggleCross()
}

function donateShowBoundingBoxes(context) {
  const url =
    "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=BCL2X3AFQBAP2&item_name=Sketch%20Show%20Bounding%20Boxes%20Beer"
  NSWorkspace.sharedWorkspace().openURL(NSURL.URLWithString(url))
}
