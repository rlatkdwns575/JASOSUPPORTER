import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';

/// 유형별 STAR 입력 힌트 (폼·카드 편집기 공통 톤).
class StarFieldHints {
  const StarFieldHints({
    required this.situation,
    required this.task,
    required this.action,
    required this.result,
    required this.learned,
  });

  final String situation;
  final String task;
  final String action;
  final String result;
  final String learned;

  static const StarFieldHints defaults = StarFieldHints(
    situation: '배경·제약·맥락을 적어 주세요.',
    task: '맡은 목표·문제를 적어 주세요.',
    action: '본인이 한 행동·도구·협업을 적어 주세요.',
    result: '확인 가능한 결과만 적어 주세요. 없는 수치는 만들지 마세요.',
    learned: '다음에 쓸 인사이트·역량을 적어 주세요.',
  );

  /// 저장된 Experience.type → 가장 가까운 subtype 힌트.
  static StarFieldHints forExperienceType(ExperienceType type) {
    return switch (type) {
      ExperienceType.club => forSubtype(ExperienceSubtype.club),
      ExperienceType.campusActivity => forSubtype(ExperienceSubtype.classProject),
      ExperienceType.internship => forSubtype(ExperienceSubtype.internship),
      ExperienceType.partTime => forSubtype(ExperienceSubtype.partTime),
      ExperienceType.contest => forSubtype(ExperienceSubtype.contestEntry),
      ExperienceType.bootcamp => forSubtype(ExperienceSubtype.bootcamp),
      ExperienceType.project => forSubtype(ExperienceSubtype.externalProject),
      ExperienceType.trainingAbroad => forSubtype(ExperienceSubtype.exchange),
      ExperienceType.certificate ||
      ExperienceType.education ||
      ExperienceType.other =>
        defaults,
    };
  }

  static StarFieldHints forSubtype(ExperienceSubtype? subtype) {
    if (subtype == null) {
      return defaults;
    }
    return switch (subtype) {
      ExperienceSubtype.club => const StarFieldHints(
          situation: '동아리 규모·분위기, 합류 시점의 과제를 적어 주세요.',
          task: '담당 역할에서 해결하려던 목표를 적어 주세요.',
          action: '회의·기획·실행에서 본인이 한 일을 적어 주세요.',
          result: '행사·산출물·피드백 등 확인 가능한 결과만 적어 주세요.',
          learned: '협업·리더십 등 자소서에 쓸 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.lab => const StarFieldHints(
          situation: '연구실 분위기·주제와 합류 시점을 적어 주세요.',
          task: '맡은 실험·조사·논문 보조 목표를 적어 주세요.',
          action: '실험·분석·문헌 조사에서 본인이 한 일을 적어 주세요.',
          result: '보고서·데이터·피드백 등 확인 가능한 결과만 적어 주세요.',
          learned: '전공·연구 역량과 연결되는 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.classProject => const StarFieldHints(
          situation: '수업·프로젝트 주제와 팀/개인 구성을 적어 주세요.',
          task: '맡은 기능·과제·구현 목표를 적어 주세요.',
          action: '설계·구현·발표에서 본인이 한 일을 적어 주세요.',
          result: '데모·성적·피드백 등 확인 가능한 결과만 적어 주세요.',
          learned: '전공·직무와 연결되는 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.internship => const StarFieldHints(
          situation: '팀/부서 배경과 인턴 기간의 업무 맥락을 적어 주세요.',
          task: '요청받은 업무 목표·기한을 적어 주세요.',
          action: '본인이 수행한 업무·도구·협업을 구체적으로 적어 주세요.',
          result: '산출물·피드백 등 확인 가능한 결과만 (없는 수치는 쓰지 마세요).',
          learned: '지원 직무에 연결되는 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.bootcamp => const StarFieldHints(
          situation: '프로그램 목적·일정과 팀 구성을 적어 주세요.',
          task: '학습·프로젝트에서 맡은 목표를 적어 주세요.',
          action: '수업·실습·협업에서 본인이 한 일을 적어 주세요.',
          result: '배포·데모·피드백 등 확인 가능한 결과만 적어 주세요.',
          learned: '기술·협업에서 다음에 쓸 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.externalProject => const StarFieldHints(
          situation: '프로젝트 목적과 팀/클라이언트 구성을 적어 주세요.',
          task: '맡은 기능·문제 정의를 적어 주세요.',
          action: '설계·구현·협업에서 본인이 한 일을 적어 주세요.',
          result: '배포·데모·지표 등 확인 가능한 결과만 적어 주세요.',
          learned: '기술·협업에서 다음에 쓸 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.award => const StarFieldHints(
          situation: '대회 주제와 참가 형태(팀/개인)를 적어 주세요.',
          task: '수상으로 이어진 목표·평가 기준을 적어 주세요.',
          action: '기획·제작·발표에서 본인 역할을 적어 주세요.',
          result: '실제 수상 결과·피드백만 적어 주세요. 없는 상은 쓰지 마세요.',
          learned: '다음 공모·직무에 연결할 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.contestEntry => const StarFieldHints(
          situation: '공모전 주제와 참가 형태(팀/개인)를 적어 주세요.',
          task: '출품 목표·평가 기준에 맞춘 과제를 적어 주세요.',
          action: '기획·제작·발표에서 본인 역할을 적어 주세요.',
          result: '본선·미수상·피드백 등 확인 가능한 결과만 적어 주세요.',
          learned: '다음 공모·직무에 연결할 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.workingHoliday => const StarFieldHints(
          situation: '체류 국가·비자·근무 환경의 맥락을 적어 주세요.',
          task: '일·생활에서 달성하려던 목표를 적어 주세요.',
          action: '업무·적응·의사소통에서 본인이 한 시도를 적어 주세요.',
          result: '근무·언어·생활 변화 등 확인 가능한 결과만 적어 주세요.',
          learned: '글로벌·자립·소통 역량으로 쓸 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.languageTraining => const StarFieldHints(
          situation: '연수 목적과 수업·생활 환경 제약을 적어 주세요.',
          task: '언어·과정 목표를 적어 주세요.',
          action: '수업·과제·현지 연습에서 본인이 한 시도를 적어 주세요.',
          result: '레벨·시험·피드백 등 확인 가능한 결과만 적어 주세요.',
          learned: '언어·학습 습관으로 쓸 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.exchange => const StarFieldHints(
          situation: '교환 학교·수업 환경과 적응 과제를 적어 주세요.',
          task: '학업·교류에서 달성하려던 목표를 적어 주세요.',
          action: '수강·팀플·캠퍼스 활동에서 본인이 한 일을 적어 주세요.',
          result: '성적·프로젝트·피드백 등 확인 가능한 결과만 적어 주세요.',
          learned: '학업·문화 적응 역량으로 쓸 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.partTime => const StarFieldHints(
          situation: '근무지·고객/업무 환경의 맥락을 적어 주세요.',
          task: '맡은 업무 목표·책임 범위를 적어 주세요.',
          action: '응대·운영·개선에서 본인이 한 일을 적어 주세요.',
          result: '피드백·개선 사례 등 확인 가능한 결과만 적어 주세요.',
          learned: '서비스·책임감 등 직무 연결 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.military => const StarFieldHints(
          situation: '공개 가능한 범위의 환경·역할을 적어 주세요.',
          task: '맡은 임무·책임만 필요 범위로 적어 주세요.',
          action: '본인이 수행한 업무·협업을 과장 없이 적어 주세요.',
          result: '확인 가능한 변화·성과만 적어 주세요.',
          learned: '책임·협업 등 이어서 쓸 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.personal => const StarFieldHints(
          situation: '경험의 배경과 본인이 처한 상황을 적어 주세요.',
          task: '해결하거나 이루려던 목표를 적어 주세요.',
          action: '본인이 한 행동·선택을 구체적으로 적어 주세요.',
          result: '확인 가능한 변화·결과만 적어 주세요. 없는 수치는 쓰지 마세요.',
          learned: '자소서·면접에 연결할 배운 점을 적어 주세요.',
        ),
      ExperienceSubtype.highSchool ||
      ExperienceSubtype.university ||
      ExperienceSubtype.gradSchool ||
      ExperienceSubtype.certificate ||
      ExperienceSubtype.language ||
      ExperienceSubtype.scholarship ||
      ExperienceSubtype.volunteer ||
      ExperienceSubtype.otherSpec =>
        defaults,
    };
  }
}
