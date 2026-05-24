# NRL Admin CMS

Admin dashboard for NRL (Nur Rianto Learning) portfolio management system. Built with Ruby on Rails 7, Tailwind CSS, and Turbo.

## Overview

NRL Admin provides a unified interface to manage portfolio content:
- **Skills** - Technical skills with category and proficiency level
- **Projects** - Portfolio projects with tech stack and URLs
- **Experiences** - Work experiences with date ranges
- **Tools** - Development tools and software
- **Social Links** - Social media and professional links
- **Profile** - Admin user profile management

## Tech Stack

- **Framework**: Ruby on Rails 7
- **Styling**: Tailwind CSS
- **Frontend**: Turbo + Stimulus
- **API Client**: HTTParty
- **Backend API**: nrl-be (Go)
- **Database**: PostgreSQL

## Requirements

- Ruby 3.x
- PostgreSQL 9.6+
- Redis (for session storage)
- Node.js 18+ (for Tailwind CSS)

## Installation

### 1. Clone the repository

```bash
git clone git@github.com:heru-oktafian/nrl-adm.git
cd nrl-adm
```

### 2. Install dependencies

```bash
bundle install
npm install
```

### 3. Configure environment

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

Edit `.env` with your settings:

```env
# nrl-be API URL
NRL_BE_API_URL=http://localhost:3101/api/v1

# Database credentials
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_password

# Rails
RAILS_MAX_THREADS=5
```

### 4. Setup database

```bash
rails db:create db:migrate
```

### 5. Run the application

```bash
./bin/dev
```

The admin panel will be available at http://localhost:3102

## Default Credentials

- **Username**: `admin`
- **Password**: `admin123`

> ⚠️ Change these credentials in production!

## Project Structure

```
nrl-adm/
├── app/
│   ├── controllers/         # Rails controllers
│   │   ├── admin_resources_controller.rb  # Main CRUD handler
│   │   ├── application_controller.rb
│   │   ├── dashboard_controller.rb
│   │   └── sessions_controller.rb
│   ├── views/
│   │   ├── admin_resources/ # Resource management views
│   │   ├── dashboard/       # Dashboard views
│   │   └── layouts/         # Application layout
│   ├── javascript/          # Stimulus controllers
│   └── lib/
│       └── nrl_api_client.rb # API client helper
├── config/
│   ├── routes.rb            # Route definitions
│   └── puma.rb              # Puma server config (default port 3102)
└── lib/
    └── nrl_api_client.rb    # API communication
```

## API Integration

NRL Admin communicates with the backend API (nrl-be) running on port 3101:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/:resource` | GET | List all resources |
| `/:resource/:id` | GET | Show single resource |
| `/:resource` | POST | Create resource |
| `/:resource/:id` | PUT | Update resource |
| `/:resource/:id` | DELETE | Delete resource |

## Related Projects

| Project | Description | Port |
|---------|-------------|------|
| [nrl-be](https://github.com/heru-oktafian/nrl-be) | Backend API | 3101 |
| [nrl-fe](https://github.com/heru-oktafian/nrl-fe) | Public portfolio frontend | - |

## Development

### Running tests

```bash
rails test
```

### Building assets

```bash
rails assets:precompile
```

## License

MIT License