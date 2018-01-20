const name = "SketchWire";

function onStart(context) {
  const scriptPath = context.scriptPath;
  const directory = [scriptPath stringByDeletingLastPathComponent];
  
  const loaded = [[Mocha sharedRuntime] loadFrameworkWithName:name inDirectory:directory];
  if (!loaded) {
    log(name + " loadFrameworkWithName failed");
    return;
  }
  
  const frameworkClass = NSClassFromString(name);
  if (!frameworkClass) {
    log(name + " NSClassFromString failed");
    return;
  }
  
  if (![frameworkClass install]) {
    log(name + " install failed");
    return;
  }
  
  log(name + " OK");
}

function toggleSketchWire(context) {
  const frameworkClass = NSClassFromString(name);
  [frameworkClass toggle];
}

function toggleCrossSketchWire(context) {
  const frameworkClass = NSClassFromString(name);
  [frameworkClass toggleCross];
}

function donateSketchWire(context) {
    const url = "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=BCL2X3AFQBAP2&item_name=Sketch%20Wire%20Beer";
    NSWorkspace.sharedWorkspace().openURL(NSURL.URLWithString(url));
}
