{
  monitorWidth ? 1920,
  monitorHeight ? 1080,
  sidebarWidth ? 800,
  sidebarPadding ? (monitorWidth - sidebarWidth) / 2,
  wibarHeight ? 26,
}: ''
configuration {
  kb-row-tab: "";
  kb-mode-next: "Tab";
  kb-cancel: "Escape,Super_L-space";
  show-icons:   true;
  sidebar-mode: true;
  yoffset: ${toString (builtins.div wibarHeight 2)};
  terminal: "gnome-terminal";
}

* {
  background-color:            rgb(2,2,2);
  text-color:                  #d3d7cf;
  selbg:                       #215d9c;
  actbg:                       #262626;
  urgbg:                       #e53935;
  winbg:                       #26c6da;

  selected-normal-foreground:  @winbg;
  normal-foreground:           @text-color;
  dim-foreground:              @actbg;
  selected-normal-background:  @actbg;
  normal-background:           @background-color;

  selected-urgent-foreground:  @background-color;
  urgent-foreground:           @text-color;
  selected-urgent-background:  @urgbg;
  urgent-background:           @background-color;

  selected-active-foreground:  @winbg;
  active-foreground:           @text-color;
  selected-active-background:  @actbg;
  active-background:           @selbg;

  line-margin:                 2;
  line-padding:                2;
  separator-style:             "none";
  hide-scrollbar:              "true";
  margin:                      0;
  padding:                     0;
}

window {
  background-color: rgba(2,2,2, 80%);
  location: west;
  anchor:   west;
  padding:  0 ${toString sidebarPadding} 0 ${toString sidebarPadding};
  height:   ${toString (monitorHeight - wibarHeight)}; /* Leave room for the awesomewm wibar. */
  width:    100%;
  orientation: horizontal;
  children: [mainbox];
}

mainbox {
  spacing:  0.8em;
  children: [ entry,listview,sidebar ];
}

button {
  text-color: @dim-foreground;
  padding: 5px 2px;
}

button selected {
  background-color: @actbg;
  text-color:       @normal-foreground;
}

inputbar {
  padding: 5px;
  spacing: 5px;
  border: 1px;
  border-color: @border;
}

listview {
  spacing: 0.5em;
  dynamic: false;
  cycle:   true;
}

element { padding: 10px; }

entry {
  expand:         false;
  text-color:     @normal-foreground;
  vertical-align: 1;
  padding:        5px;
}

element normal.normal {
  background-color: @normal-background;
  text-color:       @normal-foreground;
}

element normal.urgent {
  background-color: @urgent-background;
  text-color:       @urgent-foreground;
}

element normal.active {
  background-color: @active-background;
  text-color:       @active-foreground;
}

element selected.normal {
  background-color: @selected-normal-background;
  text-color:       @selected-normal-foreground;
  border:           0 5px solid 0 0;
  border-color:     @active-background;
}

element selected.urgent {
  background-color: @selected-urgent-background;
  text-color:       @selected-urgent-foreground;
}

element selected.active {
  background-color: @selected-active-background;
  text-color:       @selected-active-foreground;
}

element alternate.normal {
  background-color: @normal-background;
  text-color:       @normal-foreground;
}

element alternate.urgent {
  background-color: @urgent-background;
  text-color:       @urgent-foreground;
}

element alternate.active {
  background-color: @active-background;
  text-color:       @active-foreground;
}
''
