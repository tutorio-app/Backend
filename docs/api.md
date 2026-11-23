# Tutorio API 계약 초안

기본 경로: `/v1`. JSON 사용. 오류는 `{ "code": "...", "message": "..." }` 형식. 공개 읽기는 인증이 필요 없다. 관리자 쓰기는 서버에서 인증·권한 검사를 통과해야 한다.

## 공개 API

| 메서드 | 경로 | 동작 |
| --- | --- | --- |
| GET | `/services?query=` | 공개 튜토리얼이 있는 서비스 검색 |
| GET | `/services/:serviceSlug/tutorials?platform=&query=` | 서비스의 공개 튜토리얼 목록 |
| GET | `/services/:serviceSlug/practice?platform=` | 공개된 연습 화면과 hotspot을 기능 둘러보기용으로 조회 |
| GET | `/tutorials?query=&platform=` | 전체 공개 튜토리얼 검색 |
| GET | `/tutorials/:id` | 현재 발행 버전과 순서대로 정렬된 단계 조회 |
| POST | `/tutorials/:id/feedback` | 현재 발행 버전의 도움 여부 또는 단계 오류 접수 |

검색 결과는 제목, 목표, 서비스 이름, 플랫폼, 대상 버전, 발행일과 마지막 검토일을 포함한다. 튜토리얼 상세 응답은 단계별 **연습 화면 ID와 목표 hotspot ID**를 포함한다. 기능 둘러보기와 작업 연습은 같은 공개 화면 묶음을 참조한다. 초안은 공개 API 결과에 포함하지 않는다. 존재하지 않거나 비공개인 콘텐츠는 `404`를 반환한다.

피드백 요청: `{ "tutorialVersionId": "uuid", "stepId": "uuid | null", "helpful": true | false | null, "reportText": "string | null" }`. 도움 여부와 신고 내용 중 하나는 필수다. 서버는 `stepId`가 같은 발행 버전에 속하는지 검증한다.

## 관리자 API

| 메서드 | 경로 | 동작 |
| --- | --- | --- |
| GET | `/admin/services` | 모든 서비스 조회 |
| POST | `/admin/services` | 서비스 등록 |
| GET | `/admin/tutorials?status=` | 초안·발행본 관리 목록 |
| POST | `/admin/practice-sets` | 서비스의 UI 버전별 연습 화면 묶음 생성 |
| PUT | `/admin/practice-sets/:id` | 화면, hotspot, 설명, 화면 간 연결 편집 |
| POST | `/admin/tutorials` | 튜토리얼과 첫 초안 생성 |
| GET | `/admin/tutorials/:id` | 편집용 초안과 발행 이력 조회 |
| PUT | `/admin/tutorials/:id/draft` | 제목·목표·단계 등 초안 저장 |
| POST | `/admin/tutorials/:id/publish` | 유효성 검증 후 새 버전 발행 |
| POST | `/admin/tutorials/:id/unpublish` | 공개 목록에서 제외하고 이력 보존 |
| GET | `/admin/feedback` | 신고와 도움 여부 조회 |

관리자 요청에서 권한이 없으면 `401` 또는 `403`을 반환한다. 발행 요청은 `Idempotency-Key` 헤더로 중복 발행을 방지한다. 발행 시 제목·목표·최소 1단계·연속된 단계 순서를 검증한다. 발행본은 직접 수정하지 않고 새 초안을 만들어 다음 버전으로 발행한다.

## AI 연결 지점 (현재 미구현)

나중에 관리자가 제공한 화면 자료와 작업 목표에서 **연습 화면, 누를 영역, 설명**의 초안을 제안한다. 결과는 공용 튜토리얼로 자동 발행하지 않는다. 엔드포인트와 자료 보관 기간은 AI 구현 시 확정한다.
