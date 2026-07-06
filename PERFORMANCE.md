# NEO Platform Performance Profiling

## 1. Database Bottlenecks
- **Recommendation Engine (Content-Based)**: Currently loads up to 200 entity relations into V8 memory to perform `.map()` scoring and sorting. This is acceptable for ~1,000 entities but will cause Node.js Event Loop Blocking at scale. Must migrate to `pgvector` or Elasticsearch.
- **Unified Search (`/search?q=`)**: Relies on 4 parallel `ILIKE '%query%'` queries. Indexes on standard B-Trees do not optimize full-text search. Must migrate to Postgres `tsvector` or Typesense.

## 2. Media Processing
- `fluent-ffmpeg` and `sharp` are heavily CPU-bound. If 50 admins upload albums simultaneously, the NestJS main thread could degrade.
- **Mitigation**: The current `UploadsService` mimics a queue, but in production, we MUST extract FFmpeg logic to a dedicated microservice or AWS Lambda function connected via Redis/BullMQ.
