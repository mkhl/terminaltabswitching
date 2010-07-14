#import "JRSwizzle.h"

@implementation NSWindowController (TerminalTabSwitching)
- (void)selectRepresentedTabViewItem:(NSMenuItem*)item
{
	NSTabViewItem* tabViewItem = [item representedObject];
	[[tabViewItem tabView] selectTabViewItem:tabViewItem];
}

- (void)updateTabListMenu
{
	NSMenu* windowsMenu = [[NSApplication sharedApplication] windowsMenu];

  BOOL wasSeparator = NO;
	for(NSMenuItem* menuItem in [windowsMenu itemArray])
	{
		if([menuItem action] == @selector(selectRepresentedTabViewItem:))
      [windowsMenu removeItem:menuItem];
    else if ([menuItem action] == @selector(makeKeyAndOrderFront:))
      [windowsMenu removeItem:menuItem];
    else if (wasSeparator && [menuItem isSeparatorItem])
      [windowsMenu removeItem:menuItem];
    else
      wasSeparator = [menuItem isSeparatorItem];
	}

	NSArray* tabViewItems = [[self valueForKey:@"tabView"] tabViewItems];
	for(size_t tabIndex = 0; tabIndex < [tabViewItems count]; ++tabIndex)
	{
		NSString* keyEquivalent = (tabIndex < 10) ? [NSString stringWithFormat:@"%d", (tabIndex+1)%10] : @"";
		NSTabViewItem* tabViewItem = [tabViewItems objectAtIndex:tabIndex];
		NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:[tabViewItem label]
                                                      action:@selector(selectRepresentedTabViewItem:)
                                               keyEquivalent:keyEquivalent];
		[menuItem setRepresentedObject:tabViewItem];
		[windowsMenu addItem:menuItem];
		[menuItem release];
	}
}

- (void)TerminalTabSwitching_awakeFromNib;
{
	[[NSApplication sharedApplication] removeWindowsItem:[self window]];
	[[self window] setExcludedFromWindowsMenu:YES];
	[self TerminalTabSwitching_awakeFromNib];
}

- (void)TerminalTabSwitching_windowDidBecomeMain:(id)fp8;
{
	[self TerminalTabSwitching_windowDidBecomeMain:fp8];
	[self updateTabListMenu];
}

- (void)TerminalTabSwitching_newTab:(id)fp8;
{
	[self TerminalTabSwitching_newTab:fp8];
	[self updateTabListMenu];
}

- (void)TerminalTabSwitching_mergeAllWindows:(id)fp8;
{
	[self TerminalTabSwitching_mergeAllWindows:fp8];
	[self updateTabListMenu];
}

- (void)TerminalTabSwitching_tabView:(id)fp8 didCloseTabViewItem:(id)fp16
{
	[self TerminalTabSwitching_tabView:fp8 didCloseTabViewItem:fp16];
	[self updateTabListMenu];
}

- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView*)aTabView
{
	[self updateTabListMenu];
}
@end

@interface TerminalTabSwitching : NSObject
@end

@implementation TerminalTabSwitching
+ (void)load
{
	[[[NSApplication sharedApplication] windowsMenu] addItem:[NSMenuItem separatorItem]];
	[NSClassFromString(@"TTWindowController") jr_swizzleMethod:@selector(windowDidBecomeMain:) withMethod:@selector(TerminalTabSwitching_windowDidBecomeMain:) error:NULL];
	[NSClassFromString(@"TTWindowController") jr_swizzleMethod:@selector(awakeFromNib) withMethod:@selector(TerminalTabSwitching_awakeFromNib) error:NULL];
	[NSClassFromString(@"TTWindowController") jr_swizzleMethod:@selector(newTab:) withMethod:@selector(TerminalTabSwitching_newTab:) error:NULL];
	[NSClassFromString(@"TTWindowController") jr_swizzleMethod:@selector(mergeAllWindows:) withMethod:@selector(TerminalTabSwitching_mergeAllWindows:) error:NULL];

  [[NSApp windowsMenu] addItem:[NSMenuItem separatorItem]];
  NSWindow *mainWindow = [NSApp mainWindow];
  [NSApp removeWindowsItem:mainWindow];
  [mainWindow setExcludedFromWindowsMenu:YES];
  [[mainWindow windowController] updateTabListMenu];
}
@end
