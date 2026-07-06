# Technical Debt Tracker

## High Priority
1. **Hardcoded User Associations**: We currently hardcode `'System Admin'` into audit logs and playlist creations because the `UsersModule` authentication was bypassed or mocked.
2. **Missing Unit Tests**: We have tested compilation and SSR, but we do not have automated Jest suites verifying the FFmpeg chunking logic.
3. **Synchronize = True**: TypeORM is set to `synchronize: true` in `app.module.ts`. This is fatal for production. We must implement rigid Migration files before beta launch.

## Medium Priority
1. **Duplicate Error Handling**: Controllers currently leak standard TypeORM errors. We need a Global Exception Filter to sanitize 500 errors.
2. **Missing Redis Cache**: API endpoints like the Homepage CMS will be hit millions of times. They require a caching layer to avoid DB load.
