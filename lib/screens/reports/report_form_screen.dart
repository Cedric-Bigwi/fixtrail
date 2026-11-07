import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/locations.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../models/incident.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/network_photo.dart';
import '../../widgets/ui_ext.dart';

/// Used for both creating a report and editing one ([editing] != null).
class ReportFormScreen extends StatefulWidget {
  final Incident? editing;
  const ReportFormScreen({super.key, this.editing});
  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _desc;
  IncidentCategory? _category;
  String? _location;
  bool _anonymous = false;
  Uint8List? _photo;
  bool _removeExisting = false;
  bool _categoryError = false;

  bool get _isEdit => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _title = TextEditingController(text: e?.title);
    _desc = TextEditingController(text: e?.description);
    _category = e?.category;
    _location = e?.location;
    _anonymous = e?.anonymous ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await ImagePicker()
          .pickImage(source: source, maxWidth: 1600, imageQuality: 75);
      if (x != null) {
        final bytes = await x.readAsBytes(); // works on mobile AND web
        if (!mounted) return;
        setState(() {
          _photo = bytes;
          _removeExisting = false;
        });
      }
    } catch (_) {
      if (mounted) showToast(context, 'Could not access the photo.', error: true);
    }
  }

  void _photoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (c) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.photo_camera_outlined, color: AppColors.teal),
            title: const Text('Take a photo'),
            onTap: () {
              Navigator.pop(c);
              _pick(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library_outlined, color: AppColors.teal),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(c);
              _pick(ImageSource.gallery);
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _categoryError = _category == null);
    if (!_form.currentState!.validate() || _category == null) return;
    FocusScope.of(context).unfocus();
    final p = context.read<IncidentProvider>();
    final String? err;
    if (_isEdit) {
      err = await p.updateReport(widget.editing!,
          title: _title.text,
          description: _desc.text,
          category: _category!,
          location: _location!,
          anonymous: _anonymous,
          newPhoto: _photo,
          removePhoto: _removeExisting);
    } else {
      err = await p.submit(
          title: _title.text,
          description: _desc.text,
          category: _category!,
          location: _location!,
          anonymous: _anonymous,
          photo: _photo);
    }
    if (!mounted) return;
    if (err != null) {
      showToast(context, err, error: true);
    } else {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Report updated' : 'Report submitted - thank you!'),
          backgroundColor: AppColors.ink));
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<IncidentProvider>().submitting;
    final existingUrl = widget.editing?.photoUrl;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit report' : 'Report an incident')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          children: [
            _label('Category'),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final c in IncidentCategory.values)
                _CategoryTile(
                  category: c,
                  selected: _category == c,
                  onTap: () => setState(() {
                    _category = c;
                    _categoryError = false;
                  }),
                ),
            ]),
            if (_categoryError)
              const Padding(
                padding: EdgeInsets.only(left: 4, top: 6),
                child: Text('Pick a category',
                    style: TextStyle(color: AppColors.persimmon, fontSize: 12)),
              ),
            _label('Title'),
            TextFormField(
              controller: _title,
              maxLength: 80,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Briefly describe the issue'),
              validator: (v) => Validators.minLength(v, 5, 'Title'),
            ),
            _label('Description'),
            TextFormField(
              controller: _desc,
              maxLines: 5,
              maxLength: 600,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  hintText: 'What happened, when, and who is affected?'),
              validator: (v) => Validators.minLength(v, 15, 'Description'),
            ),
            _label('Location'),
            PickerField(
              label: 'location',
              options: CampusLocations.all,
              icon: Icons.place_outlined,
              initial: _location,
              onChanged: (v) => _location = v,
              validator: (v) => v == null ? 'Choose where the issue is' : null,
            ),
            _label('Photo (optional)'),
            _PhotoBox(
              file: _photo,
              existingUrl: _removeExisting ? null : existingUrl,
              onTap: _photoSheet,
              onRemove: () => setState(() {
                _photo = null;
                if (existingUrl != null) _removeExisting = true;
              }),
            ),
            const SizedBox(height: 16),
            Material(
              color: AppColors.card,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: AppColors.line)),
              child: SwitchListTile(
                value: _anonymous,
                onChanged: (v) => setState(() => _anonymous = v),
                title: const Text('Hide my name from other students',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                subtitle: const Text('Campus staff can still see who reported.',
                    style: TextStyle(fontSize: 12.5)),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _isEdit ? 'Save changes' : 'Submit report',
              icon: Icons.send_rounded,
              loading: submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      );
}

class _CategoryTile extends StatelessWidget {
  final IncidentCategory category;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryTile(
      {required this.category, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - 40 - 30) / 4;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: w,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? category.color : AppColors.field,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? category.color : AppColors.line),
        ),
        child: Column(children: [
          Icon(category.icon, color: selected ? Colors.white : category.color),
          const SizedBox(height: 5),
          Text(category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.ink)),
        ]),
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  final Uint8List? file;
  final String? existingUrl;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _PhotoBox(
      {required this.file,
      required this.existingUrl,
      required this.onTap,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final has = file != null || existingUrl != null;
    if (!has) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          width: double.infinity,
          decoration: BoxDecoration(
            color: tint(AppColors.sand, 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.saffron, width: 1.2),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add_photo_alternate_outlined, color: AppColors.teal, size: 30),
            SizedBox(height: 6),
            Text('Tap to add a photo', style: TextStyle(color: AppColors.muted)),
          ]),
        ),
      );
    }
    return Stack(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 190,
          width: double.infinity,
          child: file != null
              ? Image.memory(file!, fit: BoxFit.cover)
              : NetworkPhoto(url: existingUrl!, fit: BoxFit.cover),
        ),
      ),
      Positioned(
        top: 8,
        right: 8,
        child: Row(children: [
          _Mini(icon: Icons.edit_outlined, onTap: onTap),
          const SizedBox(width: 8),
          _Mini(icon: Icons.close_rounded, onTap: onRemove),
        ]),
      ),
    ]);
  }
}

class _Mini extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Mini({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
            radius: 16,
            backgroundColor: tint(Colors.black, 0.6),
            child: Icon(icon, size: 17, color: Colors.white)),
      );
}
