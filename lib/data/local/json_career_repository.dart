import 'dart:convert';
import 'dart:io';

import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/domain/repositories/experience_repository.dart';
import 'package:path_provider/path_provider.dart';

class JsonCareerRepository
    implements
        ExperienceRepository,
        SpecItemRepository,
        MasterEssayRepository,
        PortfolioProjectRepository,
        ApplicationRecordRepository {
  const JsonCareerRepository({
    this.fileName = "jaso_supporter_career_data.json",
  });

  final String fileName;

  @override
  Future<List<Experience>> listExperiences() async {
    final Map<String, Object?> data = await _readData();
    final Object? raw = data["experiences"];
    if (raw is! List) {
      return const [];
    }
    return raw
        .whereType<Map>()
        .map((Map item) => Experience.fromJson(Map<String, Object?>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<Experience?> getExperience(String id) async {
    for (final Experience experience in await listExperiences()) {
      if (experience.id == id) {
        return experience;
      }
    }
    return null;
  }

  @override
  Future<void> saveExperience(Experience experience) async {
    final Map<String, Object?> data = await _readData();
    final List<Experience> experiences = await listExperiences();
    final int index = experiences.indexWhere((Experience item) => item.id == experience.id);
    final Experience next = experience.copyWith(updatedAt: DateTime.now());
    if (index >= 0) {
      experiences[index] = next;
    } else {
      experiences.add(next);
    }
    data["experiences"] = experiences.map((Experience item) => item.toJson()).toList();
    await _writeData(data);
  }

  @override
  Future<void> deleteExperience(String id) async {
    final Map<String, Object?> data = await _readData();
    final List<Experience> experiences = await listExperiences();
    experiences.removeWhere((Experience item) => item.id == id);
    data["experiences"] = experiences.map((Experience item) => item.toJson()).toList();
    await _writeData(data);
  }

  @override
  Future<List<SpecItem>> listSpecItems() async {
    final Map<String, Object?> data = await _readData();
    final Object? raw = data["specItems"];
    if (raw is! List) {
      return const [];
    }
    return raw
        .whereType<Map>()
        .map((Map item) => SpecItem.fromJson(Map<String, Object?>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<void> saveSpecItem(SpecItem item) async {
    final Map<String, Object?> data = await _readData();
    final List<SpecItem> items = await listSpecItems();
    final int index = items.indexWhere((SpecItem existing) => existing.id == item.id);
    final SpecItem next = SpecItem(
      id: item.id,
      type: item.type,
      title: item.title,
      value: item.value,
      issuedAt: item.issuedAt,
      createdAt: item.createdAt,
      updatedAt: DateTime.now(),
    );
    if (index >= 0) {
      items[index] = next;
    } else {
      items.add(next);
    }
    data["specItems"] = items.map((SpecItem entry) => entry.toJson()).toList();
    await _writeData(data);
  }

  @override
  Future<void> deleteSpecItem(String id) async {
    final Map<String, Object?> data = await _readData();
    final List<SpecItem> items = await listSpecItems();
    items.removeWhere((SpecItem item) => item.id == id);
    data["specItems"] = items.map((SpecItem entry) => entry.toJson()).toList();
    await _writeData(data);
  }

  @override
  Future<List<MasterEssay>> listMasterEssays() async {
    final Map<String, Object?> data = await _readData();
    final Object? raw = data["masterEssays"];
    if (raw is! List) {
      return const [];
    }
    return raw
        .whereType<Map>()
        .map((Map item) => MasterEssay.fromJson(Map<String, Object?>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<MasterEssay?> getMasterEssay(String id) async {
    for (final MasterEssay essay in await listMasterEssays()) {
      if (essay.id == id) {
        return essay;
      }
    }
    return null;
  }

  @override
  Future<void> saveMasterEssay(MasterEssay essay) async {
    final Map<String, Object?> data = await _readData();
    final List<MasterEssay> essays = await listMasterEssays();
    final int index = essays.indexWhere((MasterEssay item) => item.id == essay.id);
    final MasterEssay next = essay.copyWith(updatedAt: DateTime.now());
    if (index >= 0) {
      essays[index] = next;
    } else {
      essays.add(next);
    }
    data["masterEssays"] = essays.map((MasterEssay item) => item.toJson()).toList();
    await _writeData(data);
  }

  @override
  Future<List<EssayVersion>> listEssayVersions(String masterEssayId) async {
    final Map<String, Object?> data = await _readData();
    final Object? raw = data["essayVersions"];
    if (raw is! List) {
      return const [];
    }
    return raw
        .whereType<Map>()
        .map((Map item) => EssayVersion.fromJson(Map<String, Object?>.from(item)))
        .where((EssayVersion version) => version.masterEssayId == masterEssayId)
        .toList(growable: false);
  }

  @override
  Future<void> saveEssayVersion(EssayVersion version) async {
    final Map<String, Object?> data = await _readData();
    final Object? raw = data["essayVersions"];
    final List<EssayVersion> versions = raw is List
        ? raw.whereType<Map>().map((Map item) => EssayVersion.fromJson(Map<String, Object?>.from(item))).toList()
        : <EssayVersion>[];
    final int index = versions.indexWhere((EssayVersion item) => item.id == version.id);
    if (index >= 0) {
      versions[index] = version;
    } else {
      versions.add(version);
    }
    data["essayVersions"] = versions.map((EssayVersion item) => item.toJson()).toList();
    await _writeData(data);
  }

  @override
  Future<List<PortfolioProject>> listPortfolioProjects() async {
    final Map<String, Object?> data = await _readData();
    final Object? raw = data["portfolioProjects"];
    if (raw is! List) {
      return const [];
    }
    return raw
        .whereType<Map>()
        .map((Map item) => PortfolioProject.fromJson(Map<String, Object?>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<void> savePortfolioProject(PortfolioProject project) async {
    final Map<String, Object?> data = await _readData();
    final List<PortfolioProject> projects = await listPortfolioProjects();
    final int index = projects.indexWhere((PortfolioProject item) => item.id == project.id);
    final PortfolioProject next = project.copyWith(updatedAt: DateTime.now());
    if (index >= 0) {
      projects[index] = next;
    } else {
      projects.add(next);
    }
    data["portfolioProjects"] = projects.map((PortfolioProject item) => item.toJson()).toList();
    await _writeData(data);
  }

  @override
  Future<void> deletePortfolioProject(String id) async {
    final Map<String, Object?> data = await _readData();
    final List<PortfolioProject> projects = await listPortfolioProjects();
    projects.removeWhere((PortfolioProject item) => item.id == id);
    data["portfolioProjects"] = projects.map((PortfolioProject item) => item.toJson()).toList();
    await _writeData(data);
  }

  @override
  Future<List<ApplicationRecord>> listApplicationRecords() async {
    final Map<String, Object?> data = await _readData();
    final Object? raw = data["applicationRecords"];
    if (raw is! List) {
      return const [];
    }
    return raw
        .whereType<Map>()
        .map((Map item) => ApplicationRecord.fromJson(Map<String, Object?>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<void> saveApplicationRecord(ApplicationRecord record) async {
    final Map<String, Object?> data = await _readData();
    final List<ApplicationRecord> records = await listApplicationRecords();
    final int index = records.indexWhere((ApplicationRecord item) => item.id == record.id);
    final ApplicationRecord next = record.copyWith(updatedAt: DateTime.now());
    if (index >= 0) {
      records[index] = next;
    } else {
      records.add(next);
    }
    data["applicationRecords"] = records.map((ApplicationRecord item) => item.toJson()).toList();
    await _writeData(data);
  }

  @override
  Future<void> deleteApplicationRecord(String id) async {
    final Map<String, Object?> data = await _readData();
    final List<ApplicationRecord> records = await listApplicationRecords();
    records.removeWhere((ApplicationRecord item) => item.id == id);
    data["applicationRecords"] = records.map((ApplicationRecord item) => item.toJson()).toList();
    await _writeData(data);
  }

  Future<File> _file() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/$fileName");
  }

  Future<Map<String, Object?>> _readData() async {
    final File file = await _file();
    if (!await file.exists()) {
      return _emptyData();
    }
    final String raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return _emptyData();
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return _emptyData();
    }
    final Map<String, Object?> data = Map<String, Object?>.from(decoded);
    data.putIfAbsent("experiences", () => <Object?>[]);
    data.putIfAbsent("specItems", () => <Object?>[]);
    data.putIfAbsent("masterEssays", () => <Object?>[]);
    data.putIfAbsent("essayVersions", () => <Object?>[]);
    data.putIfAbsent("portfolioProjects", () => <Object?>[]);
    data.putIfAbsent("applicationRecords", () => <Object?>[]);
    return data;
  }

  Future<void> _writeData(Map<String, Object?> data) async {
    final File file = await _file();
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    const JsonEncoder encoder = JsonEncoder.withIndent("  ");
    await file.writeAsString(encoder.convert(data), flush: true);
  }

  Map<String, Object?> _emptyData() {
    return {
      "schemaVersion": 1,
      "experiences": <Object?>[],
      "specItems": <Object?>[],
      "masterEssays": <Object?>[],
      "essayVersions": <Object?>[],
      "portfolioProjects": <Object?>[],
      "applicationRecords": <Object?>[],
    };
  }
}
