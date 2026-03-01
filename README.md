📘 Word Rehearsal Service

Backend service for Vocab Rehearse — a vocabulary learning and spaced repetition system with import, OneNote sync, search, and mobile rehearsal features.

This service is developed with Spring Boot, using PostgreSQL, clean architecture principles, and production-grade APIs tailored for a Flutter mobile client.

🧠 Project Summary

This backend provides:

✔ Vocabulary storage with definitions and examples
✔ Import from text files with strict validation
✔ Sync words from Microsoft OneNote
✔ Search by word text
✔ Spaced Repetition (SM-2) based reviews
✔ Error handling compliant with RFC 7807 Problem Details
✔ REST APIs consumed by a Flutter client

📁 Core Features
✅ Word Management

Word objects with:

Definitions

Examples

Synonyms / Antonyms

Context paragraph

Rehearsal scheduling data

Strict rules enforce that a word must have:
✔ At least 1 valid definition
✔ Full examples (no empty example slots)
✔ Proper sanitization
Word marked “ready = false” if validation fails.

✅ Rehearsal Logic

Implements an SM-2 inspired algorithm

Grades (1–5) affect intervals & ease factor

Next review date is updated on each review

✅ Import & Sync

Import from:

Text file via /api/v1/words/file

OneNote via /api/v1/words/sync

Parsing logic is shared — no duplication — and handles:

Word headers

Paragraph / context

Synonyms / antonyms

Examples

Clean definitions

✅ Search & Rehearsal API
Endpoint	Method	Description
/rehearse	GET	Returns due words (with ready = true)
/count-due	GET	Count of due words
/search	GET	Search by word text
/{id}/grade	POST	Submit grade for a word

All endpoints return structured JSON with proper HTTP status codes.

📦 Architecture
Controller
    ↓
Service
    ↓
Repository (JPA)
    ↓
Database (PostgreSQL)
Layers
Layer	Responsibility
Controllers	HTTP API handlers
Services	Business rules + algorithm
Repositories	Database access
Dictionary Providers	Fallback definitions
Exception Handlers	Unified error responses
🧱 Backend Structure
src/main/java
├── controller              // REST endpoints
├── service                 // Business logic
├── model                   // JPA entities
├── repository              // DB access
├── exception               // Global and custom errors
├── dictionary              // Optional definition providers
├── dto                     // Request/response Records & DTOs
└── util                    // Shared parsers & normalizers
📌 Error Handling (RFC 7807)

Errors conform to Problem Details JSON:

{
  "type": "https://vocabrehearse.com/errors/validation-error",
  "title": "Validation Failed",
  "status": 400,
  "detail": "Request validation failed",
  "instance": "/api/v1/words/5/grade",
  "timestamp": "2026-03-01T20:59:21",
  "errors": {
    "grade": "must be ≤ 5"
  }
}

Validation, business exceptions, and unexpected errors are consistently handled.

⚙️ Configuration

application.yml

spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/vocab
    username: postgres
    password: yourpassword

app:
  dict:
    file-path: /your/word/list.txt
🏁 Setup & Running
📥 Clone
git clone https://github.com/vahabov007/Word-Rehearsal-Service.git
cd Word-Rehearsal-Service
🐘 Database Setup

Create PostgreSQL database:

CREATE DATABASE vocab;

Update credentials in application.yml.

▶️ Run Server
mvn clean spring-boot:run

or

mvn clean install
java -jar target/*.jar
🪄 OneNote Sync

To sync with Microsoft OneNote:

Configure OAuth2 client

Call:

POST /api/v1/words/sync

This fetches the “My English Words” page and parses contents.

📱 Flutter Client

The mobile app expects API responses like:

{
  "word": "example",
  "definitions": ["…"],
  "examples": ["…"],
  "synonyms": "...",
  "antonyms": "...",
  "usageFrequency": "Common",
  ...
}

Ensure networking is allowed (CORS) and backend reachable from mobile.

🧪 Testing

Add unit and integration tests with:

JUnit 5

Spring Boot Test

Mockito
(templates are ready in code)

🔐 Security & Validation

Uses @Valid annotations

Returns clean validation error responses

Ready for JWT / OAuth2 expansion

📈 Future Enhancements

✔ Caching (Redis)
✔ Admin dashboard
✔ User login & personalization
✔ Multi-tenant support
✔ Continuous Deployment

📄 License

MIT License — Open Source
