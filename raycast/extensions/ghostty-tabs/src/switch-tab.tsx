import {
  Action,
  ActionPanel,
  List,
  closeMainWindow,
  showToast,
  Toast,
} from "@raycast/api";
import { usePromise } from "@raycast/utils";
import { execSync } from "child_process";

// AppleScript that enumerates Ghostty tab titles, one per line.
// Each tab is an AX radio button under the window tab-bar group; the AX
// name is the tab title. We loop and concat with linefeed manually because
// touching `AppleScript's text item delimiters` is annoying to escape.
const LIST_SCRIPT = `tell application "System Events"
    tell process "Ghostty"
        if (count of windows) is 0 then return ""
        try
            set tabStr to ""
            repeat with t in (radio buttons of tab group "tab bar" of window 1)
                set tabStr to tabStr & (name of t) & linefeed
            end repeat
            return tabStr
        on error
            return ""
        end try
    end tell
end tell`;

function listTabs(): string[] {
  const out = execSync(`/usr/bin/osascript -e ${shellQuote(LIST_SCRIPT)}`, {
    encoding: "utf8",
  });
  return out
    .split("\n")
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
}

function switchToTab(name: string): void {
  // Escape AppleScript string literal (backslash + double-quote).
  const escaped = name.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
  const script = `tell application "Ghostty" to activate
tell application "System Events"
    tell process "Ghostty"
        click (first radio button of tab group "tab bar" of window 1 whose name is "${escaped}")
    end tell
end tell`;
  execSync(`/usr/bin/osascript -e ${shellQuote(script)}`);
}

// Wrap a string for safe inclusion as a single shell argument.
function shellQuote(s: string): string {
  return `'${s.replace(/'/g, `'\\''`)}'`;
}

export default function Command() {
  const { data, isLoading, error, revalidate } = usePromise(
    async () => listTabs(),
    [],
    {
      onError: (err) => {
        showToast({
          style: Toast.Style.Failure,
          title: "Couldn't list Ghostty tabs",
          message: err instanceof Error ? err.message : String(err),
        });
      },
    },
  );

  const tabs = data ?? [];

  return (
    <List
      isLoading={isLoading}
      searchBarPlaceholder="Filter Ghostty tabs..."
      onSearchTextChange={() => {
        /* List's built-in filter handles this */
      }}
    >
      {error || tabs.length === 0 ? (
        <List.EmptyView
          title={error ? "Error reading tabs" : "No open Ghostty tabs"}
          description={
            error
              ? "Make sure Raycast has Accessibility permission (System Settings → Privacy & Security → Accessibility)."
              : "Open some tabs in Ghostty and try again."
          }
          actions={
            <ActionPanel>
              <Action title="Reload" onAction={revalidate} />
            </ActionPanel>
          }
        />
      ) : (
        tabs.map((title, i) => (
          <List.Item
            key={`${i}-${title}`}
            title={title}
            accessories={[{ text: `⌘${i + 1 <= 9 ? i + 1 : ""}` }]}
            actions={
              <ActionPanel>
                <Action
                  title="Switch to Tab"
                  onAction={async () => {
                    try {
                      switchToTab(title);
                      await closeMainWindow();
                    } catch (e) {
                      showToast({
                        style: Toast.Style.Failure,
                        title: "Couldn't switch tab",
                        message: e instanceof Error ? e.message : String(e),
                      });
                    }
                  }}
                />
                <Action
                  title="Reload List"
                  onAction={revalidate}
                  shortcut={{ modifiers: ["cmd"], key: "r" }}
                />
              </ActionPanel>
            }
          />
        ))
      )}
    </List>
  );
}
