# Kuotes - KOReader Highlights on iOS

![widgets-on-phones](assets/widgets-on-phones.jpeg)

Allows fetching and displaying your remotely saved KOReader Highlights and viewing them on your iOS homescreen using widgets.

# Usage

1. Save your KOReader highlights using the plugin [koreader-highlight-sync](https://github.com/gitalexcampos/koreader-Highlight-Sync) on a WebDAV server.
   - Important: the URL has to be in the format `https://your.server.com` meaning lead by `https://` and without a trailing `/`
2. After logging in with your WebDAV credentials, choose the folder where the `*.sdr.json` files from [koreader-highlight-sync](https://github.com/gitalexcampos/koreader-Highlight-Sync) are stored
   1. if the folder has no parent folder: Select it in the 'Folders' tab
   2. if the folder is a subfolder: Hardcode its path in the 'Settings' tab (e.g. `/Documents/`)

Now you can fetch the Highlights in the 'Kuotes' tab or view them on a widget.
The widget can filter for color and type of Highlight:

![widgets-surround-icon](assets/widgets-surround-icon.png)

# Debugging Nightmares

- When removing all highlights from one book, its file will not be deleted but get empty.
- [koreader-highlight-sync](https://github.com/gitalexcampos/koreader-Highlight-Sync) internally labels highlight types differently (e.g. 'strikeout' instead of 'strikethrough')

![icons-horizontal](assets/icons-horizontal.png)