# 📘 Word Rehearsal Service

![Java](https://img.shields.io/badge/Java-17+-orange?style=flat-square)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-brightgreen?style=flat-square)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue?style=flat-square)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)

Backend service for **Vocab Rehearse** — a vocabulary learning and spaced repetition system with:

- Import from file  
- OneNote sync  
- Search functionality  
- Mobile rehearsal flow (Flutter client)  

Built with **Spring Boot + PostgreSQL**, following clean architecture principles and a production-style REST API design.

---

## ✨ Features

### ✅ Vocabulary Storage

Stores words with:

- Definitions  
- Examples  
- Synonyms / Antonyms  
- Context paragraph  
- Readiness flag (`is_ready`)  

---

### ✅ Strict “Prepared Words Only”

A word appears in rehearsal **only if it is fully prepared**:

- Must have at least **1 valid definition**
- Must have **complete examples**
- If any `Example X:` is empty → `is_ready = false`

This ensures only high-quality vocabulary is shown during review.

---

### ✅ Spaced Repetition (SM-2 Based)

Implements a modified SM-2 algorithm:

- Grades: **1–5**
- Updates:
  - `easeFactor`
  - `intervalDays`
  - `repetitions`
  - `nextReviewDate`

Grades below 3 reset repetitions and interval.

---

### ✅ Import & Sync

- Import words from local text file
- Sync words from Microsoft OneNote (Microsoft Graph API)
- Shared parsing logic for file and HTML (no duplication)

---

### ✅ Search API

- Case-insensitive substring search
- Returns stored vocabulary entries

---

### ✅ Unified Error Response

All errors return structured JSON:

```json
{
  "message": "No valid definition could be found for word: Concrete",
  "errorCode": "WORD_DEFINITION_NOT_FOUND",
  "status": 404,
  "timestamp": "2026-03-01T21:15:33.421"
}
```

Error fields:

- `message` – Human-readable explanation  
- `errorCode` – Application-specific identifier  
- `status` – HTTP status code  
- `timestamp` – Server timestamp  

Centralized error handling is implemented using `@RestControllerAdvice`.

---

## 🧱 Tech Stack

- Java 17+
- Spring Boot 3.x
- Spring Data JPA (Hibernate)
- PostgreSQL
- Spring Validation
- Swagger / OpenAPI (springdoc)

---

## 📦 Project Structure

```
src/main/java/com/vocabrehearse/word_sync_service
├── controller        # REST endpoints
├── service           # Business logic (sync + rehearsal)
├── model             # JPA entities
├── repository        # JPA repositories
├── dictionary        # Dictionary providers (fallback definitions)
├── exception         # Exceptions + ApiError + Global handler
└── util              # Parsing / normalization helpers
```

---

## 🚀 Getting Started

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/vahabov007/Word-Rehearsal-Service.git
cd Word-Rehearsal-Service
```

---

### 2️⃣ Configure PostgreSQL

Create a database:

```sql
CREATE DATABASE vocab_rehearse;
```

Update your `application.yml` or `application.properties`:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/vocab_rehearse
spring.datasource.username=postgres
spring.datasource.password=your_password
```

---

### 3️⃣ Run the Application

Using Maven Wrapper:

```bash
./mvnw spring-boot:run
```

Or using Maven:

```bash
mvn spring-boot:run
```

Application runs at:

```
http://localhost:8080
```

Swagger UI (if enabled):

```
http://localhost:8080/swagger-ui/index.html
```

---

## 🔌 API Endpoints

Base URL:

```
/api/v1/words
```

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/count-due` | Count due words ready for review |
| GET | `/rehearse?page=0&size=10` | Get due words (strict) |
| POST | `/{id}/grade` | Submit grade (1–5) |
| GET | `/search?query=word` | Search by text |
| POST | `/file` | Import from local file |
| POST | `/sync` | Sync from OneNote |

---

## 🧠 Rehearsal Flow (Mobile)

1. Client requests due words  
   `GET /rehearse`

2. User reviews word and reveals details  

3. User submits grade  
   `POST /{id}/grade`

4. Backend updates:
   - `intervalDays`
   - `easeFactor`
   - `repetitions`
   - `nextReviewDate`

---

## 📄 License

MIT License
