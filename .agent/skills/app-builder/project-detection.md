# Project Type Detection

> Analyze user requests to determine project type and template.

## Keyword Matrix

| Keywords | Project Type | Template |
|----------|--------------|----------|
| blog, post, article | Blog | nextjs-static |
| e-commerce, product, cart, payment | E-commerce | nextjs-fullstack + `/create-admin` |
| dashboard, admin, panel, management, login | Admin Dashboard | `/create-admin` workflow |
| api, backend, service, rest | API Service | express-api |
| python, fastapi, django | Python API | python-fastapi |
| mobile, android, ios, react native | Mobile App (RN) | react-native-app |
| flutter, dart | Mobile App (Flutter) | flutter-app |
| portfolio, personal, cv | Portfolio | nextjs-static |
| crm, customer, sales | CRM | nextjs-fullstack |
| saas, subscription, stripe | SaaS | nextjs-fullstack + `/create-admin` |
| landing, promotional, marketing | Landing Page | nextjs-static |
| docs, documentation | Documentation | nextjs-static |
| extension, plugin, chrome | Browser Extension | chrome-extension |
| desktop, electron | Desktop App | electron-desktop |
| cli, command line, terminal | CLI Tool | cli-tool |
| monorepo, workspace | Monorepo | monorepo-turborepo |

## Detection Process

```
1. Tokenize user request
2. Extract keywords
3. Determine project type
4. Detect missing information → forward to conversation-manager
5. Suggest tech stack
```
