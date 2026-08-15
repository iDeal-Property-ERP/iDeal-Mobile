class PropertyMapAttachmentGuard {
  bool _active = true;

  bool get isActive => _active;

  bool acceptAttachment() => _active;

  void invalidate() {
    _active = false;
  }
}
