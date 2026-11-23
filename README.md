# Backend

튜토리오의 API와 데이터베이스를 위한 저장소입니다.

## 현재 포함된 내용

- `packages/db/migrations/001_init.sql`: PostgreSQL 초기 스키마.
- `docs/api.md`: 공개·관리자 API 계약 초안.

Fastify API 서버, 인증, Drizzle ORM 연결과 마이그레이션 실행 도구는 아직 구현되지 않았습니다. SQL 파일은 자동으로 실행되지 않습니다.

## 관련 저장소

- [Frontend](https://github.com/tutorio-app/Frontend): Expo 클라이언트와 공통 제품 설계 문서.
- [Ai](https://github.com/tutorio-app/Ai): AI 제작 보조.
