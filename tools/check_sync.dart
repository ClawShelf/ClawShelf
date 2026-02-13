import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:claw_shelf/core/constants/urls.dart';

void main(List<String> args) async {
  final openClawPath = args.isNotEmpty ? args[0] : '../openclaw_data';

  // 1. Get Local Hash via Git
  final result = await Process.run('git', [
    'log',
    '-1',
    '--format=%H',
    '--',
    'docs/',
  ], workingDirectory: openClawPath);
  final localHash = result.stdout.toString().trim();

  // 2. Get Remote Hash from build.json
  String remoteHash = 'none';
  try {
    final response = await http.get(Uri.parse(remoteVersionUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      remoteHash = data['openclaw_sha'] ?? 'none';
    }
  } catch (e) {
    print('⚠️ Could not fetch remote manifest, assuming first build.');
  }

  // 3. Compare and Output for GitHub Actions
  final bool buildNeeded = localHash != remoteHash;

  // This is the "magic" string GitHub Actions looks for
  print('::set-output name=build_needed::$buildNeeded');
  print('::set-output name=local_hash::$localHash');

  final outputEnv = Platform.environment['GITHUB_OUTPUT'];
  if (outputEnv != null && outputEnv.isNotEmpty) {
    final outputFile = File(Platform.environment['GITHUB_OUTPUT']!);
    outputFile.writeAsStringSync(
      'build_needed=$buildNeeded\n',
      mode: FileMode.append,
    );
    outputFile.writeAsStringSync(
      'local_hash=$localHash\n',
      mode: FileMode.append,
    );
  }

  if (buildNeeded) {
    print('🚀 Update detected: $remoteHash -> $localHash');
  } else {
    print('✅ Everything is up to date.');
  }
}
