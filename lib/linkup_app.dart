import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LinkColors {
  static const canvas = Color(0xFF171B1A);
  static const rail = Color(0xFF111514);
  static const panel = Color(0xFF1E2422);
  static const raised = Color(0xFF28312E);
  static const line = Color(0xFF303936);
  static const text = Color(0xFFE6ECE8);
  static const muted = Color(0xFF929E98);
  static const mint = Color(0xFF9BE3C2);
  static const mintDark = Color(0xFF244C3C);
}

class LinkUpApp extends StatelessWidget {
  const LinkUpApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'LinkUp',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: LinkColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: LinkColors.mint,
        brightness: Brightness.dark,
        surface: LinkColors.panel,
      ),
      useMaterial3: true,
      dividerColor: LinkColors.line,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: LinkColors.raised,
        behavior: SnackBarBehavior.floating,
      ),
    ),
    home: const LinkUpHome(),
  );
}

class _Room {
  const _Room(
    this.name, {
    this.voice = false,
    this.direct = false,
    this.initials = '',
    this.color = LinkColors.mintDark,
  });
  final String name;
  final bool voice;
  final bool direct;
  final String initials;
  final Color color;
}

class _Message {
  _Message(
    this.author,
    this.initials,
    this.color,
    this.time,
    this.body, {
    this.mine = false,
    Map<String, int>? reactions,
  }) : reactions = reactions ?? {};
  final String author;
  final String initials;
  final Color color;
  final String time;
  final String body;
  final bool mine;
  final Map<String, int> reactions;
}

class LinkUpHome extends StatefulWidget {
  const LinkUpHome({super.key});
  @override
  State<LinkUpHome> createState() => _LinkUpHomeState();
}

class _LinkUpHomeState extends State<LinkUpHome> {
  final _message = TextEditingController();
  final _roomSearch = TextEditingController();
  final _messageFocus = FocusNode();
  final _messagesScroll = ScrollController();
  final _servers = ['The Commons', 'Sketchbook', 'Night Owls'];
  final Map<String, List<_Message>> _messages = {};
  String _server = 'The Commons';
  String _filter = '';
  String _search = '';
  String? _voiceRoom;
  bool _compactChat = false;
  bool _membersVisible = true;
  bool _notifications = true;
  bool _mic = true;
  bool _deafened = false;
  late List<_Room> _rooms;
  late _Room _room;

  @override
  void initState() {
    super.initState();
    _rooms = _roomsFor(_server);
    _room = _rooms.first;
    _ensureMessages(_room);
  }

  @override
  void dispose() {
    _message.dispose();
    _roomSearch.dispose();
    _messageFocus.dispose();
    _messagesScroll.dispose();
    super.dispose();
  }

  List<_Room> _roomsFor(String server) {
    final people = server == 'Night Owls'
        ? const [
            _Room(
              'Jordan Lee',
              direct: true,
              initials: 'JL',
              color: Color(0xFF637E9B),
            ),
            _Room(
              'Noah Kim',
              direct: true,
              initials: 'NK',
              color: Color(0xFFB38A55),
            ),
          ]
        : const [
            _Room(
              'Maya Chen',
              direct: true,
              initials: 'MC',
              color: Color(0xFFB36C58),
            ),
            _Room(
              'Jordan Lee',
              direct: true,
              initials: 'JL',
              color: Color(0xFF637E9B),
            ),
            _Room(
              'Noah Kim',
              direct: true,
              initials: 'NK',
              color: Color(0xFFB38A55),
            ),
          ];
    final channels = server == 'Sketchbook'
        ? const ['general', 'work-in-progress', 'inspiration']
        : server == 'Night Owls'
        ? const ['general', 'games', 'late-night']
        : const ['general', 'design-studio', 'dev-log'];
    return [
      for (final name in channels) _Room(name),
      _Room(
        server == 'Sketchbook'
            ? 'studio voice'
            : server == 'Night Owls'
            ? 'after hours'
            : 'lounge',
        voice: true,
      ),
      if (server == 'The Commons') const _Room('study room', voice: true),
      ...people,
    ];
  }

  String get _key => '$_server/${_room.name}';
  List<_Message> get _currentMessages => _messages[_key]!;

  void _ensureMessages(_Room room) {
    _messages.putIfAbsent('$_server/${room.name}', () => _sampleMessages(room));
  }

  List<_Message> _sampleMessages(_Room room) {
    if (room.direct) {
      return [
        _Message(
          room.name,
          room.initials,
          room.color,
          '10:24 AM',
          'Hey! Glad we found each other on LinkUp. What are you working on today?',
        ),
        _Message(
          'You',
          'YO',
          LinkColors.mintDark,
          '10:27 AM',
          'A little bit of everything. Want to catch up later?',
          mine: true,
          reactions: {'✨': 1},
        ),
      ];
    }
    if (room.name == 'general') {
      return [
        _Message(
          'Maya Chen',
          'MC',
          const Color(0xFFB36C58),
          '9:41 AM',
          'Morning everyone! I dropped the first pass at the new community page in the design channel.',
          reactions: {'👀': 3, '✨': 2},
        ),
        _Message(
          'Jordan Lee',
          'JL',
          const Color(0xFF637E9B),
          '9:46 AM',
          'That warm green palette is feeling really good. It feels like a place people want to stay awhile.',
          reactions: {'💚': 4},
        ),
        _Message(
          'Noah Kim',
          'NK',
          const Color(0xFFB38A55),
          '10:02 AM',
          'Agreed. I can wire up the responsive layout this afternoon. Are we keeping the compact member list on tablet?',
        ),
        _Message(
          'Sam Rivera',
          'SR',
          const Color(0xFF8A6F9B),
          '10:08 AM',
          'Let’s hide it below 1100px. The conversation deserves the space.',
          reactions: {'👍': 2},
        ),
      ];
    }
    return [
      _Message(
        'Maya Chen',
        'MC',
        const Color(0xFFB36C58),
        'Yesterday at 4:18 PM',
        'I put a few notes together for this channel. Take a look when you get a chance!',
        reactions: {'💡': 2},
      ),
      _Message(
        'Jordan Lee',
        'JL',
        const Color(0xFF637E9B),
        'Yesterday at 4:32 PM',
        'Nice, this gives us a clear place to start. I’ll add my thoughts here.',
      ),
    ];
  }

  void _selectRoom(_Room room) {
    setState(() {
      _room = room;
      _search = '';
      _compactChat = true;
      _ensureMessages(room);
    });
  }

  void _selectServer(String server) {
    setState(() {
      _server = server;
      _rooms = _roomsFor(server);
      _room = _rooms.first;
      _search = '';
      _compactChat = false;
      _ensureMessages(_room);
    });
  }

  void _openMember(String name) {
    final existing = _rooms.where((room) => room.direct && room.name == name);
    final room = existing.isEmpty
        ? _Room(
            name,
            direct: true,
            initials: _initials(name),
            color: const Color(0xFF708C79),
          )
        : existing.first;
    setState(() {
      if (existing.isEmpty) _rooms.add(room);
      _room = room;
      _search = '';
      _compactChat = true;
      _ensureMessages(room);
    });
  }

  void _send([String? value]) {
    final text = (value ?? _message.text).trim();
    if (text.isEmpty) return;
    setState(() {
      _currentMessages.add(
        _Message('You', 'YO', LinkColors.mintDark, 'now', text, mine: true),
      );
      _message.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_messagesScroll.hasClients) {
        _messagesScroll.animateTo(
          _messagesScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _notice(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<String?> _ask(String title, String hint) => showDialog<String>(
    context: context,
    builder: (context) => _TextPromptDialog(title: title, hint: hint),
  );

  Future<void> _addServer() async {
    final name = await _ask('Create a server', 'Give your space a name');
    if (name == null || name.isEmpty) return;
    _servers.add(name);
    _selectServer(name);
    _notice('$name is ready. Invite someone to join.');
  }

  Future<void> _addRoom({bool voice = false, bool direct = false}) async {
    final name = await _ask(
      direct
          ? 'Start a conversation'
          : 'Create a ${voice ? 'voice' : 'text'} channel',
      direct ? 'Person’s name' : 'Channel name',
    );
    if (name == null || name.isEmpty) return;
    final room = _Room(
      name.replaceAll('#', '').trim(),
      voice: voice,
      direct: direct,
      initials: direct ? _initials(name) : '',
      color: const Color(0xFF708C79),
    );
    setState(() {
      final voiceIndex = _rooms.indexWhere((room) => room.voice);
      _rooms.insert(
        direct || voiceIndex < 0 ? _rooms.length : voiceIndex,
        room,
      );
      _room = room;
      _compactChat = true;
      _ensureMessages(room);
    });
    _notice(direct ? 'Conversation started with $name.' : 'Channel created.');
  }

  String _initials(String value) => value
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((part) => part.isEmpty ? '' : part[0])
      .join()
      .toUpperCase();

  Future<void> _invite() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite people'),
        content: const Text(
          'Share this invite with someone you want in your space.\n\nlinkup.app/invite/commons-8k2m',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(
                const ClipboardData(
                  text: 'https://linkup.app/invite/commons-8k2m',
                ),
              );
              Navigator.pop(context);
              _notice('Invite link copied.');
            },
            icon: const Icon(Icons.copy_rounded, size: 17),
            label: const Text('Copy link'),
          ),
        ],
      ),
    );
  }

  Future<void> _attachment() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: LinkColors.panel,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(title: Text('Add to your message')),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Photo or video'),
              onTap: () => Navigator.pop(context, 'Shared a photo or video'),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file_rounded),
              title: const Text('File'),
              onTap: () => Navigator.pop(context, 'Shared a file'),
            ),
            ListTile(
              leading: const Icon(Icons.poll_outlined),
              title: const Text('Poll'),
              onTap: () => Navigator.pop(context, 'Started a poll'),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      _message.text = '${_message.text}$result';
      _message.selection = TextSelection.collapsed(
        offset: _message.text.length,
      );
      _messageFocus.requestFocus();
    }
  }

  Future<void> _emoji() async {
    const emojis = ['✨', '💚', '👀', '🙌', '😂', '🎉', '👍', '💡'];
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a reaction'),
        content: Wrap(
          spacing: 8,
          children: [
            for (final emoji in emojis)
              IconButton(
                tooltip: emoji,
                onPressed: () => Navigator.pop(context, emoji),
                icon: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
          ],
        ),
      ),
    );
    if (result != null) {
      _message.text = '${_message.text}$result';
      _message.selection = TextSelection.collapsed(
        offset: _message.text.length,
      );
      _messageFocus.requestFocus();
    }
  }

  Future<void> _pins() async {
    final pinned = _currentMessages
        .where((message) => message.reactions.containsKey('📌'))
        .toList();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pinned messages'),
        content: SizedBox(
          width: 360,
          child: pinned.isEmpty
              ? const Text('No pinned messages in this conversation yet.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final message in pinned)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text('${message.author}: ${message.body}'),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      final compact = size.maxWidth < 760;
      final showMembers = !compact && size.maxWidth >= 1120 && _membersVisible;
      return Scaffold(
        body: SafeArea(
          child: compact
              ? (_compactChat
                    ? _chatPanel(compact: true)
                    : Row(
                        children: [
                          _serverRail(compact: true),
                          Expanded(child: _roomSidebar(compact: true)),
                        ],
                      ))
              : Row(
                  children: [
                    _serverRail(),
                    _roomSidebar(),
                    Expanded(
                      child: _chatPanel(
                        showMemberToggle: size.maxWidth >= 1120,
                      ),
                    ),
                    if (showMembers) _memberPanel(),
                  ],
                ),
        ),
      );
    },
  );

  Widget _serverRail({bool compact = false}) => Container(
    width: 68,
    color: LinkColors.rail,
    child: Column(
      children: [
        const SizedBox(height: 12),
        Tooltip(
          message: 'LinkUp home',
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              if (compact) setState(() => _compactChat = false);
              _selectServer('The Commons');
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: LinkColors.mint,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.forum_rounded,
                color: LinkColors.rail,
                size: 23,
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(width: 28, child: Divider(height: 1)),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final server in _servers)
                _ServerIcon(
                  name: server,
                  selected: _server == server,
                  initials: _initials(server).substring(0, 1),
                  onTap: () => _selectServer(server),
                ),
              _RailButton(
                icon: Icons.add_rounded,
                label: 'Add a server',
                color: LinkColors.mint,
                onTap: _addServer,
              ),
            ],
          ),
        ),
        _RailButton(
          icon: Icons.inbox_outlined,
          label: 'Inbox',
          onTap: () => _info(
            'Your inbox',
            'You’re all caught up. New mentions and replies will show up here.',
          ),
        ),
        _RailButton(
          icon: Icons.help_outline_rounded,
          label: 'Help',
          onTap: () => _info(
            'LinkUp help',
            'Your conversations stay organized by space and channel. Use search to find a message.',
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
  );

  Widget _roomSidebar({bool compact = false}) {
    final filtered = _rooms
        .where(
          (room) => room.name.toLowerCase().contains(_filter.toLowerCase()),
        )
        .toList();
    final textRooms = filtered
        .where((room) => !room.voice && !room.direct)
        .toList();
    final voiceRooms = filtered.where((room) => room.voice).toList();
    final directRooms = filtered.where((room) => room.direct).toList();
    return Container(
      width: compact ? null : 250,
      color: LinkColors.panel,
      child: Column(
        children: [
          SizedBox(
            height: 62,
            child: Material(
              color: LinkColors.panel,
              child: InkWell(
                onTap: _serverMenu,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _server,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 19,
                        color: LinkColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 5),
            child: TextField(
              controller: _roomSearch,
              onChanged: (value) => setState(() => _filter = value),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Find a channel',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: LinkColors.rail.withValues(alpha: 0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              children: [
                _Section(label: 'TEXT CHANNELS', onAdd: () => _addRoom()),
                for (final room in textRooms)
                  _RoomTile(
                    room: room,
                    selected: room == _room,
                    onTap: () => _selectRoom(room),
                  ),
                const SizedBox(height: 14),
                _Section(label: 'VOICE', onAdd: () => _addRoom(voice: true)),
                for (final room in voiceRooms)
                  _RoomTile(
                    room: room,
                    selected: room == _room,
                    onTap: () => _selectRoom(room),
                  ),
                const SizedBox(height: 14),
                _Section(
                  label: 'DIRECT MESSAGES',
                  onAdd: () => _addRoom(direct: true),
                ),
                for (final room in directRooms)
                  _RoomTile(
                    room: room,
                    selected: room == _room,
                    onTap: () => _selectRoom(room),
                  ),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'No matching channels',
                      style: TextStyle(color: LinkColors.muted, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          _userPanel(),
        ],
      ),
    );
  }

  Widget _userPanel() => Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 7, 10),
    child: Row(
      children: [
        const _Avatar(
          initials: 'YO',
          color: LinkColors.mintDark,
          size: 34,
          online: true,
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              Text(
                'Available',
                style: TextStyle(color: LinkColors.muted, fontSize: 10),
              ),
            ],
          ),
        ),
        _icon(
          _mic ? Icons.mic_none_rounded : Icons.mic_off_rounded,
          _mic ? 'Mute microphone' : 'Unmute microphone',
          () => setState(() => _mic = !_mic),
        ),
        PopupMenuButton<String>(
          tooltip: 'User settings',
          icon: const Icon(
            Icons.settings_outlined,
            size: 18,
            color: LinkColors.muted,
          ),
          onSelected: (value) {
            if (value == 'profile') {
              _info(
                'Your profile',
                'You’re signed in as You. Your status is Available.',
              );
            }
            if (value == 'status') {
              _notice('Your status is set to Available.');
            }
            if (value == 'settings') {
              _info(
                'Settings',
                'Account, appearance, and notification settings are ready to customize.',
              );
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'profile', child: Text('View profile')),
            PopupMenuItem(value: 'status', child: Text('Set status')),
            PopupMenuItem(value: 'settings', child: Text('Settings')),
          ],
        ),
      ],
    ),
  );

  Widget _chatPanel({bool compact = false, bool showMemberToggle = false}) =>
      Column(
        children: [
          _chatHeader(compact: compact, showMemberToggle: showMemberToggle),
          const Divider(height: 1),
          Expanded(child: _room.voice ? _voiceView() : _messageView()),
          if (!_room.voice) _composer(),
        ],
      );

  Widget _chatHeader({
    bool compact = false,
    bool showMemberToggle = false,
  }) => SizedBox(
    height: 62,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (compact)
            _icon(
              Icons.arrow_back_rounded,
              'Back to channels',
              () => setState(() => _compactChat = false),
            ),
          if (_room.direct)
            _Avatar(
              initials: _room.initials,
              color: _room.color,
              size: 30,
              online: true,
            )
          else
            Icon(
              _room.voice ? Icons.volume_up_rounded : Icons.tag_rounded,
              color: LinkColors.muted,
              size: 20,
            ),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              _room.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 12),
            const SizedBox(height: 22, child: VerticalDivider(width: 1)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _room.direct
                    ? 'A conversation with ${_room.name}'
                    : 'A good place to make something together.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: LinkColors.muted, fontSize: 12),
              ),
            ),
          ] else
            const Spacer(),
          if (_search.isNotEmpty)
            SizedBox(
              width: compact ? 100 : 170,
              child: TextField(
                autofocus: true,
                onChanged: (value) => setState(() => _search = value),
                decoration: InputDecoration(
                  hintText: 'Search messages',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 9,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            )
          else
            _icon(
              Icons.search_rounded,
              'Search messages',
              () => setState(() => _search = ' '),
            ),
          _icon(
            _notifications
                ? Icons.notifications_none_rounded
                : Icons.notifications_off_outlined,
            _notifications
                ? 'Mute this conversation'
                : 'Unmute this conversation',
            () => setState(() => _notifications = !_notifications),
          ),
          _icon(Icons.push_pin_outlined, 'Pinned messages', _pins),
          if (showMemberToggle)
            _icon(
              Icons.people_outline_rounded,
              _membersVisible ? 'Hide members' : 'Show members',
              () => setState(() => _membersVisible = !_membersVisible),
            ),
          PopupMenuButton<String>(
            tooltip: 'Conversation options',
            icon: const Icon(Icons.more_horiz_rounded, color: LinkColors.muted),
            onSelected: (value) {
              if (value == 'invite') _invite();
              if (value == 'copy') {
                Clipboard.setData(
                  ClipboardData(text: 'LinkUp / ${_room.name}'),
                );
                _notice('Channel name copied.');
              }
              if (value == 'clear') setState(() => _search = '');
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'invite', child: Text('Invite people')),
              PopupMenuItem(value: 'copy', child: Text('Copy channel name')),
              PopupMenuItem(
                value: 'clear',
                child: Text('Clear message search'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _messageView() {
    final visible = _currentMessages
        .where(
          (message) =>
              message.body.toLowerCase().contains(_search.trim().toLowerCase()),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: LinkColors.mintDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _room.direct
                      ? Icons.chat_bubble_outline_rounded
                      : Icons.tag_rounded,
                  color: LinkColors.mint,
                  size: 25,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                _room.direct
                    ? 'Your conversation with ${_room.name}'
                    : 'Welcome to #${_room.name}!',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _room.direct
                    ? 'This is the beginning of your conversation.'
                    : 'This is the beginning of the #${_room.name} channel.',
                style: const TextStyle(color: LinkColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: 24, endIndent: 24),
        Expanded(
          child: visible.isEmpty
              ? Center(
                  child: Text(
                    _search.trim().isEmpty
                        ? 'No messages yet. Start the conversation.'
                        : 'No messages match “${_search.trim()}”.',
                    style: const TextStyle(color: LinkColors.muted),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  controller: _messagesScroll,
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
                  itemCount: visible.length,
                  itemBuilder: (context, index) => _MessageTile(
                    message: visible[index],
                    onReact: (emoji) => setState(
                      () => visible[index].reactions[emoji] =
                          (visible[index].reactions[emoji] ?? 0) + 1,
                    ),
                    onPin: () => setState(() {
                      final reactions = visible[index].reactions;
                      if (reactions.containsKey('📌')) {
                        reactions.remove('📌');
                      } else {
                        reactions['📌'] = 1;
                      }
                    }),
                    onReply: () {
                      _message.text = '@${visible[index].author} ';
                      _messageFocus.requestFocus();
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _composer() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
    child: Container(
      decoration: BoxDecoration(
        color: LinkColors.raised,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 4),
            child: IconButton(
              tooltip: 'Add attachment',
              onPressed: _attachment,
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: LinkColors.muted,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              key: const Key('messageComposer'),
              controller: _message,
              focusNode: _messageFocus,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText:
                    'Message ${_room.direct ? _room.name : '#${_room.name}'}',
                hintStyle: const TextStyle(
                  color: LinkColors.muted,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(8, 13, 6, 12),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Add emoji or GIF',
            onPressed: _emoji,
            icon: const Icon(
              Icons.sentiment_satisfied_alt_outlined,
              color: LinkColors.muted,
              size: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6, bottom: 5),
            child: IconButton.filled(
              key: const Key('sendMessage'),
              tooltip: 'Send message',
              onPressed: _send,
              style: IconButton.styleFrom(
                backgroundColor: LinkColors.mint,
                foregroundColor: LinkColors.rail,
                minimumSize: const Size(36, 36),
              ),
              icon: const Icon(Icons.arrow_upward_rounded, size: 19),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _voiceView() {
    final joined = _voiceRoom == _room.name;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: LinkColors.mintDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  color: LinkColors.mint,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                joined
                    ? 'You’re in ${_room.name}'
                    : 'Hang out in ${_room.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                joined ? 'Your voice is connected on this device.' : 'Drop in for a conversation. No ringing, just good company.',
                style: const TextStyle(color: LinkColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (var index = 0; index < (joined ? 3 : 2); index++)
                    Column(
                      children: [
                        _Avatar(
                          initials: ['MC', 'JL', 'YO'][index],
                          color: [
                            const Color(0xFFB36C58),
                            const Color(0xFF637E9B),
                            LinkColors.mintDark,
                          ][index],
                          size: 48,
                          online: true,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          ['Maya', 'Jordan', 'You'][index],
                          style: const TextStyle(
                            color: LinkColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 28),
              if (!joined)
                FilledButton.icon(
                  onPressed: () => setState(() {
                    _voiceRoom = _room.name;
                    _mic = true;
                    _deafened = false;
                  }),
                  icon: const Icon(Icons.headphones_rounded),
                  label: const Text('Join voice'),
                  style: FilledButton.styleFrom(
                    backgroundColor: LinkColors.mint,
                    foregroundColor: LinkColors.rail,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  children: [
                    IconButton.filledTonal(
                      tooltip: _mic ? 'Mute microphone' : 'Unmute microphone',
                      onPressed: () => setState(() => _mic = !_mic),
                      icon: Icon(
                        _mic ? Icons.mic_rounded : Icons.mic_off_rounded,
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: _deafened ? 'Turn sound on' : 'Deafen',
                      onPressed: () => setState(() => _deafened = !_deafened),
                      icon: Icon(
                        _deafened
                            ? Icons.headset_off_rounded
                            : Icons.headphones_rounded,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => setState(() => _voiceRoom = null),
                      icon: const Icon(Icons.call_end_rounded),
                      label: const Text('Leave'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF9C4F43),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _memberPanel() => Container(
    width: 205,
    color: LinkColors.panel,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 70),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 12, 12),
          child: Text(
            'HERE NOW  ·  5',
            style: TextStyle(
              color: LinkColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final name in const [
          'Maya Chen',
          'Jordan Lee',
          'Noah Kim',
          'Sam Rivera',
          'Ari Patel',
        ])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: _MemberTile(name: name, onTap: () => _openMember(name)),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 18, 12, 10),
          child: Text(
            'YOUR STATUS',
            style: TextStyle(
              color: LinkColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Material(
          color: LinkColors.panel,
          child: ListTile(
            dense: true,
            leading: const _Avatar(
              initials: 'YO',
              color: LinkColors.mintDark,
              size: 28,
              online: true,
            ),
            title: const Text('You', style: TextStyle(fontSize: 12)),
            subtitle: const Text('Available', style: TextStyle(fontSize: 10)),
            onTap: () => _info('Your status', 'Your status is Available.'),
          ),
        ),
      ],
    ),
  );

  Future<void> _serverMenu() async {
    final action = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(250, 58, 0, 0),
      items: const [
        PopupMenuItem(value: 'invite', child: Text('Invite people')),
        PopupMenuItem(value: 'text', child: Text('Create text channel')),
        PopupMenuItem(value: 'voice', child: Text('Create voice channel')),
        PopupMenuItem(value: 'settings', child: Text('Server settings')),
      ],
    );
    if (action == 'invite') {
      _invite();
    }
    if (action == 'text') {
      _addRoom();
    }
    if (action == 'voice') {
      _addRoom(voice: true);
    }
    if (action == 'settings') {
      _info('$_server settings', 'Manage your space, channels, and members.');
    }
  }

  Future<void> _info(String title, String message) async => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    ),
  );

  Widget _icon(IconData icon, String tooltip, VoidCallback onPressed) =>
      IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 19, color: LinkColors.muted),
        visualDensity: VisualDensity.compact,
      );
}

class _ServerIcon extends StatelessWidget {
  const _ServerIcon({
    required this.name,
    required this.selected,
    required this.initials,
    required this.onTap,
  });
  final String name;
  final bool selected;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: name,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(selected ? 14 : 22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: selected ? LinkColors.mintDark : LinkColors.raised,
            borderRadius: BorderRadius.circular(selected ? 14 : 22),
            border: selected
                ? Border.all(color: LinkColors.mint.withValues(alpha: 0.65))
                : null,
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: selected ? LinkColors.mint : LinkColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = LinkColors.muted,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        style: IconButton.styleFrom(
          backgroundColor: color == LinkColors.mint
              ? LinkColors.mintDark
              : Colors.transparent,
        ),
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.onAdd});
  final String label;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(5, 0, 0, 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: LinkColors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.55,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Add $label',
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: 16),
          visualDensity: VisualDensity.compact,
        ),
      ],
    ),
  );
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.room,
    required this.selected,
    required this.onTap,
  });
  final _Room room;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final icon = room.voice ? Icons.volume_up_rounded : Icons.tag_rounded;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: selected ? LinkColors.raised : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          key: Key('room-${room.name}'),
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: SizedBox(
            height: 34,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  if (room.direct)
                    _Avatar(
                      initials: room.initials,
                      color: room.color,
                      size: 21,
                      online: true,
                    )
                  else
                    Icon(
                      icon,
                      size: 16,
                      color: selected ? LinkColors.text : LinkColors.muted,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      room.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? LinkColors.text : LinkColors.muted,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.color,
    required this.size,
    this.online = false,
  });
  final String initials;
  final Color color;
  final double size;
  final bool online;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.34),
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.32,
              ),
            ),
          ),
        ),
        if (online)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: LinkColors.mint,
                shape: BoxShape.circle,
                border: Border.all(color: LinkColors.panel, width: 1.5),
              ),
            ),
          ),
      ],
    ),
  );
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFB36C58),
      Color(0xFF637E9B),
      Color(0xFFB38A55),
      Color(0xFF8A6F9B),
    ];
    final initials = name.split(' ').map((part) => part[0]).take(2).join();
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        key: Key('member-$name'),
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: [
              _Avatar(
                initials: initials,
                color: colors[name.length % colors.length],
                size: 30,
                online: true,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: LinkColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.message,
    required this.onReact,
    required this.onPin,
    required this.onReply,
  });
  final _Message message;
  final ValueChanged<String> onReact;
  final VoidCallback onPin;
  final VoidCallback onReply;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(initials: message.initials, color: message.color, size: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    message.author,
                    style: TextStyle(
                      color: message.mine ? LinkColors.mint : LinkColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    message.time,
                    style: const TextStyle(
                      color: LinkColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SelectableText(
                message.body,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFFD4DCD7),
                ),
              ),
              if (message.reactions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      for (final entry in message.reactions.entries)
                        ActionChip(
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            '${entry.key} ${entry.value}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          onPressed: () => onReact(entry.key),
                          backgroundColor: LinkColors.raised,
                          side: BorderSide.none,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Message actions',
          padding: EdgeInsets.zero,
          iconSize: 18,
          icon: const Icon(Icons.more_horiz_rounded, color: LinkColors.muted),
          onSelected: (value) {
            if (value == 'reply') onReply();
            if (value == 'react') onReact('✨');
            if (value == 'pin') onPin();
            if (value == 'copy') {
              Clipboard.setData(ClipboardData(text: message.body));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Message copied.')));
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'reply', child: Text('Reply')),
            PopupMenuItem(value: 'react', child: Text('Add a reaction')),
            PopupMenuItem(value: 'pin', child: Text('Pin message')),
            PopupMenuItem(value: 'copy', child: Text('Copy text')),
          ],
        ),
      ],
    ),
  );
}

class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      autofocus: true,
      decoration: InputDecoration(hintText: widget.hint),
      onSubmitted: (value) => Navigator.pop(context, value.trim()),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text.trim()),
        child: const Text('Create'),
      ),
    ],
  );
}
