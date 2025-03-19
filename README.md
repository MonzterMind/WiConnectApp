# WiConnectApp

# Node.js App with Database Persistence

This project demonstrates how to create a connection between users (mainly MS Excel or any external platform) and a Node.js application to persist data in a database. The app allows users to interact with the system, and the data entered is saved in a database for future retrieval.

## Features:
- User authentication (optional)
- Data input forms
- Persistent storage of user data in a database
- API endpoints for data retrieval and updates

## Requirements:
- Node.js
- A database (Microsoft SQL Server)
- Environment variables for sensitive data (e.g., DB connection strings)

## Installation:
1. Clone the repository.
2. Run `npm install` to install dependencies.
3. Set up your database and configure the connection.
4. Run the app using `npm start`.

## Usage:
Once the app is running, users can submit data through the frontend or API, and it will be stored in the connected database. The application handles database connections and ensures that data is persisted across sessions.

## License:
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
