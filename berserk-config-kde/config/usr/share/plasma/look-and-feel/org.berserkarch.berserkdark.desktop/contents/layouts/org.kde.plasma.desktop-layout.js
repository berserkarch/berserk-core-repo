var desktops = desktopsForActivity(currentActivity());

for (var i = 0; i < desktops.length; i++) {
  var d = desktops[i];
  d.wallpaperPlugin = "org.kde.image";
  d.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
  d.writeConfig(
    "Image",
    "file:///usr/share/backgrounds/berserkarch/berserkarch.png",
  );
  d.writeConfig("FillMode", "2"); // 2 = Scaled and Cropped
}

var panel = new Panel();

// Force panel to bottom
panel.location = "bottom";

// Make it floating (Plasma 5.27+ / Plasma 6)
panel.floating = true;

// Optional but recommended: prevent auto-hide
panel.hiding = "none";

// Clean height logic
panel.height = 2 * Math.floor((gridUnit * 2.5) / 2);

// Restrict horizontal panel width for ultrawide monitors
const maximumAspectRatio = 21 / 9;
if (panel.formFactor === "horizontal") {
  const geo = screenGeometry(panel.screen);
  const maximumWidth = Math.ceil(geo.height * maximumAspectRatio);

  if (geo.width > maximumWidth) {
    panel.alignment = "center";
    panel.minimumLength = maximumWidth;
    panel.maximumLength = maximumWidth;
  }
}

// --- Widgets ---

// Kickoff with custom logo
var kickoff = panel.addWidget("org.kde.plasma.kickoff");
kickoff.currentConfigGroup = ["General"];
kickoff.writeConfig("icon", "file:///usr/share/berserkarch/logo.svg");

panel.addWidget("org.kde.plasma.pager");
panel.addWidget("org.kde.plasma.marginsseparator");

var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
  "applications:kitty.desktop",
  "applications:org.kde.dolphin.desktop",
  "applications:firefox.desktop",
]);

panel.addWidget("org.kde.plasma.systemtray");
panel.addWidget("org.kde.plasma.digitalclock");
panel.addWidget("org.kde.plasma.showdesktop");
