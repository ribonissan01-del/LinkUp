# LinkUp

LinkUp is a responsive Flutter community chat prototype with server, channel, direct-message, voice-room, and member panes.

## Run

```powershell
flutter pub get
flutter run
```

To run in a browser, use `flutter run -d chrome`. Run the widget checks with `flutter test`.

The current app keeps conversations and controls in local in-memory state. Voice rooms, file sharing, invites, and account settings are UI prototypes; authentication, persistence, and real-time networking are not connected.